package net.kdt.pojavlaunch.fragments;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.StatFs;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.multirt.MultiRTUtils;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;
import net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles;
import net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public class MikaelCrashResolverFragment extends Fragment {
    public static final String TAG="MIKAEL_CRASH_RESOLVER";

    private TextView status,result;
    private Button resolve,undo;
    private String lastSession="";

    private static final Pattern MC=Pattern.compile("(?i)(?:minecraft(?: version)?|game version|version id)[^0-9]{0,32}(\\d+\\.\\d+(?:\\.\\d+)?)");
    private static final Pattern JAR=Pattern.compile("(?i)([A-Za-z0-9_.()+ -]{2,180}\.jar)");
    private static final Pattern DEP=Pattern.compile("(?i)(?:missing dependency|could not find required mod|depends on|requires(?: a dependency)?)[^:\n]*[:\\s]+([A-Za-z0-9_.:\-/]{3,100})");
    private static final Pattern JAVA_CLASS=Pattern.compile("(?i)class file version\\s+(\\d+)");
    private static final Pattern OUTDATED=Pattern.compile("(?i)([A-Za-z0-9_.-]+)[^\n]{0,100}(?:is outdated|outdated|update to)");
    private static final Pattern BAD_FILE=Pattern.compile("(?i)([A-Za-z0-9_.()+ -]{2,180}\.(?:jar|zip|json|toml))");

    private static final class ModInfo {
        File file;
        String id="",name="",version="",loader="unknown";
    }

    private static final class Action {
        String text;
        boolean risky;
        Action(String t,boolean r){text=t;risky=r;}
    }

    public MikaelCrashResolverFragment(){super(R.layout.fragment_mikael_crash_resolver);}

    @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
        status=v.findViewById(R.id.resolve_status);
        result=v.findViewById(R.id.resolve_result);
        resolve=v.findViewById(R.id.resolve_button);
        undo=v.findViewById(R.id.resolve_undo);
        Button back=v.findViewById(R.id.resolve_back);
        resolve.setOnClickListener(x->runResolve());
        undo.setOnClickListener(x->undoLast());
        back.setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
        status.setText("RESOLVER PRO++ pronto");
        result.setText("O reparador trabalha em transação: cria backup, mede a evidência, aplica apenas correções justificadas e registra cada ação.\n\nEle pode ajustar RAM/JVM, quarentenar mods quebrados/incompatíveis, instalar dependências obrigatórias, atualizar mod com correspondência forte, alinhar modloader já instalado, reparar arquivos/pastas, limpar restos de downloads e corrigir opções gráficas.");
    }

    private void runResolve(){
        resolve.setEnabled(false);
        status.setText("PRO++: construindo diagnóstico e plano de reparo...");
        result.setText("");
        new Thread(()->{
            String out;
            try{out=resolveCrash();}catch(Exception e){
                out="ERRO DO RESOLVER PRO++\n\n"+e.getClass().getSimpleName()+": "+e.getMessage();
            }
            final String f=out;
            Activity a=getActivity();
            if(a!=null)a.runOnUiThread(()->{
                if(!isAdded())return;
                result.setText(f);
                status.setText(f.contains("NENHUMA CORREÇÃO")?"Nenhuma correção segura encontrada":"Reparo PRO++ concluído");
                resolve.setEnabled(true);
            });
        }).start();
    }

    private String resolveCrash() throws Exception{
        File dir=getCurrentProfileDirectory();
        File log=findNewestLog(dir);
        if(log==null)return "NENHUMA CORREÇÃO\n\nNenhum log/crash-report recente encontrado.";

        String text=readTail(log,420000);
        String l=text.toLowerCase(Locale.ROOT);

        File root=new File(dir,".mikael_backups");
        String stamp=new SimpleDateFormat("yyyyMMdd_HHmmss_SSS",Locale.US).format(new Date());
        File session=new File(root,stamp);
        if(!session.mkdirs())throw new Exception("Não foi possível criar o backup transacional.");
        lastSession=session.getAbsolutePath();

        List<Action> actions=new ArrayList<>();
        List<String> moved=new ArrayList<>();
        List<String> created=new ArrayList<>();
        saveText(session,"input.log.info","source="+log.getAbsolutePath()+"\nmtime="+log.lastModified()+"\nsize="+log.length());

        MinecraftProfile profile=null;
        String oldVersion=null;
        try{LauncherProfiles.load(); profile=LauncherProfiles.getCurrentProfile(); oldVersion=profile.lastVersionId;}catch(Exception ignored){}

        String mc=match(MC,text);
        if(mc==null && profile!=null)mc=normalizeMc(profile.lastVersionId);
        String loader=currentLoader(profile,text);

        List<ModInfo> mods=scanMods(new File(dir,"mods"));
        int invalidMods=0;
        for(ModInfo m:mods)if("invalid".equals(m.loader))invalidMods++;

        RuntimeInfo ram=runtimeInfo();
        StorageInfo storage=storageInfo(dir,mods.size());

        saveText(session,"before.state",
                "minecraft="+nullSafe(mc)+"\nloader="+loader+"\nprofileVersion="+nullSafe(oldVersion)+
                "\nramAllocated="+ram.allocated+"\nramAvailable="+ram.available+"\nramTotal="+ram.total+
                "\nfreeStorage="+storage.free+"\nmods="+mods.size());

        int evidence=0;
        String suspect=findSuspectJar(text,dir,mods);
        if(suspect!=null)evidence+=15;

        // A) Repair clearly corrupt JARs before anything else.
        for(ModInfo m:mods){
            if(!isReadableJar(m.file)){
                if(quarantine(m.file,session,"corrupt_mods",m.file.getName(),moved)){
                    actions.add(new Action("MOD CORROMPIDO: "+m.file.getName()+" → quarentena",false));
                    invalidMods++;
                }
            }
        }

        // B) Quarantine an exact offending mod only when the log has a concrete failure signature.
        if(suspect!=null && shouldQuarantine(l)){
            File sf=findModFile(new File(dir,"mods"),suspect);
            if(sf!=null && quarantine(sf,session,"suspect_mods",sf.getName(),moved)){
                actions.add(new Action("MOD SUSPEITO REMOVIDO COM SEGURANÇA: "+sf.getName()+" (quarentena)",false));
                evidence+=20;
            }
        }

        // C) Repair missing required dependencies using exact Modrinth project matches.
        if(mc!=null && !mc.isEmpty() && hasAny(l,
                "missing dependency","could not find required mod","depends on","requires")){
            Set<String> deps=extractDependencies(text);
            Set<String> seen=new HashSet<>();
            for(String dep:deps){
                if(!looksLikeProjectId(dep) || isInstalledDependency(dep,mods))continue;
                String installed=installDependencyRecursive(dep,mc,loader,dir,seen,created);
                if(installed!=null){
                    actions.add(new Action("DEPENDÊNCIA OBRIGATÓRIA INSTALADA: "+installed,false));
                    evidence+=14;
                }
            }
        }

        // D) Update an outdated mod only when the log names a concrete mod/JAR.
        if(mc!=null && suspect!=null && hasAny(l,"outdated","is outdated","update to")){
            String updated=updateExactMod(suspect,mc,loader,dir,session,moved,created);
            if(updated!=null){
                actions.add(new Action("MOD ATUALIZADO: "+updated,false));
                evidence+=16;
            }
        }

        // E) Auto-select another installed loader when the crash and mod inventory agree.
        if(profile!=null && mc!=null){
            LoaderStats stats=loaderStats(mods);
            String desired=bestLoader(stats,loader);
            if(desired!=null && !desired.equalsIgnoreCase(loader) && (stats.maxCount>=Math.max(2,(int)Math.ceil(mods.size()*0.70)))){
                String alternative=findInstalledVersionForLoader(new File(dir,"versions"),mc,desired);
                if(alternative!=null){
                    backupProfile(session,oldVersion);
                    profile.lastVersionId=alternative;
                    LauncherProfiles.write();
                    actions.add(new Action("MODLOADER ALINHADO: "+loader+" → "+desired+" ("+alternative+")",false));
                    evidence+=17;
                }
            }
        }

        // F) RAM repair for real JVM memory failures. Conservative and based on physical + available RAM.
        if(hasAny(l,"outofmemoryerror","java heap space","gc overhead limit exceeded","failed to allocate","unable to create native thread")){
            int target=safeRamTarget(ram,l);
            if(target>0 && target!=ram.allocated){
                savePref(session,"allocation",String.valueOf(ram.allocated));
                LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation",target).apply();
                actions.add(new Action("RAM AJUSTADA: "+ram.allocated+" MB → "+target+" MB",false));
                evidence+=18;
            }
        }

        // G) Java runtime alignment from class-file version, using an installed exact/nearest runtime only.
        int requiredJava=requiredJava(text);
        if(requiredJava>0){
            String runtime=MultiRTUtils.getExactJreName(requiredJava);
            if(runtime==null)runtime=MultiRTUtils.getNearestJreName(requiredJava);
            if(runtime!=null && !runtime.isEmpty()){
                String oldRt=LauncherPreferences.DEFAULT_PREF.getString("defaultRuntime","");
                if(!runtime.equals(oldRt)){
                    savePref(session,"defaultRuntime",oldRt);
                    savePref(session,"disable_autojre_select",String.valueOf(LauncherPreferences.DEFAULT_PREF.getBoolean("disable_autojre_select",false)));
                    LauncherPreferences.DEFAULT_PREF.edit().putString("defaultRuntime",runtime).putBoolean("disable_autojre_select",false).apply();
                    actions.add(new Action("JAVA ALINHADO: runtime "+runtime,false));
                    evidence+=18;
                }
            } else {
                actions.add(new Action("JAVA NECESSÁRIO: Java "+requiredJava+" não está instalado; nenhum arquivo foi alterado",false));
            }
        }

        // H) JVM argument repair only for explicit VM initialization failures.
        if(hasAny(l,"could not create the java virtual machine","unrecognized vm option","invalid vm option","error occurred during initialization of vm")){
            String oldArgs=LauncherPreferences.DEFAULT_PREF.getString("javaArgs","");
            if(oldArgs!=null && !oldArgs.trim().isEmpty()){
                savePref(session,"javaArgs",oldArgs);
                LauncherPreferences.DEFAULT_PREF.edit().putString("javaArgs","").apply();
                actions.add(new Action("JVM: argumentos personalizados removidos para voltar ao padrão",false));
                evidence+=12;
            }
        }

        // I) Graphics recovery: disable the unstable options, preserve user files via backup.
        if(hasAny(l,"opengl error","egl_bad","egl error","vulkan error","shader compilation","glfw error","fatal signal 11","sigsegv","native crash")){
            SharedPreferences p=LauncherPreferences.DEFAULT_PREF;
            savePref(session,"force_vsync",String.valueOf(p.getBoolean("force_vsync",false)));
            savePref(session,"alternate_surface",String.valueOf(p.getBoolean("alternate_surface",true)));
            savePref(session,"dump_shaders",String.valueOf(p.getBoolean("dump_shaders",false)));
            p.edit().putBoolean("force_vsync",false).putBoolean("alternate_surface",true).putBoolean("dump_shaders",false).apply();
            actions.add(new Action("GPU: VSync desativado + superfície alternativa ativada",false));
            backupOptionFile(dir,session,"options.txt",moved,actions);
            backupOptionFile(dir,session,"optionsof.txt",moved,actions);
            backupOptionFile(dir,session,"optionsshaders.txt",moved,actions);
            evidence+=14;
        }

        // J) File-system repair: recreate expected folders and remove only stale temporary download fragments.
        String[] folders={"mods","config","logs","crash-reports","shaderpacks","resourcepacks","saves"};
        if(hasAny(l,"permission denied","read-only file system","nosuchfileexception","failed to open","no such file")){
            for(String name:folders){
                File f=new File(dir,name);
                if(!f.exists() && f.mkdirs())actions.add(new Action("PASTA RECRIADA: "+name,false));
            }
            int cleaned=cleanTemps(dir);
            if(cleaned>0)actions.add(new Action("ARQUIVOS TEMPORÁRIOS REMOVIDOS: "+cleaned,false));
            evidence+=8;
        }

        // K) Corrupted/partial downloads: only files with .part/.tmp/.download in game folders.
        if(hasAny(l,"download failed","failed to download","connection reset","timeout")){
            int cleaned=cleanTemps(dir);
            if(cleaned>0)actions.add(new Action("DOWNLOADS INCOMPLETOS LIMPOS: "+cleaned,false));
        }

        // L) Empty mod directory sanity check: create it if a mods-related crash occurred.
        if(hasAny(l,"modresolution","mod loading","mixin","fabricloader","modlauncher")){
            File md=new File(dir,"mods");
            if(!md.exists()&&md.mkdirs())actions.add(new Action("PASTA RECRIADA: mods",false));
        }

        writeRestoreMap(session,moved);
        writeCreatedMap(session,created);
        saveText(session,"actions.txt",actionText(actions));
        saveText(session,"resolution.score","evidence="+evidence+"\nreversible=true\nactions="+actions.size());

        if(actions.isEmpty()){
            deleteTree(session);
            return "NENHUMA CORREÇÃO AUTOMÁTICA\n\n"+
                    "O analisador não encontrou uma ação suficientemente segura e específica.\n\n"+
                    "Nada foi removido, nenhum mod foi alterado e nenhuma preferência foi modificada.\n"+
                    "Use VERIFICAR CRASH para consultar a causa e as evidências.";
        }

        int confidence=Math.max(20,Math.min(99,45+evidence));
        StringBuilder out=new StringBuilder();
        out.append("══════════════════════════════\n");
        out.append("MIKAEL AUTO RESOLVER PRO++\n");
        out.append("══════════════════════════════\n\n");
        out.append("CONFIANÇA DO PLANO: ").append(confidence).append("/100\n");
        out.append("Minecraft: ").append(nullSafe(mc)).append("\n");
        out.append("Modloader antes: ").append(loader).append("\n");
        out.append("Mods detectados: ").append(mods.size()).append("\n");
        out.append("RAM: ").append(ram.allocated).append(" MB alocados • ").append(ram.available).append(" MB disponíveis agora\n");
        out.append("Espaço livre: ").append(storage.free).append(" MB\n\n");
        out.append("CORREÇÕES APLICADAS\n");
        for(Action a:actions)out.append("✓ ").append(a.text).append(a.risky?" [ATENÇÃO]":"").append("\n");
        out.append("\nBACKUP TRANSACIONAL\n").append(session.getAbsolutePath()).append("\n");
        out.append("\nCOMO TESTAR\nAbra o Minecraft novamente. Se ainda fechar, volte e execute VERIFICAR CRASH; o novo log permite uma segunda rodada mais específica.");
        out.append("\n\nDESFAZER\nA opção DESFAZER ÚLTIMA restaura arquivos, preferências e a versão do perfil desta rodada.");
        return out.toString();
    }

    private String installDependencyRecursive(String dep,String mc,String loader,File dir,Set<String> seen,List<String> created)throws Exception{
        String key=dep.toLowerCase(Locale.ROOT);
        if(!seen.add(key))return null;
        JSONObject project=findExactProject(dep,mc,loader);
        if(project==null)return null;
        String slug=project.optString("slug",project.optString("id",""));
        if(slug.isEmpty())return null;
        JSONArray versions=listVersions(slug,mc,loader);
        JSONObject v=chooseStable(versions);
        if(v==null)return null;

        JSONArray ds=v.optJSONArray("dependencies");
        if(ds!=null)for(int i=0;i<ds.length();i++){
            JSONObject d=ds.optJSONObject(i);
            if(d==null || !"required".equalsIgnoreCase(d.optString("dependency_type","required")))continue;
            String did=d.optString("project_id","");
            String dvid=d.optString("version_id","");
            if(!did.isEmpty() && !isInstalledDependency(did,scanMods(new File(dir,"mods")))){
                if(!dvid.isEmpty())installVersionById(dvid,dir,created,seen,mc,loader);
                else installDependencyRecursive(did,mc,loader,dir,seen,created);
            }
        }
        return installVersion(v,dir,created);
    }

    private void installVersionById(String id,File dir,List<String> created,Set<String> seen,String mc,String loader)throws Exception{
        if(!seen.add("version:"+id))return;
        JSONObject v=getJson("https://api.modrinth.com/v2/version/"+URLEncoder.encode(id,"UTF-8"));
        JSONArray ds=v.optJSONArray("dependencies");
        if(ds!=null)for(int i=0;i<ds.length();i++){
            JSONObject d=ds.optJSONObject(i);
            if(d!=null && "required".equalsIgnoreCase(d.optString("dependency_type","required"))){
                String did=d.optString("project_id","");
                String dvid=d.optString("version_id","");
                if(!did.isEmpty()){
                    if(!dvid.isEmpty())installVersionById(dvid,dir,created,seen,mc,loader);
                    else installDependencyRecursive(did,mc,loader,dir,seen,created);
                }
            }
        }
        installVersion(v,dir,created);
    }

    private String installVersion(JSONObject version,File dir,List<String> created)throws Exception{
        JSONArray files=version.optJSONArray("files");
        if(files==null)return null;
        JSONObject chosen=null;
        for(int i=0;i<files.length();i++){
            JSONObject f=files.optJSONObject(i);
            if(f!=null && f.optString("filename","").toLowerCase(Locale.ROOT).endsWith(".jar")){chosen=f;break;}
        }
        if(chosen==null)return null;
        String url=chosen.optString("url","");
        String name=chosen.optString("filename","mod.jar");
        if(url.isEmpty())return null;
        File mods=new File(dir,"mods");if(!mods.exists()&&!mods.mkdirs())return null;
        File out=new File(mods,safeName(name));
        if(out.exists())return null;
        download(url,out);
        created.add(out.getAbsolutePath());
        return out.getName();
    }

    private String updateExactMod(String suspect,String mc,String loader,File dir,File session,List<String> moved,List<String> created)throws Exception{
        File old=new File(new File(dir,"mods"),suspect);
        if(!old.exists())return null;
        String base=baseName(suspect);
        JSONObject project=findExactProject(base,mc,loader);
        if(project==null)return null;
        String slug=project.optString("slug",project.optString("id",""));
        if(slug.isEmpty())return null;
        JSONArray versions=listVersions(slug,mc,loader);
        JSONObject v=chooseStable(versions);
        if(v==null)return null;
        String newName=installVersion(v,dir,created);
        if(newName==null)return null;
        File newFile=new File(new File(dir,"mods"),newName);
        if(old.getAbsolutePath().equals(newFile.getAbsolutePath()))return null;
        File q=new File(session,"updated_old_mods");q.mkdirs();
        File movedOld=new File(q,old.getName());
        if(old.renameTo(movedOld)){
            moved.add(movedOld.getAbsolutePath()+"|"+old.getAbsolutePath());
            return newName;
        }
        newFile.delete();
        created.remove(newFile.getAbsolutePath());
        return null;
    }

    private JSONObject findExactProject(String query,String mc,String loader)throws Exception{
        String q=query.toLowerCase(Locale.ROOT).trim();
        if(q.endsWith(".jar"))q=q.substring(0,q.length()-4);
        q=q.replaceAll("[_ ]+","-").replaceAll("-\\d.*$","");
        if(q.length()<3)return null;
        String url="https://api.modrinth.com/v2/search?limit=8&query="+URLEncoder.encode(q,"UTF-8")+
                "&facets="+URLEncoder.encode("[[\"project_type:mod\"],[\"versions:"+mc+"\"]]","UTF-8");
        if(loader!=null&&!loader.equalsIgnoreCase("Vanilla")&&!loader.equalsIgnoreCase("unknown"))
            url+="&index=relevance";
        JSONArray hits=getJson(url).optJSONArray("hits");
        if(hits==null||hits.length()==0)return null;
        String wanted=slugNorm(q);
        JSONObject only=null;
        int strong=0;
        for(int i=0;i<hits.length();i++){
            JSONObject h=hits.optJSONObject(i);if(h==null)continue;
            String slug=slugNorm(h.optString("slug",""));
            String title=slugNorm(h.optString("title",""));
            if(slug.equals(wanted)){return h;}
            if(title.equals(wanted)){strong++;only=h;}
            if(slug.contains(wanted)||wanted.contains(slug)){strong++;only=h;}
        }
        return strong==1?only:null;
    }

    private JSONArray listVersions(String project,String mc,String loader)throws Exception{
        String u="https://api.modrinth.com/v2/project/"+URLEncoder.encode(project,"UTF-8")+"/version?game_versions="+
                URLEncoder.encode("[\""+mc+"\"]","UTF-8")+"&include_changelog=false";
        if(loader!=null&&!loader.equalsIgnoreCase("Vanilla")&&!loader.equalsIgnoreCase("unknown")){
            u+="&loaders="+URLEncoder.encode("[\""+loader.toLowerCase(Locale.ROOT)+"\"]","UTF-8");
        }
        return new JSONArray(getRaw(u));
    }

    private JSONObject chooseStable(JSONArray a){
        for(int i=0;i<a.length();i++){
            JSONObject v=a.optJSONObject(i);
            if(v==null||!"release".equalsIgnoreCase(v.optString("version_type","")))continue;
            JSONArray fs=v.optJSONArray("files");
            if(findJar(fs)!=null)return v;
        }
        return null;
    }

    private JSONObject findJar(JSONArray fs){
        if(fs==null)return null;
        for(int i=0;i<fs.length();i++){
            JSONObject f=fs.optJSONObject(i);
            if(f!=null&&f.optString("filename","").toLowerCase(Locale.ROOT).endsWith(".jar"))return f;
        }
        return null;
    }

    private void download(String url,File out)throws Exception{
        HttpURLConnection c=(HttpURLConnection)new URL(url).openConnection();
        c.setRequestProperty("User-Agent","Mikael-Launcher-V3/AutoResolver-PRO");
        c.setConnectTimeout(15000);c.setReadTimeout(90000);
        int code=c.getResponseCode();
        if(code>=400)throw new Exception("Download HTTP "+code);
        try(InputStream in=c.getInputStream();FileOutputStream o=new FileOutputStream(out)){
            byte[] b=new byte[16384];int n;while((n=in.read(b))!=-1)o.write(b,0,n);
        }
        if(out.length()<1024)throw new Exception("Arquivo baixado parece inválido: "+out.getName());
        if(!isReadableJar(out)){out.delete();throw new Exception("JAR baixado inválido: "+out.getName());}
    }

    private List<ModInfo> scanMods(File dir){
        List<ModInfo> out=new ArrayList<>();
        File[] fs=dir==null?null:dir.listFiles();
        if(fs==null)return out;
        for(File f:fs){
            if(!f.isFile()||!f.getName().toLowerCase(Locale.ROOT).endsWith(".jar"))continue;
            ModInfo m=parseMod(f);
            out.add(m);
        }
        return out;
    }

    private ModInfo parseMod(File f){
        ModInfo m=new ModInfo();m.file=f;
        try(ZipFile z=new ZipFile(f)){
            ZipEntry e=z.getEntry("fabric.mod.json");
            if(e!=null){
                JSONObject j=new JSONObject(readEntry(z,e));
                m.id=j.optString("id","");m.name=j.optString("name",m.id);m.version=j.optString("version","");
                m.loader="Fabric";return m;
            }
            e=z.getEntry("quilt.mod.json");
            if(e!=null){
                JSONObject root=new JSONObject(readEntry(z,e));
                JSONObject q=root.optJSONObject("quilt_loader");
                if(q!=null){m.id=q.optString("id","");m.name=q.optString("name",m.id);m.version=q.optString("version","");}
                m.loader="Quilt";return m;
            }
            e=z.getEntry("META-INF/neoforge.mods.toml");
            if(e==null)e=z.getEntry("META-INF/mods.toml");
            if(e!=null){
                String t=readEntry(z,e);
                m.id=tomlValue(t,"modId");m.name=tomlValue(t,"displayName");
                if(m.name.isEmpty())m.name=tomlValue(t,"display_name");
                m.version=tomlValue(t,"version");
                m.loader=e.getName().contains("neoforge")?"NeoForge":"Forge";return m;
            }
        }catch(Exception e){m.loader="invalid";}
        return m;
    }

    private String tomlValue(String t,String key){
        Matcher m=Pattern.compile("(?m)^[\\s]*"+Pattern.quote(key)+"[\\s]*=[\\s]*[\"']([^\"']+)[\"']").matcher(t);
        return m.find()?m.group(1).trim():"";
    }

    private String readEntry(ZipFile z,ZipEntry e)throws Exception{
        try(InputStream in=z.getInputStream(e);InputStreamReader r=new InputStreamReader(in,StandardCharsets.UTF_8);
            BufferedReader b=new BufferedReader(r)){
            StringBuilder s=new StringBuilder();String line;while((line=b.readLine())!=null)s.append(line).append('\n');return s.toString();
        }
    }

    private boolean isReadableJar(File f){
        if(f==null||!f.exists()||f.length()<1024)return false;
        try(ZipFile z=new ZipFile(f)){
            return z.entries().hasMoreElements();
        }catch(Exception e){return false;}
    }

    private boolean isInstalledDependency(String dep,List<ModInfo> mods){
        String q=slugNorm(dep);
        for(ModInfo m:mods){
            if(q.equals(slugNorm(m.id))||q.equals(slugNorm(m.name))||q.equals(slugNorm(baseName(m.file.getName()))))return true;
            if(!q.isEmpty()&&(slugNorm(m.file.getName()).contains(q)||q.contains(slugNorm(m.file.getName()))))return true;
        }
        return false;
    }

    private boolean looksLikeProjectId(String x){
        if(x==null)return false;
        String q=x.toLowerCase(Locale.ROOT);
        if(q.length()<3||q.length()>60)return false;
        return !q.equals("minecraft")&&!q.equals("java")&&!q.equals("forge")&&!q.equals("fabric")&&
                !q.equals("version")&&!q.equals("required")&&!q.equals("dependency")&&!q.equals("mod");
    }

    private String findSuspectJar(String text,File dir,List<ModInfo> mods){
        Matcher m=JAR.matcher(text);
        while(m.find()){
            String n=m.group(1).trim();
            File f=findModFile(new File(dir,"mods"),n);
            if(f!=null)return f.getName();
        }
        // Correlate the class/mod name against actual metadata.
        String l=text.toLowerCase(Locale.ROOT);
        for(ModInfo mi:mods){
            String id=mi.id.toLowerCase(Locale.ROOT),name=mi.name.toLowerCase(Locale.ROOT);
            if(!id.isEmpty()&&(l.contains("mod "+id)||l.contains("["+id+"]")||l.contains(id+".jar")))return mi.file.getName();
            if(!name.isEmpty()&&name.length()>3&&l.contains(name))return mi.file.getName();
        }
        return null;
    }

    private File findModFile(File mods,String n){
        if(n==null||mods==null)return null;
        File exact=new File(mods,n);if(exact.exists())return exact;
        String q=n.toLowerCase(Locale.ROOT);
        File[] fs=mods.listFiles();
        if(fs==null)return null;
        for(File f:fs)if(f.getName().toLowerCase(Locale.ROOT).equals(q))return f;
        return null;
    }

    private boolean shouldQuarantine(String l){
        return hasAny(l,"mixinapplyerror","modresolutionexception","could not find required mod","nosuchmethoderror","noclassdeffounderror",
                "classnotfoundexception","invalid injection","injectionpoint","mod loading has failed","mod loading error","incompatible mod");
    }

    private boolean quarantine(File src,File session,String folder,String name,List<String> moved){
        try{
            File q=new File(session,folder);if(!q.exists()&&!q.mkdirs())return false;
            File dest=new File(q,safeName(name));
            if(!src.renameTo(dest))return false;
            moved.add(dest.getAbsolutePath()+"|"+src.getAbsolutePath());
            return true;
        }catch(Exception e){return false;}
    }

    private void backupOptionFile(File dir,File session,String name,List<String> moved,List<Action> actions){
        File src=new File(dir,name);if(!src.exists())return;
        File backupDir=new File(session,"options_backup");if(!backupDir.exists())backupDir.mkdirs();
        File dest=new File(backupDir,name);
        if(src.renameTo(dest)){
            moved.add(dest.getAbsolutePath()+"|"+src.getAbsolutePath());
            actions.add(new Action("CONFIG: "+name+" preservado em backup e resetado pelo Minecraft",false));
        }
    }

    private int cleanTemps(File dir){
        int count=0;
        count+=cleanTempsRecursive(dir,3);
        return count;
    }

    private int cleanTempsRecursive(File d,int depth){
        if(d==null||!d.exists()||depth<0)return 0;
        int c=0;
        File[] fs=d.listFiles();if(fs==null)return 0;
        for(File f:fs){
            if(f.isDirectory())c+=cleanTempsRecursive(f,depth-1);
            else{
                String n=f.getName().toLowerCase(Locale.ROOT);
                if(n.endsWith(".part")||n.endsWith(".download")||n.endsWith(".tmp"))if(f.delete())c++;
            }
        }
        return c;
    }

    private LoaderStats loaderStats(List<ModInfo> mods){
        LoaderStats s=new LoaderStats();
        for(ModInfo m:mods){
            if(m.loader.equals("Fabric")){s.fabric++;s.maxLoader="Fabric";}
            else if(m.loader.equals("Forge")){s.forge++;s.maxLoader="Forge";}
            else if(m.loader.equals("NeoForge")){s.neoforge++;s.maxLoader="NeoForge";}
            else if(m.loader.equals("Quilt")){s.quilt++;s.maxLoader="Quilt";}
        }
        int[] a={s.fabric,s.forge,s.neoforge,s.quilt};
        String[] n={"Fabric","Forge","NeoForge","Quilt"};
        s.maxCount=0;
        for(int i=0;i<a.length;i++)if(a[i]>s.maxCount){s.maxCount=a[i];s.maxLoader=n[i];}
        return s;
    }

    private String bestLoader(LoaderStats s,String current){
        if(s.maxCount<2)return null;
        return s.maxLoader;
    }

    private String findInstalledVersionForLoader(File versions,String mc,String loader){
        File[] fs=versions.listFiles();if(fs==null)return null;
        String want=loader.toLowerCase(Locale.ROOT);
        String game=mc.toLowerCase(Locale.ROOT);
        String best=null;
        for(File f:fs){
            if(!f.isDirectory())continue;
            String n=f.getName().toLowerCase(Locale.ROOT);
            if(!n.contains(game))continue;
            boolean ok=(want.equals("forge")&&n.contains("forge"))||
                    (want.equals("fabric")&&n.contains("fabric"))||
                    (want.equals("quilt")&&n.contains("quilt"))||
                    (want.equals("neoforge")&&n.contains("neoforge"));
            if(ok){best=f.getName();if(n.contains("stable"))break;}
        }
        return best;
    }

    private String currentLoader(MinecraftProfile p,String t){
        if(p!=null&&p.lastVersionId!=null){
            String v=p.lastVersionId.toLowerCase(Locale.ROOT);
            if(v.contains("neoforge"))return "NeoForge";
            if(v.contains("forge"))return "Forge";
            if(v.contains("fabric"))return "Fabric";
            if(v.contains("quilt"))return "Quilt";
        }
        String l=t.toLowerCase(Locale.ROOT);
        if(l.contains("net.neoforged")||l.contains("neoforge"))return "NeoForge";
        if(l.contains("net.minecraftforge")||l.contains("modlauncher"))return "Forge";
        if(l.contains("net.fabricmc")||l.contains("fabricloader"))return "Fabric";
        if(l.contains("quilt"))return "Quilt";
        return "Vanilla";
    }

    private String normalizeMc(String version){
        if(version==null)return null;
        Matcher m=Pattern.compile("(\\d+\\.\\d+(?:\\.\\d+)?)").matcher(version);
        return m.find()?m.group(1):null;
    }

    private Set<String> extractDependencies(String t){
        Set<String> out=new LinkedHashSet<>();
        Matcher m=DEP.matcher(t);
        while(m.find()&&out.size()<12){
            String x=m.group(1).trim();
            if(x.contains(":"))x=x.substring(x.lastIndexOf(':')+1);
            x=x.replaceAll("[\"']","");
            if(looksLikeProjectId(x))out.add(x);
        }
        return out;
    }

    private int requiredJava(String t){
        Matcher m=JAVA_CLASS.matcher(t);int best=-1;
        while(m.find())try{best=Math.max(best,Integer.parseInt(m.group(1)));}catch(Exception ignored){}
        if(best<0)return -1;
        if(best>=69)return 25;
        if(best>=65)return 21;
        if(best>=61)return 17;
        if(best>=52)return 8;
        return -1;
    }

    private int safeRamTarget(RuntimeInfo r,String log){
        int total=(int)Math.min(Integer.MAX_VALUE,r.total);
        int current=r.allocated;
        int maxSafe=Math.max(512,Math.min(4096,total-1024));
        int target=current;
        if(current<=0)target=Math.min(maxSafe,1024);
        if(r.available>0&&r.available<700)target=Math.min(target>0?target:maxSafe,Math.max(512,(int)r.available-256));
        if(target>maxSafe)target=maxSafe;
        if(target>=current && r.available<900)target=Math.max(512,current-256);
        if(target<512)target=512;
        return target;
    }

    private RuntimeInfo runtimeInfo(){
        RuntimeInfo r=new RuntimeInfo();
        Context c=getContext();
        if(c!=null){
            ActivityManager am=(ActivityManager)c.getSystemService(Context.ACTIVITY_SERVICE);
            if(am!=null){ActivityManager.MemoryInfo i=new ActivityManager.MemoryInfo();am.getMemoryInfo(i);r.available=i.availMem/(1024L*1024L);r.total=i.totalMem/(1024L*1024L);}
        }
        r.allocated=LauncherPreferences.DEFAULT_PREF.getInt("allocation",0);
        return r;
    }

    private StorageInfo storageInfo(File dir,int modCount){
        StorageInfo s=new StorageInfo();s.mods=modCount;
        try{StatFs f=new StatFs(dir.getAbsolutePath());s.free=f.getAvailableBytes()/(1024L*1024L);}catch(Exception ignored){}
        return s;
    }

    private File findNewestLog(File dir){
        List<File> all=new ArrayList<>();
        addIf(all,new File(dir,"latestlog.txt"));addIf(all,new File(dir,"logs/latest.log"));addIf(all,new File(dir,"debug.log"));
        collect(new File(dir,"crash-reports"),all,3);collect(new File(dir,"logs"),all,2);
        File best=null;for(File f:all)if(best==null||f.lastModified()>best.lastModified())best=f;
        return best;
    }

    private void addIf(List<File> a,File f){if(f.exists()&&f.isFile())a.add(f);}
    private void collect(File d,List<File> a,int depth){
        if(d==null||!d.exists()||depth<0)return;
        File[] fs=d.listFiles();if(fs==null)return;
        for(File f:fs)if(f.isDirectory())collect(f,a,depth-1);else if(f.getName().endsWith(".log")||f.getName().endsWith(".txt"))a.add(f);
    }

    private String readTail(File f,int max)throws Exception{
        long skip=Math.max(0,f.length()-max);
        try(FileInputStream in=new FileInputStream(f)){
            while(skip>0){long n=in.skip(skip);if(n<=0)break;skip-=n;}
            BufferedReader b=new BufferedReader(new InputStreamReader(in,StandardCharsets.UTF_8));
            StringBuilder s=new StringBuilder();char[] c=new char[16384];int n;while((n=b.read(c))!=-1)s.append(c,0,n);return s.toString();
        }
    }

    private String match(Pattern p,String t){Matcher m=p.matcher(t);return m.find()?m.group(1):null;}
    private boolean hasAny(String s,String...v){for(String x:v)if(s.contains(x))return true;return false;}
    private String baseName(String s){String n=s.replaceFirst("(?i)\\.jar$","");return n.replaceAll("[-_ ]+\\d.*$","");}
    private String slugNorm(String s){return s==null?"":s.toLowerCase(Locale.ROOT).replaceAll("[-_ ]+","-").replaceAll("[^a-z0-9-]","");}
    private String safeName(String s){return s.replaceAll("[\\\\/:*?\"<>|]","_");}
    private String nullSafe(String s){return s==null?"indeterminado":s;}

    private void saveText(File dir,String name,String text)throws Exception{try(FileWriter w=new FileWriter(new File(dir,name))){w.write(text==null?"":text);}}
    private void savePref(File dir,String key,String value)throws Exception{File f=new File(dir,"prefs.bak");try(FileWriter w=new FileWriter(f,true)){w.write(key+"="+value.replace("\\","\\\\").replace("\n","\\n")+"\n");}}
    private void backupProfile(File dir,String old)throws Exception{saveText(dir,"profile.bak","lastVersionId="+nullSafe(old)+"\n");}

    private String actionText(List<Action> a){StringBuilder b=new StringBuilder();for(Action x:a)b.append(x.text).append('\n');return b.toString();}

    private void writeRestoreMap(File dir,List<String> entries)throws Exception{saveText(dir,"restore.map",join(entries));}
    private void writeCreatedMap(File dir,List<String> entries)throws Exception{saveText(dir,"created.map",join(entries));}
    private String join(List<String> a){StringBuilder b=new StringBuilder();for(String x:a)b.append(x).append('\n');return b.toString();}

    private void undoLast(){
        new Thread(()->{
            String msg;
            try{
                File dir=getCurrentProfileDirectory(),root=new File(dir,".mikael_backups");
                File[] ss=root.listFiles(File::isDirectory);
                if(ss==null||ss.length==0)throw new Exception("Nenhuma rodada de reparo encontrada.");
                File best=ss[0];for(File f:ss)if(f.lastModified()>best.lastModified())best=f;

                File created=new File(best,"created.map");
                if(created.exists())try(BufferedReader b=new BufferedReader(new InputStreamReader(new FileInputStream(created),StandardCharsets.UTF_8))){
                    String p;while((p=b.readLine())!=null){File f=new File(p.trim());if(f.exists())f.delete();}
                }

                File map=new File(best,"restore.map");
                if(map.exists())try(BufferedReader b=new BufferedReader(new InputStreamReader(new FileInputStream(map),StandardCharsets.UTF_8))){
                    String x;while((x=b.readLine())!=null){int i=x.indexOf('|');if(i<0)continue;File from=new File(x.substring(0,i)),to=new File(x.substring(i+1));if(from.exists()){File parent=to.getParentFile();if(parent!=null)parent.mkdirs();from.renameTo(to);}}
                }

                File pb=new File(best,"profile.bak");
                if(pb.exists()){
                    String old=readKey(pb,"lastVersionId");
                    if(old!=null){LauncherProfiles.load();MinecraftProfile p=LauncherProfiles.getCurrentProfile();if(!"indeterminado".equals(old)){p.lastVersionId=old;LauncherProfiles.write();}}
                }

                File pref=new File(best,"prefs.bak");
                if(pref.exists())restorePrefs(pref);
                LauncherPreferences.loadPreferences(getContext());
                msg="Última rodada desfeita: "+best.getName();
            }catch(Exception e){msg="Falha ao desfazer: "+e.getMessage();}
            final String out=msg;Activity a=getActivity();if(a!=null)a.runOnUiThread(()->{if(isAdded()){status.setText("DESFAZER CONCLUÍDO");result.setText(out);}});
        }).start();
    }

    private String readKey(File f,String key)throws Exception{
        try(BufferedReader b=new BufferedReader(new InputStreamReader(new FileInputStream(f),StandardCharsets.UTF_8))){
            String x;while((x=b.readLine())!=null)if(x.startsWith(key+"="))return x.substring(key.length()+1);
        }
        return null;
    }

    private void restorePrefs(File f)throws Exception{
        SharedPreferences.Editor e=LauncherPreferences.DEFAULT_PREF.edit();
        try(BufferedReader b=new BufferedReader(new InputStreamReader(new FileInputStream(f),StandardCharsets.UTF_8))){
            String x;while((x=b.readLine())!=null){
                int i=x.indexOf('=');if(i<1)continue;
                String k=x.substring(0,i),v=x.substring(i+1).replace("\\n","\n").replace("\\\\","\\");
                if("allocation".equals(k))e.putInt(k,Integer.parseInt(v));
                else if("force_vsync".equals(k)||"alternate_surface".equals(k)||"dump_shaders".equals(k)||"disable_autojre_select".equals(k))e.putBoolean(k,Boolean.parseBoolean(v));
                else e.putString(k,v);
            }
        }
        e.apply();
    }

    private void saveTextUnchecked(File d,String n,String x){}
    private int getInt(int x){return x;}
    private void deleteTree(File f){
        File[] a=f.listFiles();if(a!=null)for(File x:a){if(x.isDirectory())deleteTree(x);else x.delete();}f.delete();
    }

    private static final class RuntimeInfo{long available,total;int allocated;}
    private static final class StorageInfo{long free;int mods;}
    private static final class LoaderStats{
        int fabric,forge,neoforge,quilt,maxCount;String maxLoader="";
    }

    private JSONObject getJson(String u)throws Exception{return new JSONObject(getRaw(u));}
    private String getRaw(String u)throws Exception{
        HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();
        c.setRequestProperty("Accept","application/json");
        c.setRequestProperty("User-Agent","Mikael-Launcher-V3/AutoResolver-PRO");
        c.setConnectTimeout(15000);c.setReadTimeout(30000);
        int code=c.getResponseCode();
        InputStream in=code>=400?c.getErrorStream():c.getInputStream();
        java.io.ByteArrayOutputStream o=new java.io.ByteArrayOutputStream();
        if(in!=null){byte[] b=new byte[16384];int n;while((n=in.read(b))!=-1)o.write(b,0,n);}
        if(code>=400)throw new Exception("HTTP "+code);
        return o.toString("UTF-8");
    }
    private File getCurrentProfileDirectory(){
        String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
        if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);
        try{LauncherProfiles.load();MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);}
        catch(Exception e){return new File(Tools.DIR_GAME_NEW);}
    }
}
