package net.kdt.pojavlaunch.fragments;

import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;
import net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles;
import net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class MikaelModLibraryFragment extends Fragment {
    public static final String TAG="MIKAEL_MOD_LIBRARY";
    private final List<ModItem> mods=new ArrayList<>();
    private ArrayAdapter<String> adapter;
    private TextView status;
    private EditText search;

    public MikaelModLibraryFragment(){super(R.layout.fragment_mikael_mod_library);}

    @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
        search=v.findViewById(R.id.mod_search);
        status=v.findViewById(R.id.mod_status);
        ListView list=v.findViewById(R.id.mod_list);
        adapter=new ArrayAdapter<>(requireContext(),android.R.layout.simple_list_item_1,new ArrayList<>());
        list.setAdapter(adapter);
        v.findViewById(R.id.mod_search_button).setOnClickListener(x->searchMods());
        v.findViewById(R.id.mod_back).setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
        list.setOnItemClickListener((p,x,pos,id)->confirmInstall(mods.get(pos)));
        searchMods();
    }

    private String detectMinecraftVersion(){
        try{
            String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
            if(cur==null||cur.trim().isEmpty()) return null;
            LauncherProfiles.load();
            MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);
            if(p==null) return null;
            String[] names={"lastVersionId","versionId","version","versionName","gameVersion"};
            for(String n:names){
                try{
                    Field f=p.getClass().getDeclaredField(n); f.setAccessible(true);
                    Object value=f.get(p);
                    if(value!=null && value.toString().matches("[0-9]+\\.[0-9]+([.][0-9]+)?"))
                        return value.toString();
                }catch(Exception ignored){}
                try{
                    String mn="get"+Character.toUpperCase(n.charAt(0))+n.substring(1);
                    Method m=p.getClass().getMethod(mn); Object value=m.invoke(p);
                    if(value!=null && value.toString().matches("[0-9]+\\.[0-9]+([.][0-9]+)?"))
                        return value.toString();
                }catch(Exception ignored){}
            }
        }catch(Exception ignored){}
        return null;
    }

    private void searchMods(){
        String q=search.getText().toString().trim();
        String mc=detectMinecraftVersion();
        status.setText(mc==null?"Pesquisando mods...":"Pesquisando mods para Minecraft "+mc+"...");
        new Thread(()->{
            try{
                String facets;
                if(mc!=null && !mc.isEmpty())
                    facets="[[\"project_type:mod\"],[\"versions:"+mc+"\"]]";
                else
                    facets="[[\"project_type:mod\"]]";
                String u="https://api.modrinth.com/v2/search?limit=20&facets="+URLEncoder.encode(facets,"UTF-8");
                if(!q.isEmpty()) u+="&query="+URLEncoder.encode(q,"UTF-8");
                JSONObject json=getPublic(u);
                JSONArray hits=json.optJSONArray("hits");
                List<ModItem> found=new ArrayList<>();
                if(hits!=null) for(int i=0;i<hits.length();i++){
                    JSONObject h=hits.getJSONObject(i);
                    found.add(new ModItem(h.optString("project_id"),h.optString("title","Mod"),h.optString("description",""),"",h.optString("project_id")));
                }
                android.app.Activity a=getActivity(); if(a==null)return;
                a.runOnUiThread(()->{
                    if(!isAdded()) return;
                    mods.clear(); mods.addAll(found); adapter.clear();
                    for(ModItem m:mods) adapter.add(m.name);
                    adapter.notifyDataSetChanged();
                    status.setText(found.size()+" mods encontrados"+(mc==null?"":" • Minecraft "+mc));
                });
            }catch(Exception e){
                android.app.Activity a=getActivity(); if(a!=null)a.runOnUiThread(()->{if(isAdded())status.setText("Erro ao buscar: "+e.getMessage());});
            }
        }).start();
    }

    private void confirmInstall(ModItem m){
        new AlertDialog.Builder(requireContext()).setTitle(m.name)
                .setMessage(m.summary+"

Minecraft: "+(detectMinecraftVersion()==null?"automático":detectMinecraftVersion())+"
Dependências obrigatórias: automáticas")
                .setNegativeButton("CANCELAR",null)
                .setPositiveButton("INSTALAR", (d,w)->installProject(m.modId))
                .show();
    }

    private void installProject(String projectId){
        String mc=detectMinecraftVersion();
        if(mc==null || mc.isEmpty()){status.setText("Não foi possível detectar a versão do Minecraft.");return;}
        status.setText("Preparando "+mc+"...");
        new Thread(()->{
            try{
                installRecursive(projectId,mc,new HashSet<String>(),true);
                android.app.Activity a=getActivity(); if(a!=null)a.runOnUiThread(()->{if(isAdded())status.setText("Mod e dependências instalados para Minecraft "+mc+".");});
            }catch(Exception e){
                android.app.Activity a=getActivity(); if(a!=null)a.runOnUiThread(()->{if(isAdded())status.setText("Falha: "+e.getMessage());});
            }
        }).start();
    }

    private void installRecursive(String projectId,String mc,Set<String> seen,boolean root)throws Exception{
        if(projectId==null||projectId.isEmpty()||seen.contains(projectId))return;
        seen.add(projectId);
        JSONArray versions=getPublic("https://api.modrinth.com/v2/project/"+URLEncoder.encode(projectId,"UTF-8")+"/version?game_versions="+URLEncoder.encode("[\""+mc+"\"]","UTF-8")).optJSONArray("");
        if(versions==null){
            JSONArray arr=new JSONArray(getRawPublic("https://api.modrinth.com/v2/project/"+URLEncoder.encode(projectId,"UTF-8")+"/version?game_versions="+URLEncoder.encode("[\""+mc+"\"]","UTF-8")));
            versions=arr;
        }
        if(versions.length()==0) throw new Exception("Sem versão compatível para "+projectId+" ("+mc+").");
        JSONObject version=chooseStableVersion(versions);
        JSONArray deps=version.optJSONArray("dependencies");
        if(deps!=null) for(int i=0;i<deps.length();i++){
            JSONObject dep=deps.getJSONObject(i);
            if("required".equalsIgnoreCase(dep.optString("dependency_type","required"))){
                String did=dep.optString("project_id","");
                String dvid=dep.optString("version_id","");
                if(!did.isEmpty()){
                    if(!dvid.isEmpty()){
                        installVersion(dvid,mc,seen,false);
                    }else{
                        installRecursive(did,mc,seen,false);
                    }
                }
            }
        }
        installVersionObject(version,mc);
    }

    private void installVersion(String versionId,String mc,Set<String> seen,boolean root)throws Exception{
        JSONObject version=getPublic("https://api.modrinth.com/v2/version/"+URLEncoder.encode(versionId,"UTF-8"));
        JSONArray deps=version.optJSONArray("dependencies");
        if(deps!=null) for(int i=0;i<deps.length();i++){
            JSONObject dep=deps.getJSONObject(i);
            if("required".equalsIgnoreCase(dep.optString("dependency_type","required"))){
                String did=dep.optString("project_id","");
                String dvid=dep.optString("version_id","");
                if(!did.isEmpty()){
                    if(!dvid.isEmpty()) installVersion(dvid,mc,seen,false);
                    else installRecursive(did,mc,seen,false);
                }
            }
        }
        installVersionObject(version,mc);
    }

    private JSONObject chooseStableVersion(JSONArray versions)throws Exception{
        for(int i=0;i<versions.length();i++){
            JSONObject v=versions.getJSONObject(i);
            String type=v.optString("version_type","release");
            if("release".equalsIgnoreCase(type) && jarFile(v)!=null) return v;
        }
        for(int i=0;i<versions.length();i++){
            JSONObject v=versions.getJSONObject(i);
            if(jarFile(v)!=null) return v;
        }
        throw new Exception("Nenhum arquivo .jar compatível foi encontrado.");
    }

    private String jarFile(JSONObject version){
        JSONArray files=version.optJSONArray("files");
        if(files==null) return null;
        for(int i=0;i<files.length();i++){
            JSONObject f=files.optJSONObject(i);
            if(f!=null){
                String fn=f.optString("filename","");
                if(fn.toLowerCase().endsWith(".jar") && !f.optBoolean("primary",false)) return fn;
            }
        }
        for(int i=0;i<files.length();i++){
            JSONObject f=files.optJSONObject(i);
            if(f!=null && f.optString("filename","").toLowerCase().endsWith(".jar")) return f.optString("filename","");
        }
        return null;
    }

    private void installVersionObject(JSONObject version,String mc)throws Exception{
        JSONArray files=version.optJSONArray("files");
        if(files==null||files.length()==0)throw new Exception("Arquivo da versão indisponível.");
        JSONObject selected=null;
        for(int i=0;i<files.length();i++){
            JSONObject f=files.optJSONObject(i);
            if(f!=null && f.optString("filename","").toLowerCase().endsWith(".jar")) {selected=f;break;}
        }
        if(selected==null)throw new Exception("Arquivo .jar indisponível.");
        String url=selected.optString("url","");
        String name=selected.optString("filename","mod.jar");
        if(url.isEmpty())throw new Exception("URL de download indisponível.");
        File dir=new File(getCurrentProfileDirectory(),"mods");
        if(!dir.exists()&&!dir.mkdirs())throw new Exception("Não foi possível criar mods/.");
        File out=new File(dir,name.replaceAll("[\\\\/:*?\"<>|]","_"));
        HttpURLConnection c=(HttpURLConnection)new URL(url).openConnection();
        c.setRequestProperty("User-Agent","Mikael-Launcher-V3/1.0.0 (https://github.com/mikael8367/Mikael-launcher-V3)");
        c.setConnectTimeout(15000);c.setReadTimeout(60000);
        try(InputStream in=c.getInputStream();FileOutputStream o=new FileOutputStream(out)){
            byte[] b=new byte[8192];int n;while((n=in.read(b))!=-1)o.write(b,0,n);
        }
    }

    private JSONObject getPublic(String u)throws Exception{
        return new JSONObject(getRawPublic(u));
    }

    private String getRawPublic(String u)throws Exception{
        HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();
        c.setRequestMethod("GET");
        c.setRequestProperty("Accept","application/json");
        c.setRequestProperty("User-Agent","Mikael-Launcher-V3/1.0.0 (https://github.com/mikael8367/Mikael-launcher-V3)");
        c.setConnectTimeout(15000);c.setReadTimeout(30000);
        int code=c.getResponseCode();
        InputStream in=code>=400?c.getErrorStream():c.getInputStream();
        java.io.ByteArrayOutputStream o=new java.io.ByteArrayOutputStream();
        if(in!=null){byte[] b=new byte[8192];int n;while((n=in.read(b))!=-1)o.write(b,0,n);}
        if(code>=400)throw new Exception("HTTP "+code);
        return o.toString("UTF-8");
    }

    private File getCurrentProfileDirectory(){
        String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
        if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);
        LauncherProfiles.load(); MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);
        return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);
    }

    static class ModItem{String modId,name,summary,fileId,fileName;ModItem(String a,String b,String c,String d,String e){modId=a;name=b;summary=c;fileId=d;fileName=e;}}
}
