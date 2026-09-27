#!/usr/bin/env bash
set -euo pipefail
ROOT=app_pojavlauncher/src/main
RES=$ROOT/res
JAVA=$ROOT/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java
mkdir -p "$RES/drawable"

# Use the Mikael logo as the actual Android launcher icon.
MANIFEST="$ROOT/AndroidManifest.xml"
python3 - <<'PY'
from pathlib import Path
p = Path("app_pojavlauncher/src/main/AndroidManifest.xml")
s = p.read_text()
s = s.replace('android:icon="@mipmap/ic_launcher"', 'android:icon="@drawable/mikael_logo"')
s = s.replace('android:roundIcon="@mipmap/ic_launcher_round"', 'android:roundIcon="@drawable/mikael_logo"')
p.write_text(s)
PY

cat > "$RES/drawable/mikael_logo.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="128dp" android:height="128dp" android:viewportWidth="128" android:viewportHeight="128">
<path android:fillColor="#101827" android:pathData="M8,8h112v112H8z"/>
<path android:fillColor="#4ADE80" android:pathData="M18,18h92v92H18z"/>
<path android:fillColor="#101827" android:pathData="M30,30h14v24h8V30h14v24h8V30h14v66H74V68h-8v28H52V68h-8v28H30z"/>
<path android:fillColor="#FFFFFF" android:pathData="M32,101h64v4H32z"/>
</vector>
EOF

cat > "$RES/drawable/ic_mikael_profile.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="28dp" android:height="28dp" android:viewportWidth="28" android:viewportHeight="28"><path android:fillColor="#FFFFFF" android:pathData="M14,3a5,5 0,1 1,0 10a5,5 0,0 1,0 -10M5,25c0,-5 4,-8 9,-8s9,3 9,8z"/></vector>
EOF
cat > "$RES/drawable/mikael_play.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="#4ADE80"/><corners android:radius="16dp"/><padding android:left="10dp" android:top="6dp" android:right="10dp" android:bottom="6dp"/></shape>
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
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/custom_control_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="CONTROLES" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/settings_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="AJUSTES" android:background="@drawable/mikael_button"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/open_files_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="ARQUIVOS"/ android:background="@drawable/mikael_button">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/share_logs_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="LOGS"/ android:background="@drawable/mikael_button">
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/news_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="NOTÍCIAS"/ android:background="@drawable/mikael_button">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/discord_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="COMUNIDADE"/ android:background="@drawable/mikael_button">
</LinearLayout>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/install_jar_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="INSTALAR MOD / JAR"/ android:background="@drawable/mikael_button">
</LinearLayout>
</ScrollView>
<LinearLayout android:id="@+id/mikael_bottom" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:paddingHorizontal="@dimen/_12sdp" android:paddingTop="@dimen/_6sdp" android:paddingBottom="@dimen/_9sdp" android:background="@color/background_bottom_bar" app:layout_constraintBottom_toBottomOf="parent">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal">
<com.kdt.mcgui.mcVersionSpinner android:id="@+id/mc_version_spinner" android:layout_width="0dp" android:layout_height="@dimen/_50sdp" android:layout_weight="1" android:background="@android:color/transparent" android:drawableEnd="@drawable/spinner_arrow" app:drawableEndSize="@dimen/padding_heavy" app:drawableStartIntegerScaling="true" app:drawableStartSize="@dimen/_34sdp" app:drawableEndPadding="@dimen/_1sdp"/>
<ImageButton android:id="@+id/edit_profile_button" android:layout_width="@dimen/_50sdp" android:layout_height="@dimen/_50sdp" android:background="@drawable/mikael_button" android:src="@drawable/ic_mikael_profile" android:contentDescription="Perfil"/>
</LinearLayout>
<com.kdt.mcgui.MineButton android:id="@+id/play_button" android:background="@drawable/mikael_play" android:textColor="#0C0E12" android:layout_width="match_parent" android:layout_height="@dimen/_56sdp" android:layout_marginTop="@dimen/_5sdp" android:text="JOGAR" android:textAllCaps="true"/>
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


