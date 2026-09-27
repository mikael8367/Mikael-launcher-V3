#!/usr/bin/env bash
set -euo pipefail
ROOT=app_pojavlauncher/src/main
RES=$ROOT/res
JAVA=$ROOT/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java
mkdir -p "$RES/drawable"

cat > "$RES/drawable/mikael_logo.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="128dp" android:height="128dp" android:viewportWidth="128" android:viewportHeight="128">
<path android:fillColor="#101827" android:pathData="M8,8h112v112H8z"/>
<path android:fillColor="#4ADE80" android:pathData="M18,18h92v92H18z"/>
<path android:fillColor="#101827" android:pathData="M30,30h14v24h8V30h14v24h8V30h14v66H74V68h-8v28H52V68h-8v28H30z"/>
<path android:fillColor="#FFFFFF" android:pathData="M32,101h64v4H32z"/>
</vector>
EOF

cat > "$RES/layout/fragment_launcher.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:background="@color/background_app">
<ScrollView android:layout_width="match_parent" android:layout_height="0dp" android:fillViewport="true" app:layout_constraintTop_toTopOf="parent" app:layout_constraintBottom_toTopOf="@id/mikael_bottom">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center_horizontal" android:paddingHorizontal="@dimen/_16sdp" android:paddingTop="@dimen/_16sdp" android:paddingBottom="@dimen/_10sdp">
<ImageView android:layout_width="@dimen/_88sdp" android:layout_height="@dimen/_88sdp" android:src="@drawable/mikael_logo" android:contentDescription="Mikael Launcher"/>
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginTop="@dimen/_6sdp" android:text="MIKAEL LAUNCHER V3" android:textSize="@dimen/_21ssp" android:textStyle="bold" android:textColor="@android:color/white"/>
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Minecraft Java Edition" android:textSize="@dimen/_12ssp" android:alpha="0.72"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="@dimen/_10sdp" android:padding="@dimen/padding_medium" android:gravity="center" android:text="Versões • Perfis • Controles • Mods" android:textSize="@dimen/_11ssp" android:background="@drawable/background_card"/>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:layout_marginTop="@dimen/_8sdp">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/custom_control_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="CONTROLES" android:drawableStart="@drawable/ic_menu_custom_controls"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/settings_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="AJUSTES" android:drawableStart="@drawable/ic_menu_settings"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/open_files_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="ARQUIVOS"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/share_logs_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="LOGS"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/news_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="NOTÍCIAS"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/discord_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="COMUNIDADE"/>
</LinearLayout>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/install_jar_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="INSTALAR MOD / JAR"/>
</LinearLayout>
</ScrollView>
<LinearLayout android:id="@+id/mikael_bottom" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:paddingHorizontal="@dimen/_12sdp" android:paddingTop="@dimen/_6sdp" android:paddingBottom="@dimen/_9sdp" android:background="@color/background_bottom_bar" app:layout_constraintBottom_toBottomOf="parent">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal">
<com.kdt.mcgui.mcVersionSpinner android:id="@+id/mc_version_spinner" android:layout_width="0dp" android:layout_height="@dimen/_50sdp" android:layout_weight="1" android:background="@android:color/transparent" android:drawableEnd="@drawable/spinner_arrow" app:drawableEndSize="@dimen/padding_heavy" app:drawableStartIntegerScaling="true" app:drawableStartSize="@dimen/_34sdp" app:drawableEndPadding="@dimen/_1sdp"/>
<ImageButton android:id="@+id/edit_profile_button" android:layout_width="@dimen/_50sdp" android:layout_height="@dimen/_50sdp" android:background="?android:attr/selectableItemBackground" android:src="@drawable/ic_edit_profile" android:contentDescription="Perfil"/>
</LinearLayout>
<com.kdt.mcgui.MineButton android:id="@+id/play_button" android:layout_width="match_parent" android:layout_height="@dimen/_56sdp" android:layout_marginTop="@dimen/_5sdp" android:text="JOGAR" android:textAllCaps="true"/>
</LinearLayout>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$JAVA" <<'EOF'
package net.kdt.pojavlaunch.fragments;
import static net.kdt.pojavlaunch.Tools.*;
import android.content.Intent;
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
  controls.setOnClickListener(x->startActivity(new Intent(requireContext(),CustomControlsActivity.class)));
  settings.setOnClickListener(x->swapFragment(requireActivity(),LauncherPreferenceFragment.class,LauncherActivity.SETTING_FRAGMENT_TAG,null));
  news.setOnClickListener(x->openURL(requireActivity(),URL_HOME));
  discord.setOnClickListener(x->openURL(requireActivity(),getString(R.string.discord_invite)));
  logs.setOnClickListener(x->shareLog(requireContext()));
  files.setOnClickListener(x->{if(!hasOnlineProfile()){hasNoOnlineProfileDialog(requireActivity());return;}openPath(requireContext(),getCurrentProfileDirectory(),false);});
  if(hasOnlineProfile()){install.setOnClickListener(x->runInstaller(false));install.setOnLongClickListener(x->{runInstaller(true);return true;});}else install.setOnClickListener(x->hasNoOnlineProfileDialog(requireActivity()));
  profile.setOnClickListener(x->mVersionSpinner.openProfileEditor(requireActivity()));
  play.setOnClickListener(x->{if(hasMods("sodium")&&!LauncherPreferences.DEFAULT_PREF.getBoolean("sodium_override",false)){new AlertDialog.Builder(requireContext()).setTitle(R.string.sodium_warning_title).setMessage(R.string.sodium_warning_message).setNeutralButton(R.string.delete_sodium,(d,w)->{deleteSodiumMods();ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);}).show();}else ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);});
 }
 private File getCurrentProfileDirectory(){String p=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);if(!isValidString(p))return new File(DIR_GAME_NEW);LauncherProfiles.load();MinecraftProfile m=LauncherProfiles.mainProfileJson.profiles.get(p);return m==null?new File(DIR_GAME_NEW):getGameDirPath(m);}
 private void runInstaller(boolean custom){if(ProgressKeeper.getTaskCount()==0)installMod(requireActivity(),custom);else Toast.makeText(requireContext(),R.string.tasks_ongoing,Toast.LENGTH_LONG).show();}
 @Override public void onResume(){super.onResume();if(mVersionSpinner!=null)mVersionSpinner.reloadProfiles();}
}
EOF

grep -q '<string name="app_name"' "$RES/values/strings.xml" && sed -i 's#<string name="app_name"[^<]*>[^<]*</string>#<string name="app_name" translatable="false">Mikael Launcher V3</string>#' "$RES/values/strings.xml"
