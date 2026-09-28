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
        status.setText("Pesquisando mods...");
        new Thread(()->{
            try {
                String u="https://api.curseforge.com/v1/mods/search?gameId=432&classId=6&pageSize=20";
                if(!q.isEmpty()) u+="&searchFilter="+URLEncoder.encode(q,"UTF-8");
                JSONArray data;
                try {
                    data=getJson(u).optJSONArray("data");
                } catch(Exception curseError) {
                    // CurseForge requires a valid x-api-key. Fall back to the public Modrinth API.
                    String mr="https://api.modrinth.com/v2/search?limit=20&facets="+URLEncoder.encode("[[\\"project_type:mod\\"]]", "UTF-8");
                    if(!q.isEmpty()) mr+="&query="+URLEncoder.encode(q,"UTF-8");
                    data=new JSONArray();
                    JSONArray hits=getJsonPublic(mr).optJSONArray("hits");
                    if(hits!=null) for(int i=0;i<hits.length();i++){
                        JSONObject h=hits.getJSONObject(i);
                        String id=h.optString("project_id");
                        String title=h.optString("title","Mod");
                        String desc=h.optString("description","");
                        JSONObject item=new JSONObject();
                        item.put("id","mr:"+id);
                        item.put("name",title);
                        item.put("summary",desc);
                        item.put("fileId",h.optString("latest_version",""));
                        item.put("fileName","Modrinth");
                        data.put(item);
                    }
                }
                List<ModItem> found=new ArrayList<>();
                for(int i=0;i<data.length();i++){
                    JSONObject m=data.getJSONObject(i);
                    if(m.optString("id").startsWith("mr:")){
                        found.add(new ModItem(m.optString("id"),m.optString("name","Mod"),m.optString("summary",""),m.optString("fileId"),m.optString("fileName","Modrinth")));
                    } else {
                        JSONObject f=m.optJSONArray("latestFiles")!=null?m.getJSONArray("latestFiles").optJSONObject(0):null;
                        if(f!=null) found.add(new ModItem(m.optString("id"),m.optString("name","Mod"),m.optString("summary",""),f.optString("id"),f.optString("displayName",f.optString("fileName","Arquivo"))));
                    }
                }
                android.app.Activity a=getActivity(); if(a==null)return; a.runOnUiThread(()->{
                    mods.clear(); mods.addAll(found); adapter.clear();
                    for(ModItem m:mods) adapter.add(m.name+"\n"+m.fileName);
