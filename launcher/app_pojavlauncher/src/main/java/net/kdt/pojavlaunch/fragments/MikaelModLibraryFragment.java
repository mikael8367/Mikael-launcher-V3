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
import java.util.List;

public class MikaelModLibraryFragment extends Fragment {
    public static final String TAG = "MIKAEL_MOD_LIBRARY";
    private final List<ModItem> mods = new ArrayList<>();
    private ArrayAdapter<String> adapter;
    private TextView status;
    private EditText search;

    public MikaelModLibraryFragment() { super(R.layout.fragment_mikael_mod_library); }

    @Override public void onViewCreated(@NonNull View v, @Nullable Bundle b) {
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

    private void searchMods() {
        String q=search.getText().toString().trim();
        status.setText("Pesquisando mods no CurseForge...");
        new Thread(()->{
            try {
                String u="https://api.curseforge.com/v1/mods/search?gameId=432&classId=6&pageSize=20";
                if(!q.isEmpty()) u+="&searchFilter="+URLEncoder.encode(q,"UTF-8");
                JSONArray data=getJson(u).optJSONArray("data");
                List<ModItem> found=new ArrayList<>();
                if(data!=null) for(int i=0;i<data.length();i++){
                    JSONObject m=data.getJSONObject(i), f=m.optJSONArray("latestFiles")!=null?m.getJSONArray("latestFiles").optJSONObject(0):null;
                    if(f!=null) found.add(new ModItem(m.optString("id"),m.optString("name","Mod"),m.optString("summary",""),f.optString("id"),f.optString("displayName",f.optString("fileName","Arquivo"))));
                }
                requireActivity().runOnUiThread(()->{
                    mods.clear(); mods.addAll(found); adapter.clear();
                    for(ModItem m:mods) adapter.add(m.name+"\n"+m.fileName);
                    adapter.notifyDataSetChanged(); status.setText(found.size()+" mods encontrados • toque para instalar");
                });
            } catch(Exception e){ requireActivity().runOnUiThread(()->status.setText("Erro: "+e.getMessage())); }
        }).start();
    }

    private void confirmInstall(ModItem m) {
        new AlertDialog.Builder(requireContext()).setTitle(m.name)
            .setMessage(m.summary+"\n\nArquivo: "+m.fileName)
            .setNegativeButton("CANCELAR",null).setPositiveButton("BAIXAR",(d,w)->downloadMod(m)).show();
    }

    private void downloadMod(ModItem m) {
        status.setText("Baixando "+m.name+"...");
        new Thread(()->{
            try {
                String url=getJson("https://api.curseforge.com/v1/mods/"+m.modId+"/files/"+m.fileId+"/download-url").optString("data","");
                if(url.isEmpty()) throw new Exception("CurseForge não forneceu o link.");
                File dir=getCurrentProfileDirectory(), modsDir=new File(dir,"mods");
                if(!modsDir.exists()&&!modsDir.mkdirs()) throw new Exception("Não foi possível criar a pasta mods.");
                File out=new File(modsDir,m.fileName.replaceAll("[\\\\/:*?\"<>|]","_"));
                HttpURLConnection c=(HttpURLConnection)new URL(url).openConnection();
                c.setConnectTimeout(15000); c.setReadTimeout(30000);
                try(InputStream in=c.getInputStream();FileOutputStream o=new FileOutputStream(out)){
                    byte[] b=new byte[8192]; int n; while((n=in.read(b))!=-1)o.write(b,0,n);
                }
                requireActivity().runOnUiThread(()->status.setText("Instalado em mods/: "+out.getName()));
            }catch(Exception e){requireActivity().runOnUiThread(()->status.setText("Falha: "+e.getMessage()));}
        }).start();
    }

    private JSONObject getJson(String u)throws Exception{
        HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();
        c.setRequestMethod("GET"); c.setConnectTimeout(15000); c.setReadTimeout(20000);
        c.setRequestProperty("Accept","application/json");
        c.setRequestProperty("x-api-key",getString(R.string.curseforge_api_key));
        int code=c.getResponseCode(); InputStream in=code>=400?c.getErrorStream():c.getInputStream();
        java.io.ByteArrayOutputStream o=new java.io.ByteArrayOutputStream(); byte[] b=new byte[8192]; int n;
        while((n=in.read(b))!=-1)o.write(b,0,n);
        if(code>=400)throw new Exception("HTTP "+code);
        return new JSONObject(o.toString("UTF-8"));
    }

    private File getCurrentProfileDirectory(){
        String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
        if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);
        LauncherProfiles.load(); MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);
        return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);
    }

    private static class ModItem{
        final String modId,name,summary,fileId,fileName;
        ModItem(String a,String b,String c,String d,String e){modId=a;name=b;summary=c;fileId=d;fileName=e;}
    }
}
