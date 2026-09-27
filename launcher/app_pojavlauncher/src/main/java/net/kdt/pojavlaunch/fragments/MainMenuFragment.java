package net.kdt.pojavlaunch.fragments;
import static net.kdt.pojavlaunch.Tools.*;
import android.content.Intent;
import android.graphics.Color;
import android.content.res.ColorStateList;
import android.net.Uri;
import android.widget.VideoView;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;
import com.kdt.mcgui.mcVersionSpinner;
import net.kdt.pojavlaunch.CustomControlsActivity;
import net.kdt.pojavlaunch.LauncherActivity;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.extra.ExtraConstants;
import net.kdt.pojavlaunch.extra.ExtraCore;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;
import net.kdt.pojavlaunch.prefs.screens.LauncherPreferenceFragment;
import net.kdt.pojavlaunch.progresskeeper.ProgressKeeper;
import net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles;
import net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile;
import java.io.File;
public class MainMenuFragment extends Fragment {
 public static final String TAG="MainMenuFragment";
 private mcVersionSpinner mVersionSpinner;
 public MainMenuFragment(){super(R.layout.fragment_launcher);}
 @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
  Button controls=v.findViewById(R.id.custom_control_button),settings=v.findViewById(R.id.settings_button),files=v.findViewById(R.id.open_files_button),logs=v.findViewById(R.id.share_logs_button),news=v.findViewById(R.id.news_button),discord=v.findViewById(R.id.discord_button),install=v.findViewById(R.id.install_jar_button),play=v.findViewById(R.id.play_button);
  ImageButton profile=v.findViewById(R.id.edit_profile_button); mVersionSpinner=v.findViewById(R.id.mc_version_spinner);
   Button modLibrary=v.findViewById(R.id.mod_library_button),contentLibrary=v.findViewById(R.id.content_library_button),forgeOptiFine=v.findViewById(R.id.forge_optifine_button);
  applyMikaelTheme(v);
  setupMikaelVideo(v);
  controls.setOnClickListener(x->startActivity(new Intent(requireContext(),CustomControlsActivity.class)));
  settings.setOnClickListener(x->swapFragment(requireActivity(),LauncherPreferenceFragment.class,LauncherActivity.SETTING_FRAGMENT_TAG,null));
  news.setOnClickListener(x->openURL(requireActivity(),URL_HOME));
  discord.setOnClickListener(x->openURL(requireActivity(),getString(R.string.discord_invite)));
   if(modLibrary!=null) modLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelModLibraryFragment.class,MikaelModLibraryFragment.TAG,null));
   if(contentLibrary!=null) contentLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelContentLibraryFragment.class,MikaelContentLibraryFragment.TAG,null));
   if(forgeOptiFine!=null) forgeOptiFine.setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));
  logs.setOnClickListener(x->shareLog(requireContext()));
  files.setOnClickListener(x->openPath(requireContext(),getCurrentProfileDirectory(),false));
  install.setOnClickListener(x->runInstaller(false));
   install.setOnLongClickListener(x->{runInstaller(true);return true;});
  profile.setOnClickListener(x->mVersionSpinner.openProfileEditor(requireActivity()));
  play.setOnClickListener(x->{if(hasMods("sodium")&&!LauncherPreferences.DEFAULT_PREF.getBoolean("sodium_override",false)){new AlertDialog.Builder(requireContext()).setTitle(R.string.sodium_warning_title).setMessage(R.string.sodium_warning_message).setNeutralButton(R.string.delete_sodium,(d,w)->{deleteSodiumMods();ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);}).show();}else ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);});
 }
 private void applyMikaelTheme(View v){
  String hex=LauncherPreferences.DEFAULT_PREF.getString("mikael_accent_color","#4ADE80");
  int color;
  try{color=Color.parseColor(hex);}catch(Exception e){color=Color.rgb(74,222,128);}
  int[] ids={R.id.custom_control_button,R.id.settings_button,R.id.open_files_button,R.id.share_logs_button,R.id.news_button,R.id.discord_button,R.id.install_jar_button};
  for(int id:ids){View x=v.findViewById(id); if(x!=null) x.setBackgroundTintList(ColorStateList.valueOf(color));}
  View play=v.findViewById(R.id.play_button); if(play!=null) play.setBackgroundTintList(ColorStateList.valueOf(color));
 }
 private void setupMikaelVideo(View v){
  VideoView video=v.findViewById(R.id.mikael_video_background);
  String uri=LauncherPreferences.DEFAULT_PREF.getString("mikael_video_uri","");
  boolean enabled=LauncherPreferences.DEFAULT_PREF.getBoolean("mikael_video_enabled",false);
  if(video==null || !enabled || uri==null || uri.isEmpty()) return;
  try{
   video.setVideoURI(Uri.parse(uri));
   video.setOnPreparedListener(mp->{mp.setLooping(true);mp.setVolume(0f,0f);video.start();});
   video.setVisibility(View.VISIBLE);
  }catch(Exception ignored){video.setVisibility(View.GONE);}
 }
 private File getCurrentProfileDirectory(){String p=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);if(!isValidString(p))return new File(DIR_GAME_NEW);LauncherProfiles.load();MinecraftProfile m=LauncherProfiles.mainProfileJson.profiles.get(p);return m==null?new File(DIR_GAME_NEW):getGameDirPath(m);}
 private void runInstaller(boolean custom){if(ProgressKeeper.getTaskCount()==0)installMod(requireActivity(),custom);else Toast.makeText(requireContext(),R.string.tasks_ongoing,Toast.LENGTH_LONG).show();}
 @Override public void onResume(){super.onResume();if(mVersionSpinner!=null)mVersionSpinner.reloadProfiles(); View root=getView(); if(root!=null){applyMikaelTheme(root); setupMikaelVideo(root);}}
}