# Fully custom Mikael account/header UI (no Amethyst skin/launcher images).
cat > "$RES/drawable/mikael_button.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="#20242D"/><corners android:radius="14dp"/><stroke android:width="1dp" android:color="#343A46"/><padding android:left="12dp" android:top="10dp" android:right="12dp" android:bottom="10dp"/></shape>
EOF
cat > "$RES/drawable/mikael_topbar.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="#111318"/><corners android:bottomLeftRadius="18dp" android:bottomRightRadius="18dp"/></shape>
EOF
cat > "$RES/drawable/mikael_add.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="28dp" android:height="28dp" android:viewportWidth="28" android:viewportHeight="28"><path android:fillColor="#4ADE80" android:pathData="M13,4h2v9h9v2h-9v9h-2v-9H4v-2h9z"/></vector>
EOF
cat > "$RES/drawable/ic_mikael_settings.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="28dp" android:height="28dp" android:viewportWidth="28" android:viewportHeight="28"><path android:fillColor="#FFFFFF" android:pathData="M3,6h22v2H3zM3,13h22v2H3zM3,20h22v2H3z"/><path android:fillColor="#4ADE80" android:pathData="M8,4h3v6H8zM17,11h3v6h-3zM11,18h3v6h-3z"/></vector>
EOF
cat > "$RES/drawable/ic_mikael_home.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="28dp" android:height="28dp" android:viewportWidth="28" android:viewportHeight="28"><path android:fillColor="#FFFFFF" android:pathData="M4,13.5L14,5l10,8.5v9a2,2 0,0 1,-2 2h-5v-7h-6v7H6a2,2 0,0 1,-2 -2z"/></vector>
EOF
cat > "$RES/drawable/ic_mikael_delete.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="24dp" android:height="24dp" android:viewportWidth="24" android:viewportHeight="24"><path android:fillColor="#FF6B6B" android:pathData="M6,7h12l-1,14H7zM9,4h6l1,2H8z"/></vector>
EOF
cat > "$RES/layout/item_minecraft_account.xml" <<'EOF'
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="@dimen/_52sdp" android:orientation="horizontal" android:gravity="center_vertical" android:background="#111318">
<fr.spse.extended_view.ExtendedTextView android:id="@+id/account_item" android:layout_width="0dp" android:layout_height="match_parent" android:layout_weight="1" android:gravity="center_vertical" android:paddingStart="@dimen/_16sdp" android:textColor="#FFFFFF" android:textSize="@dimen/_16ssp" android:maxLines="1" android:ellipsize="end"/>
<ImageView android:id="@+id/delete_account_button" android:layout_width="@dimen/_44sdp" android:layout_height="match_parent" android:src="@drawable/ic_mikael_delete" android:padding="@dimen/padding_moderate" android:background="?attr/selectableItemBackground"/>
</LinearLayout>
EOF
cat > "$RES/layout/activity_pojav_launcher.xml" <<'EOF'
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:background="#0C0E12">
<LinearLayout android:id="@+id/mikael_header" android:layout_width="match_parent" android:layout_height="@dimen/_60sdp" android:orientation="horizontal" android:gravity="center_vertical" android:paddingStart="@dimen/_14sdp" android:paddingEnd="@dimen/_8sdp" android:background="@drawable/mikael_topbar" app:layout_constraintTop_toTopOf="parent">
<com.kdt.mcgui.mcAccountSpinner android:id="@+id/account_spinner" android:layout_width="0dp" android:layout_height="@dimen/_52sdp" android:layout_weight="1" android:background="@android:color/transparent" android:dropDownWidth="@dimen/_280sdp" android:dropDownVerticalOffset="@dimen/_4sdp"/>
<ImageButton android:id="@+id/setting_button" android:layout_width="@dimen/_52sdp" android:layout_height="@dimen/_52sdp" android:background="?attr/selectableItemBackgroundBorderless" android:src="@drawable/ic_mikael_settings" android:padding="@dimen/_11sdp" android:contentDescription="Ajustes"/>
</LinearLayout>
<androidx.fragment.app.FragmentContainerView android:id="@+id/container_fragment" android:layout_width="match_parent" android:layout_height="0dp" app:layout_constraintTop_toBottomOf="@id/mikael_header" app:layout_constraintBottom_toTopOf="@+id/progress_layout"/>
<com.kdt.mcgui.ProgressLayout android:id="@+id/progress_layout" android:layout_width="match_parent" android:layout_height="wrap_content" app:layout_constraintBottom_toBottomOf="parent"/>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/com/kdt/mcgui/mcAccountSpinner.java")
s=p.read_text().replace("R.drawable.ic_add", "R.drawable.mikael_add")
p.write_text(s)
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/LauncherActivity.java")
s=p.read_text().replace("R.drawable.ic_menu_settings : R.drawable.ic_menu_home", "R.drawable.ic_mikael_settings : R.drawable.ic_mikael_home")
p.write_text(s)
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text().replace(' android:drawableEnd="@drawable/spinner_arrow" app:drawableEndSize="@dimen/padding_heavy" app:drawableStartIntegerScaling="true" app:drawableStartSize="@dimen/_34sdp" app:drawableEndPadding="@dimen/_1sdp"','').replace(' android:src="@drawable/ic_edit_profile"','')
p.write_text(s)
PY


