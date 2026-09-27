package net.kdt.pojavlaunch.fragments;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import net.kdt.pojavlaunch.JMinecraftVersionList;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.JavaGUILauncherActivity;
import net.kdt.pojavlaunch.extra.ExtraConstants;
import net.kdt.pojavlaunch.extra.ExtraCore;
import net.kdt.pojavlaunch.modloaders.ForgeDownloadTask;
import net.kdt.pojavlaunch.modloaders.ForgeUtils;
import net.kdt.pojavlaunch.modloaders.ModloaderDownloadListener;
import net.kdt.pojavlaunch.modloaders.OptiFineDownloadTask;
import net.kdt.pojavlaunch.modloaders.OptiFineUtils;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;

public class MikaelForgeOptiFineFragment extends Fragment {
    public static final String TAG="MIKAEL_FORGE_OPTIFINE";
    private Spinner game, forge, optifine;
    private TextView status;
    private final List<String> forgeAll=new ArrayList<>();
    private OptiFineUtils.OptiFineVersions ofAll;

    public MikaelForgeOptiFineFragment(){ super(R.layout.fragment_mikael_forge_optifine); }

    private void fill(Spinner s, List<String> values){
        ArrayAdapter<String> a=new ArrayAdapter<>(requireContext(), android.R.layout.simple_spinner_dropdown_item, values);
        s.setAdapter(a);
    }

    @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
        game=v.findViewById(R.id.mfo_game); forge=v.findViewById(R.id.mfo_forge); optifine=v.findViewById(R.id.mfo_optifine); status=v.findViewById(R.id.mfo_status);
        Button install=v.findViewById(R.id.mfo_install), back=v.findViewById(R.id.mfo_back);
        List<String> games=new ArrayList<>();
        JMinecraftVersionList table=(JMinecraftVersionList)ExtraCore.getValue(ExtraConstants.RELEASE_TABLE);
        if(table!=null && table.versions!=null) for(JMinecraftVersionList.Version x:table.versions) if(x.id!=null && !games.contains(x.id)) games.add(x.id);
        fill(game,games);
        game.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener(){
            public void onNothingSelected(android.widget.AdapterView<?> p){}
            public void onItemSelected(android.widget.AdapterView<?> p,View x,int pos,long id){ refreshLoaders(games.get(pos)); }
        });
        new Thread(()->{
            try{
                List<String> f=ForgeUtils.downloadForgeVersions();
                android.app.Activity a=getActivity(); if(a==null)return; a.runOnUiThread(()->{forgeAll.clear(); if(f!=null) forgeAll.addAll(f); if(!games.isEmpty()) refreshLoaders(games.get(0));});
                ofAll=OptiFineUtils.downloadOptiFineVersions();
                if(!games.isEmpty()) requireActivity().runOnUiThread(()->refreshLoaders(games.get(game.getSelectedItemPosition())));
            }catch(Exception e){ requireActivity().runOnUiThread(()->status.setText("Não foi possível carregar Forge/OptiFine."));}
        }).start();
        install.setOnClickListener(x->installPair());
        back.setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
    }

    private void refreshLoaders(String mc){
        List<String> fs=new ArrayList<>();
        for(String f:forgeAll) if(f.startsWith(mc+"-")) fs.add(f);
        fill(forge,fs);
        List<String> os=new ArrayList<>();
        if(ofAll!=null && ofAll.minecraftVersions!=null){
            for(int i=0;i<ofAll.minecraftVersions.size();i++){
                if(mc.equals(ofAll.minecraftVersions.get(i)) && i<ofAll.optifineVersions.size())
                    for(OptiFineUtils.OptiFineVersion o:ofAll.optifineVersions.get(i)) os.add(o.versionName);
            }
        }
        fill(optifine,os);
        status.setText("Jogo: "+mc+" • Forge: "+fs.size()+" • OptiFine: "+os.size());
    }

    private void installPair(){
        if(game.getSelectedItem()==null || forge.getSelectedItem()==null || optifine.getSelectedItem()==null){
            status.setText("Selecione Minecraft, Forge e OptiFine compatíveis.");
            return;
        }
        final String mc=game.getSelectedItem().toString();
        final String fv=forge.getSelectedItem().toString();
        final String ov=optifine.getSelectedItem().toString();
        OptiFineUtils.OptiFineVersion selectedOF=null;
        for(int i=0;i<ofAll.minecraftVersions.size();i++) if(mc.equals(ofAll.minecraftVersions.get(i))){
            for(OptiFineUtils.OptiFineVersion o:ofAll.optifineVersions.get(i)) if(ov.equals(o.versionName)) selectedOF=o;
        }
        if(selectedOF==null){status.setText("OptiFine selecionado não foi encontrado.");return;}
        status.setText("Baixando Forge + OptiFine...");
        final OptiFineUtils.OptiFineVersion of=selectedOF;
        new Thread(()->{
            new ForgeDownloadTask(new ModloaderDownloadListener(){
                public void onDownloadFinished(File forgeJar){
                    new OptiFineDownloadTask(of,new ModloaderDownloadListener(){
                        public void onDownloadFinished(File ofJar){
                            android.app.Activity a=getActivity(); if(a==null)return; a.runOnUiThread(()->{
                                status.setText("Downloads concluídos. Abrindo instalador do Forge...");
                                Intent i=new Intent(requireContext(),JavaGUILauncherActivity.class);
                                ForgeUtils.addAutoInstallArgs(i,forgeJar,true);
                                i.putExtra("mikael_optifine_jar",ofJar.getAbsolutePath());
                                i.putExtra("mikael_minecraft_version",mc);
                                startActivity(i);
                            });
                        }
                        public void onDataNotAvailable(){fail("OptiFine não disponível");}
                        public void onDownloadError(Exception e){fail("Erro no OptiFine: "+e.getMessage());}
                        private void fail(String x){requireActivity().runOnUiThread(()->status.setText(x));}
                    },requireActivity()).run();
                }
                public void onDataNotAvailable(){fail("Forge não disponível");}
                public void onDownloadError(Exception e){fail("Erro no Forge: "+e.getMessage());}
                private void fail(String x){requireActivity().runOnUiThread(()->status.setText(x));}
            },fv).run();
        }).start();
    }
}
