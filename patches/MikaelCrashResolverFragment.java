package net.kdt.pojavlaunch.fragments;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

public class MikaelCrashResolverFragment extends Fragment {
    public static final String TAG="MIKAEL_CRASH_RESOLVER";
    public MikaelCrashResolverFragment(){super(R.layout.fragment_mikael_crash_resolver);}
    @Override public void onViewCreated(@NonNull View v,@Nullable Bundle state){
        TextView status=v.findViewById(R.id.resolve_status), result=v.findViewById(R.id.resolve_result);
        Button resolve=v.findViewById(R.id.resolve_button), undo=v.findViewById(R.id.resolve_undo), back=v.findViewById(R.id.resolve_back);
        status.setText("RESOLVER AUTOMÁTICO PRONTO");
        result.setText("Diagnóstico e reparos locais reversíveis.\n\n• RAM em OutOfMemory\n• VSync/superfície em falhas gráficas\n• pastas essenciais\n• temporários de download\n• backup antes de alterações");
        resolve.setOnClickListener(x->repair(status,result));
        undo.setOnClickListener(x->undo(status,result));
        back.setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
    }
    private File gameDir(){
        String p=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
        if(p==null||p.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);
        try{
            net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.load();
            net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile m=net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.mainProfileJson.profiles.get(p);
            return m==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(m);
        }catch(Exception e){return new File(Tools.DIR_GAME_NEW);}
    }
    private String readLog(File dir)throws Exception{
        File f=new File(dir,"latestlog.txt"); if(!f.exists())f=new File(dir,"logs/latest.log"); if(!f.exists())return "";
        long skip=Math.max(0,f.length()-180000);
        try(FileInputStream in=new FileInputStream(f)){
            while(skip>0){long n=in.skip(skip);if(n<=0)break;skip-=n;}
            byte[] b=new byte[180000]; int n=in.read(b); return n<=0?"":new String(b,0,n,StandardCharsets.UTF_8);
        }
    }
    private void backup(File dir,String key,String value)throws Exception{
        File b=new File(dir,".mikael_resolver_backup"); if(!b.exists())b.mkdirs();
        try(FileOutputStream out=new FileOutputStream(new File(b,key+".bak"))){out.write(value.getBytes(StandardCharsets.UTF_8));}
    }
    private int cleanTemps(File dir,StringBuilder out){
        int count=0; File[] roots={new File(dir,"libraries"),new File(dir,"versions"),new File(dir,"mods")};
        for(File root:roots){File[] fs=root.listFiles();if(fs==null)continue;for(File f:fs){
            String n=f.getName().toLowerCase(Locale.ROOT);
            if(n.endsWith(".part")||n.endsWith(".tmp")||n.endsWith(".download"))if(f.delete()){out.append("✓ Temporário removido: ").append(f.getName()).append("\n");count++;}
        }} return count;
    }
    private void repair(TextView status,TextView result){
        status.setText("ANALISANDO E REPARANDO...");
        new Thread(()->{
            StringBuilder out=new StringBuilder(); int changes=0;
            try{
                File dir=gameDir();if(!dir.exists())dir.mkdirs();String l=readLog(dir).toLowerCase(Locale.ROOT);
                if(l.contains("outofmemoryerror")||l.contains("java heap space")||l.contains("gc overhead limit exceeded")){
                    int old=LauncherPreferences.DEFAULT_PREF.getInt("allocation",0); ActivityManager am=(ActivityManager)requireContext().getSystemService(Context.ACTIVITY_SERVICE);
                    ActivityManager.MemoryInfo mi=new ActivityManager.MemoryInfo();if(am!=null)am.getMemoryInfo(mi);
                    int available=(int)(mi.availMem/(1024L*1024L)),target=old>0?old:1024;if(available<1024)target=Math.min(target,768);
                    if(target>=512&&target!=old){backup(dir,"allocation",String.valueOf(old));LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation",target).apply();out.append("✓ RAM: ").append(old).append(" MB → ").append(target).append(" MB\n");changes++;}
                }
                if(l.contains("opengl error")||l.contains("egl_bad")||l.contains("glfw error")||l.contains("vulkan error")||l.contains("shader compilation")||l.contains("fatal signal 11")){
                    boolean ov=LauncherPreferences.DEFAULT_PREF.getBoolean("force_vsync",false),os=LauncherPreferences.DEFAULT_PREF.getBoolean("alternate_surface",true);
                    backup(dir,"force_vsync",String.valueOf(ov));backup(dir,"alternate_surface",String.valueOf(os));
                    LauncherPreferences.DEFAULT_PREF.edit().putBoolean("force_vsync",false).putBoolean("alternate_surface",true).apply();
                    out.append("✓ Gráficos: VSync desativado + superfície alternativa ativada\n");changes++;
                }
                if(l.contains("permission denied")||l.contains("no such file")||l.contains("failed to open")){
                    String[] folders={"mods","config","logs","crash-reports","resourcepacks","shaderpacks","saves"};
                    for(String name:folders){File f=new File(dir,name);if(!f.exists()&&f.mkdirs()){out.append("✓ Pasta recriada: ").append(name).append("\n");changes++;}}
                }
                if(l.contains("failed to download")||l.contains("download failed")||l.contains("connection reset")||l.contains("timeout"))changes+=cleanTemps(dir,out);
                if(changes==0)out.append("Nenhuma correção segura foi aplicada.\nUse VERIFICAR CRASH para o diagnóstico detalhado.");
                else out.append("\nBackup criado em: ").append(new File(dir,".mikael_resolver_backup").getAbsolutePath());
            }catch(Exception e){out.append("Resolver interrompido com segurança: ").append(e.getClass().getSimpleName()).append(": ").append(e.getMessage());}
            final String report=out.toString();android.app.Activity a=getActivity();if(a!=null)a.runOnUiThread(()->{if(!isAdded())return;status.setText(report.startsWith("Nenhuma")?"SEM ALTERAÇÃO":"REPARO CONCLUÍDO");result.setText(report);});
        }).start();
    }
    private void undo(TextView status,TextView result){
        try{
            File b=new File(gameDir(),".mikael_resolver_backup");int restored=0;File f=new File(b,"allocation.bak");
            if(f.exists()){LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation",Integer.parseInt(read(f).trim())).apply();restored++;}
            f=new File(b,"force_vsync.bak");if(f.exists()){LauncherPreferences.DEFAULT_PREF.edit().putBoolean("force_vsync",Boolean.parseBoolean(read(f).trim())).apply();restored++;}
            f=new File(b,"alternate_surface.bak");if(f.exists()){LauncherPreferences.DEFAULT_PREF.edit().putBoolean("alternate_surface",Boolean.parseBoolean(read(f).trim())).apply();restored++;}
            status.setText(restored>0?"RESTAURADO":"SEM BACKUP");result.setText(restored>0?"Últimas preferências restauradas.":"Nenhum backup encontrado.");
        }catch(Exception e){status.setText("DESFAZER FALHOU");result.setText("Erro: "+e.getMessage());}
    }
    private String read(File f)throws Exception{try(FileInputStream in=new FileInputStream(f)){byte[] b=new byte[(int)f.length()];int n=in.read(b);return n<=0?"":new String(b,0,n,StandardCharsets.UTF_8);}}
}