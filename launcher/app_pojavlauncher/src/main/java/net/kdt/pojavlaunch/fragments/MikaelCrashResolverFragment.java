package net.kdt.pojavlaunch.fragments;
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
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

public class MikaelCrashResolverFragment extends Fragment {
 public static final String TAG="MIKAEL_CRASH_RESOLVER";
 public MikaelCrashResolverFragment(){super(R.layout.fragment_mikael_crash_resolver);}
 @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
  TextView status=v.findViewById(R.id.resolve_status),result=v.findViewById(R.id.resolve_result);
  Button resolve=v.findViewById(R.id.resolve_button),undo=v.findViewById(R.id.resolve_undo),back=v.findViewById(R.id.resolve_back);
  status.setText("RESOLVER PRO++ pronto");
  result.setText("Analisa o último crash e aplica correções locais reversíveis.\n\nRAM, renderização, pastas essenciais e temporários. Toda alteração de preferência recebe backup.");
  resolve.setOnClickListener(x->repair(status,result));
  undo.setOnClickListener(x->undo(status,result));
  back.setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
 }
 private File gameDir(){
  String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
  if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);
  try{
   net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.load();
   net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile p=net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.mainProfileJson.profiles.get(cur);
   return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);
  }catch(Exception e){return new File(Tools.DIR_GAME_NEW);}
 }
 private String readLog(File dir){
  File[] fs={new File(dir,"latestlog.txt"),new File(dir,"logs/latest.log")};
  for(File f:fs)if(f.exists())try{
   StringBuilder s=new StringBuilder();
   BufferedReader r=new BufferedReader(new InputStreamReader(new FileInputStream(f),StandardCharsets.UTF_8));
   String line;while((line=r.readLine())!=null){s.append(line).append('\n');if(s.length()>180000)break;}r.close();return s.toString();
  }catch(Exception ignored){}
  return "";
 }
 private void repair(TextView status,TextView result){
  status.setText("ANALISANDO E REPARANDO...");
  new Thread(()->{
   StringBuilder out=new StringBuilder();
   try{
    File dir=gameDir(),backup=new File(dir,".mikael_resolver_backup");backup.mkdirs();
    String log=readLog(dir).toLowerCase(Locale.ROOT);int changes=0;
    if(log.contains("outofmemoryerror")||log.contains("java heap space")||log.contains("gc overhead")){
     int old=LauncherPreferences.DEFAULT_PREF.getInt("allocation",0);
     if(old>512){save(backup,"allocation",String.valueOf(old));int next=Math.max(512,old-256);LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation",next).apply();out.append("✓ RAM: ").append(old).append(" MB → ").append(next).append(" MB\n");changes++;}
    }
    if(log.contains("opengl")||log.contains("egl_bad")||log.contains("glfw")||log.contains("vulkan")||log.contains("shader compilation")||log.contains("fatal signal 11")){
     boolean vs=LauncherPreferences.DEFAULT_PREF.getBoolean("force_vsync",false),surf=LauncherPreferences.DEFAULT_PREF.getBoolean("alternate_surface",true);
     save(backup,"force_vsync",String.valueOf(vs));save(backup,"alternate_surface",String.valueOf(surf));
     LauncherPreferences.DEFAULT_PREF.edit().putBoolean("force_vsync",false).putBoolean("alternate_surface",true).apply();
     out.append("✓ Renderização: VSync OFF + superfície alternativa ON\n");changes++;
    }
    if(log.contains("permission denied")||log.contains("no such file")||log.contains("failed to open")){
     String[] ds={"mods","config","logs","crash-reports","resourcepacks","shaderpacks","saves"};
     for(String n:ds){File f=new File(dir,n);if(!f.exists()&&f.mkdirs()){out.append("✓ Pasta recriada: ").append(n).append("/\n");changes++;}}
    }
    if(log.contains("download failed")||log.contains("failed to download")||log.contains("connection reset")||log.contains("timeout")){
     File[] fs=dir.listFiles();if(fs!=null)for(File f:fs){String n=f.getName().toLowerCase(Locale.ROOT);if(f.isFile()&&(n.endsWith(".tmp")||n.endsWith(".part")||n.endsWith(".download"))){copy(f,new File(backup,f.getName()));if(f.delete()){out.append("✓ Temporário removido: ").append(f.getName()).append("\n");changes++;}}}
    }
    if(changes==0)out.append("NENHUMA CORREÇÃO AUTOMÁTICA\n\nNão encontrei evidência suficiente para alterar o perfil com segurança.\nUse VERIFICAR CRASH para diagnóstico detalhado.");
    else out.append("\nBackup: ").append(backup.getAbsolutePath()).append("\nUse DESFAZER ÚLTIMA para restaurar preferências.");
   }catch(Exception e){out.append("Falha segura: ").append(e.getClass().getSimpleName()).append(": ").append(e.getMessage());}
   final String text=out.toString();android.app.Activity a=getActivity();if(a!=null)a.runOnUiThread(()->{if(isAdded()){status.setText(text.startsWith("NENHUMA")?"SEM CORREÇÃO SEGURA":"REPARO CONCLUÍDO");result.setText(text);}});
  }).start();
 }
 private void undo(TextView status,TextView result){
  try{
   File b=new File(gameDir(),".mikael_resolver_backup");
   File a=new File(b,"allocation"),v=new File(b,"force_vsync"),s=new File(b,"alternate_surface");
   if(a.exists())LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation",Integer.parseInt(read(a))).apply();
   if(v.exists())LauncherPreferences.DEFAULT_PREF.edit().putBoolean("force_vsync",Boolean.parseBoolean(read(v))).apply();
   if(s.exists())LauncherPreferences.DEFAULT_PREF.edit().putBoolean("alternate_surface",Boolean.parseBoolean(read(s))).apply();
   status.setText("DESFAZER CONCLUÍDO");result.setText("Preferências salvas da última rodada restauradas.");
  }catch(Exception e){status.setText("FALHA AO DESFAZER");result.setText(e.getMessage());}
 }
 private void save(File d,String n,String v)throws Exception{d.mkdirs();FileOutputStream o=new FileOutputStream(new File(d,n));o.write(v.getBytes(StandardCharsets.UTF_8));o.close();}
 private String read(File f)throws Exception{BufferedReader r=new BufferedReader(new InputStreamReader(new FileInputStream(f),StandardCharsets.UTF_8));String s=r.readLine();r.close();return s==null?"":s;}
 private void copy(File a,File b)throws Exception{FileInputStream i=new FileInputStream(a);FileOutputStream o=new FileOutputStream(b);byte[] x=new byte[8192];int n;while((n=i.read(x))!=-1)o.write(x,0,n);i.close();o.close();}
}