# Real FPS Booster settings.
mkdir -p "$RES/xml"
cat > "$RES/xml/pref_fps_booster.xml" <<'EOF'
<PreferenceScreen xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto">
    <net.kdt.pojavlaunch.prefs.BackButtonPreference/>
    <PreferenceCategory android:title="MIKAEL FPS BOOSTER">
        <androidx.preference.SwitchPreferenceCompat android:key="mikael_fps_booster_enabled" android:title="FPS Booster" android:summary="Ativa o perfil de desempenho do Mikael Launcher" android:defaultValue="false"/>
        <androidx.preference.SwitchPreferenceCompat android:key="mikael_sustained_performance" android:title="Desempenho sustentado" android:summary="Mantém o modo de desempenho sustentado durante a sessão" android:defaultValue="true"/>
        <androidx.preference.SwitchPreferenceCompat android:key="mikael_disable_vsync" android:title="Desativar VSync" android:summary="Pode reduzir latência e aumentar FPS, dependendo do aparelho" android:defaultValue="true"/>
        <androidx.preference.SeekBarPreference android:key="mikael_resolution" android:title="Resolução interna" android:summary="Reduz a resolução renderizada para ganhar FPS" android:min="50" android:max="100" android:defaultValue="75" app:showSeekBarValue="true"/>
    </PreferenceCategory>
</PreferenceScreen>
EOF
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/xml/pref_main.xml")
s=p.read_text()
needle='''<PreferenceCategory
        android:title="@string/preference_category_main_categories"
        >'''
pref='''<Preference
            android:key="mikael_fps_booster"
            android:title="FPS Booster"
            android:summary="Otimização de desempenho para Minecraft"
            android:fragment="net.kdt.pojavlaunch.prefs.screens.MikaelFpsBoosterFragment" />

        '''
if "key=\"mikael_fps_booster\"" not in s:
    s=s.replace(needle, needle+"\\n\\n        "+pref,1)
p.write_text(s)
PY
cat > "$ROOT/java/net/kdt/pojavlaunch/prefs/screens/MikaelFpsBoosterFragment.java" <<'EOF'
package net.kdt.pojavlaunch.prefs.screens;

import android.content.SharedPreferences;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.SwitchPreferenceCompat;
import androidx.preference.SeekBarPreference;
import net.kdt.pojavlaunch.R;

public class MikaelFpsBoosterFragment extends PreferenceFragmentCompat {
    private SharedPreferences prefs;

    @Override public void onCreatePreferences(@Nullable Bundle b, @Nullable String rootKey) {
        addPreferencesFromResource(R.xml.pref_fps_booster);
        prefs = getPreferenceManager().getSharedPreferences();
        SwitchPreferenceCompat booster = findPreference("mikael_fps_booster_enabled");
        SwitchPreferenceCompat sustained = findPreference("mikael_sustained_performance");
        SwitchPreferenceCompat vsync = findPreference("mikael_disable_vsync");
        SeekBarPreference resolution = findPreference("mikael_resolution");
        if (booster != null) booster.setOnPreferenceChangeListener((p,v) -> { apply((Boolean)v,sustained,vsync,resolution); return true; });
        if (sustained != null) sustained.setOnPreferenceChangeListener((p,v) -> { if (booster != null && booster.isChecked()) apply(true,sustained,vsync,resolution); return true; });
        if (vsync != null) vsync.setOnPreferenceChangeListener((p,v) -> { if (booster != null && booster.isChecked()) apply(true,sustained,vsync,resolution); return true; });
        if (resolution != null) resolution.setOnPreferenceChangeListener((p,v) -> { if (booster != null && booster.isChecked()) apply(true,sustained,vsync,resolution); return true; });
        if (prefs.getBoolean("mikael_fps_booster_enabled", false)) apply(true,sustained,vsync,resolution);
    }

    private void apply(boolean enabled, SwitchPreferenceCompat sustained, SwitchPreferenceCompat vsync, SeekBarPreference resolution) {
        SharedPreferences.Editor e=prefs.edit();
        if (!enabled) {
            e.putBoolean("sustainedPerformance",false).putBoolean("force_vsync",false).putInt("resolutionRatio",100);
        } else {
            e.putBoolean("sustainedPerformance",sustained==null || sustained.isChecked()).putBoolean("force_vsync",false);
            e.putInt("resolutionRatio",resolution==null?75:resolution.getValue());
        }
        e.apply();
    }
}
EOF
grep -q '<string name="app_name"' "$RES/values/strings.xml" && sed -i 's#<string name="app_name"[^<]*>[^<]*</string>#<string name="app_name" translatable="false">Mikael Launcher V3</string>#' "$RES/values/strings.xml"
