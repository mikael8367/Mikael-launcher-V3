package net.kdt.pojavlaunch.fragments;
import android.os.*; import android.view.*; import android.widget.*; import androidx.annotation.*; import androidx.appcompat.app.AlertDialog; import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.*; import net.kdt.pojavlaunch.prefs.LauncherPreferences; import net.kdt.pojavlaunch.value.launcherprofiles.*; import org.json.*; import java.io.*; import java.net.*; import java.util.*; import java.lang.reflect.Field; import java.lang.reflect.Method;
public class MikaelContentLibraryFragment extends Fragment {
 public static final String TAG="MIKAEL_CONTENT_LIBRARY"; Spinner type; EditText search; TextView status; ListView list; ArrayAdapter<String> adapter; List<Item> items=new ArrayList<>();
 public MikaelContentLibraryFragment(){super(R.layout.fragment_mikael_content_library);}
 public void onViewCreated(@NonNull View v,@Nullable Bundle b){
  type=v.findViewById(R.id.content_type); search=v.findViewById(R.id.content_search); status=v.findViewById(R.id.content_status); list=v.findViewById(R.id.content_list); adapter=new ArrayAdapter<>(requireContext(),android.R.layout.simple_list_item_1,new ArrayList<>()); list.setAdapter(adapter);
  type.setAdapter(new ArrayAdapter<String>(requireContext(),android.R.layout.simple_spinner_dropdown_item,new String[]{"Mods","Texturas / Resource Packs","Shaders","Mundos"}));
  v.findViewById(R.id.content_search_button).setOnClickListener(x->load()); v.findViewById(R.id.content_back).setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null)); list.setOnItemClickListener((p,x,pos,id)->confirm(items.get(pos))); load();
 }
 void load(){int t=type.getSelectedItemPosition(); String q=search.getText().toString().trim(); String selectedVersion=detectMinecraftVersion(); status.setText(selectedVersion==null?"Pesquisando...":"Pesquisando para Minecraft "+selectedVersion+"..."); new Thread(()->{try{
  String classId=t==0?"6":t==1?"12":t==2?"6552":"17"; String mcVersion=detectMinecraftVersion(); String u="https://api.curseforge.com/v1/mods/search?gameId=432&classId="+classId+"&pageSize=30"; if(mcVersion!=null&&!mcVersion.isEmpty())u+="&gameVersion="+URLEncoder.encode(mcVersion,"UTF-8"); if(!q.isEmpty())u+="&searchFilter="+URLEncoder.encode(q,"UTF-8");
  JSONArray a=json(u).optJSONArray("data"); List<Item> out=new ArrayList<>(); if(a!=null)for(int i=0;i<a.length();i++){JSONObject m=a.getJSONObject(i); JSONArray fs=m.optJSONArray("latestFiles"); JSONObject f=fs!=null&&fs.length()>0?fs.optJSONObject(0):null; if(f!=null)out.add(new Item(m.optString("id"),m.optString("name","Item"),m.optString("summary",""),f.optString("id"),f.optString("displayName",f.optString("fileName","download"))));}
  requireActivity().runOnUiThread(()->{items.clear();items.addAll(out);adapter.clear();for(Item x:items)adapter.add(x.name+"\n"+x.file);adapter.notifyDataSetChanged();status.setText(out.size()+" resultados");});
 }catch(Exception e){requireActivity().runOnUiThread(()->status.setText("Erro: "+e.getMessage()));}}).start();}
 void confirm(Item x){new AlertDialog.Builder(requireContext()).setTitle(x.name).setMessage(x.summary+"\n\n"+x.file).setNegativeButton("CANCELAR",null).setPositiveButton("BAIXAR",(d,w)->download(x)).show();}
 void download(Item x){status.setText("Baixando...");new Thread(()->{try{
  String u=json("https://api.curseforge.com/v1/mods/"+x.modId+"/files/"+x.fileId+"/download-url").optString("data",""); if(u.isEmpty())throw new Exception("Download indisponível.");
  File base=getDir(); int t=type.getSelectedItemPosition(); String folder=t==0?"mods":t==1?"resourcepacks":t==2?"shaderpacks":"saves"; File dir=new File(base,folder); if(!dir.exists()&&!dir.mkdirs())throw new Exception("Não foi possível criar "+folder);
  String fn=x.file.replaceAll("[\\\\/:*?\"<>|]","_"); File out=new File(dir,fn); HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();c.setConnectTimeout(15000);c.setReadTimeout(60000);
  try(InputStream in=c.getInputStream();FileOutputStream o=new FileOutputStream(out)){byte[] b=new byte[8192];int n;while((n=in.read(b))!=-1)o.write(b,0,n);}
  requireActivity().runOnUiThread(()->status.setText("Instalado em "+folder+"/: "+out.getName()));
 }catch(Exception e){requireActivity().runOnUiThread(()->status.setText("Falha: "+e.getMessage()));}}).start();}
 String detectMinecraftVersion(){
  try{
   String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
   if(cur==null||cur.trim().isEmpty()) return null;
   LauncherProfiles.load(); MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);
   if(p==null) return null;
   String[] names={"lastVersionId","versionId","version","versionName","gameVersion"};
   for(String n:names){
    try{ Field f=p.getClass().getDeclaredField(n); f.setAccessible(true); Object v=f.get(p); if(v!=null&&v.toString().matches("[0-9]+[.][0-9]+([.][0-9]+)?([.-].*)?")) return v.toString(); }catch(Exception ignored){}
    try{ String m="get"+Character.toUpperCase(n.charAt(0))+n.substring(1); Method mm=p.getClass().getMethod(m); Object v=mm.invoke(p); if(v!=null&&v.toString().matches("[0-9]+[.][0-9]+([.][0-9]+)?([.-].*)?")) return v.toString(); }catch(Exception ignored){}
   }
  }catch(Exception ignored){}
  return null;
 }
 JSONObject json(String u)throws Exception{HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();c.setRequestProperty("Accept","application/json");c.setRequestProperty("x-api-key",getString(R.string.curseforge_api_key));int code=c.getResponseCode();InputStream in=code>=400?c.getErrorStream():c.getInputStream();ByteArrayOutputStream o=new ByteArrayOutputStream();byte[] b=new byte[8192];int n;while((n=in.read(b))!=-1)o.write(b,0,n);if(code>=400)throw new Exception("HTTP "+code);return new JSONObject(o.toString("UTF-8"));}
 File getDir(){String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);LauncherProfiles.load();MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);}
 static class Item{String modId,name,summary,fileId,file;Item(String a,String b,String c,String d,String e){modId=a;name=b;summary=c;fileId=d;file=e;}}
}
