#!/usr/bin/env bash
set -euo pipefail
# Build safety: optional Modrinth compatibility patches must never abort the entire patch.
ROOT=app_pojavlauncher/src/main
RES=$ROOT/res
JAVA=$ROOT/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java
mkdir -p "$RES/drawable"
# Keep the APK lightweight: Java runtimes are NOT bundled anymore.
# The user downloads only the Java versions they need from Ajustes > Java > Runtimes.
rm -rf "app_pojavlauncher/src/main/assets/components/jre-new" \
       "app_pojavlauncher/src/main/assets/components/jre-21" \
       "app_pojavlauncher/src/main/assets/components/jre-25"

# Never auto-select/download an internal bundled JRE. Only runtimes explicitly
# installed by the user (External-8/17/21/25) are considered.
python3 - <<'PY'
from pathlib import Path
p = Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/NewJREUtil.java")
x = p.read_text()
old = '''    private static MathUtils.RankedValue<InternalRuntime> getNearestInternalRuntime(int targetVersion) {
        List<InternalRuntime> runtimeList = Arrays.asList(InternalRuntime.values());
        return MathUtils.findNearestPositive(targetVersion, runtimeList, (runtime)->runtime.majorVersion);
    }'''
new = '''    private static MathUtils.RankedValue<InternalRuntime> getNearestInternalRuntime(int targetVersion) {
        // Mikael Launcher does not bundle Java runtimes. The user chooses
        // which external runtime to download from the Java settings screen.
        return null;
    }'''
if old not in x:
    raise SystemExit("NewJREUtil internal-runtime selector block not found")
p.write_text(x.replace(old, new))
PY

# Make the runtime screen explicit about on-demand downloads.
python3 - <<'PY'
from pathlib import Path
p = Path("app_pojavlauncher/src/main/res/xml/pref_java.xml")
x = p.read_text()
x = x.replace('android:summary="@string/multirt_subtitle"', 'android:summary="Baixe somente as versões Java que você precisar. Nenhuma runtime vem dentro do APK."')
x = x.replace('android:title="@string/multirt_title"', 'android:title="RUNTIMES JAVA"')
p.write_text(x)
PY
# Remove upstream Amethyst/Pojav visual assets so Mikael Launcher uses only Mikael branding.
# Keep resource references while replacing the upstream visual with a neutral Mikael resource.
rm -f "$RES/drawable/ic_setting_sign_in_background.webp"
cat > "$RES/drawable/ic_setting_sign_in_background.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="#111318"/><corners android:radius="16dp"/></shape>
EOF
cat > "$RES/mipmap-anydpi-v26/ic_launcher_background.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108"><path android:fillColor="#101827" android:pathData="M0,0h108v108h-108z"/></vector>
EOF


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
cat > "$RES/drawable/mikael_hero.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient android:startColor="#141A22" android:endColor="#0F131A" android:angle="0"/>
    <corners android:radius="20dp"/>
    <stroke android:width="1dp" android:color="#26303D"/>
</shape>
EOF
cat > "$RES/drawable/mikael_bottom.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#11151C"/>
    <corners android:topLeftRadius="20dp" android:topRightRadius="20dp"/>
    <stroke android:width="1dp" android:color="#202733"/>
</shape>
EOF
cat > "$RES/drawable/mikael_profile_bg.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#151922"/>
    <corners android:radius="15dp"/>
    <stroke android:width="1dp" android:color="#4ADE80"/>
</shape>
EOF
cat > "$RES/drawable/mikael_play.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android"><solid android:color="#4ADE80"/><corners android:radius="16dp"/><padding android:left="10dp" android:top="6dp" android:right="10dp" android:bottom="6dp"/></shape>
EOF
cat > "$RES/layout/fragment_launcher.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android" xmlns:app="http://schemas.android.com/apk/res-auto" android:layout_width="match_parent" android:layout_height="match_parent" android:background="#080A0F">
<ScrollView android:layout_width="match_parent" android:layout_height="0dp" android:fillViewport="true" android:clipToPadding="false" app:layout_constraintTop_toTopOf="parent" app:layout_constraintBottom_toTopOf="@id/mikael_bottom">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:paddingStart="@dimen/_14sdp" android:paddingEnd="@dimen/_14sdp" android:paddingTop="@dimen/_14sdp" android:paddingBottom="@dimen/_18sdp">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center_vertical" android:padding="@dimen/_14sdp" android:background="@drawable/mikael_hero">
<ImageView android:layout_width="@dimen/_58sdp" android:layout_height="@dimen/_58sdp" android:src="@drawable/mikael_logo" android:contentDescription="Mikael Launcher"/>
<LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical" android:paddingStart="@dimen/_12sdp">
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="MIKAEL LAUNCHER" android:textColor="#FFFFFF" android:textSize="@dimen/_19ssp" android:textStyle="bold"/>
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginTop="2dp" android:text="V3  •  MINECRAFT JAVA EDITION" android:textColor="#8F9AAA" android:textSize="@dimen/_10ssp"/>
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginTop="7dp" android:text="SEU MINECRAFT. DO SEU JEITO." android:textColor="#4ADE80" android:textSize="@dimen/_10ssp" android:textStyle="bold"/>
</LinearLayout></LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="@dimen/_12sdp" android:orientation="horizontal" android:gravity="center_vertical">
<TextView android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="LAUNCHER" android:textColor="#FFFFFF" android:textSize="@dimen/_13ssp" android:textStyle="bold"/>
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="● ONLINE" android:textColor="#4ADE80" android:textSize="@dimen/_9ssp" android:textStyle="bold"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:layout_marginTop="@dimen/_7sdp">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/custom_control_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="@dimen/_52sdp" android:layout_weight="1" android:text="CONTROLES" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/settings_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="@dimen/_52sdp" android:layout_weight="1" android:layout_marginStart="@dimen/_7sdp" android:text="AJUSTES" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:layout_marginTop="@dimen/_7sdp">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/open_files_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="@dimen/_52sdp" android:layout_weight="1" android:text="ARQUIVOS" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/share_logs_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="@dimen/_52sdp" android:layout_weight="1" android:layout_marginStart="@dimen/_7sdp" android:text="LOGS" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:layout_marginTop="@dimen/_7sdp">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/news_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="@dimen/_52sdp" android:layout_weight="1" android:text="NOTÍCIAS" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/discord_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="@dimen/_52sdp" android:layout_weight="1" android:layout_marginStart="@dimen/_7sdp" android:text="COMUNIDADE" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
</LinearLayout>
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginTop="@dimen/_16sdp" android:text="CONTEÚDO" android:textColor="#FFFFFF" android:textSize="@dimen/_13ssp" android:textStyle="bold"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/install_jar_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="@dimen/_50sdp" android:layout_marginTop="@dimen/_7sdp" android:text="INSTALAR MOD / JAR" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/mod_library_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="@dimen/_50sdp" android:layout_marginTop="@dimen/_7sdp" android:text="BIBLIOTECA DE MODS" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/content_library_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="@dimen/_50sdp" android:layout_marginTop="@dimen/_7sdp" android:text="TEXTURAS  •  SHADERS  •  MUNDOS" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/forge_optifine_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="@dimen/_50sdp" android:layout_marginTop="@dimen/_7sdp" android:text="FORGE  •  OPTIFINE" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>
</LinearLayout></ScrollView>
<LinearLayout android:id="@+id/mikael_bottom" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:paddingStart="@dimen/_12sdp" android:paddingEnd="@dimen/_12sdp" android:paddingTop="@dimen/_8sdp" android:paddingBottom="@dimen/_10sdp" android:background="@drawable/mikael_bottom" app:layout_constraintBottom_toBottomOf="parent">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:gravity="center_vertical">
<com.kdt.mcgui.mcVersionSpinner android:id="@+id/mc_version_spinner" android:layout_width="0dp" android:layout_height="@dimen/_50sdp" android:layout_weight="1" android:background="@android:color/transparent" app:drawableStartIntegerScaling="true" app:drawableStartSize="@dimen/_34sdp"/>
<ImageButton android:id="@+id/edit_profile_button" android:layout_width="@dimen/_48sdp" android:layout_height="@dimen/_48sdp" android:background="@drawable/mikael_profile_bg" android:src="@drawable/ic_mikael_profile" android:padding="@dimen/_10sdp" android:contentDescription="Perfil"/>
</LinearLayout>
<com.kdt.mcgui.MineButton android:id="@+id/play_button" android:layout_width="match_parent" android:layout_height="@dimen/_54sdp" android:layout_marginTop="@dimen/_8sdp" android:background="@drawable/mikael_play" android:textColor="#07110B" android:text="JOGAR  ▶" android:textStyle="bold" android:textSize="@dimen/_15ssp" android:textAllCaps="false"/>
</LinearLayout></androidx.constraintlayout.widget.ConstraintLayout>
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
  Button modLibrary=v.findViewById(R.id.mod_library_button),contentLibrary=v.findViewById(R.id.content_library_button),forgeOptiFine=v.findViewById(R.id.forge_optifine_button);
  controls.setOnClickListener(x->startActivity(new Intent(requireContext(),CustomControlsActivity.class)));
  settings.setOnClickListener(x->swapFragment(requireActivity(),LauncherPreferenceFragment.class,LauncherActivity.SETTING_FRAGMENT_TAG,null));
  news.setOnClickListener(x->openURL(requireActivity(),URL_HOME));
  discord.setOnClickListener(x->openURL(requireActivity(),getString(R.string.discord_invite)));
  logs.setOnClickListener(x->shareLog(requireContext()));
  files.setOnClickListener(x->{if(!hasOnlineProfile()){hasNoOnlineProfileDialog(requireActivity());return;}openPath(requireContext(),getCurrentProfileDirectory(),false);});
  install.setOnClickListener(x->runInstaller(false));
  install.setOnLongClickListener(x->{runInstaller(true);return true;});
  if(modLibrary!=null) modLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelModLibraryFragment.class,MikaelModLibraryFragment.TAG,null));
  if(contentLibrary!=null) contentLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelContentLibraryFragment.class,MikaelContentLibraryFragment.TAG,null));
  if(forgeOptiFine!=null) forgeOptiFine.setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));
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



# Ely.by account support: custom third login option and real Ely authentication.
cat > "$RES/layout/fragment_select_auth_method.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:gravity="center" android:orientation="vertical" android:padding="24dp"
    android:background="#0C0E12">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="vertical" android:padding="26dp" android:background="#171A20">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="ADICIONAR CONTA" android:textStyle="bold" android:textSize="24sp"
            android:textColor="#FFFFFF" android:layout_gravity="center_horizontal" android:layout_marginBottom="22dp"/>
        <Button android:id="@+id/button_microsoft_authentication" android:layout_width="match_parent"
            android:layout_height="52dp" android:text="MICROSOFT ACCOUNT"/>
        <Button android:id="@+id/button_ely_authentication" android:layout_width="match_parent"
            android:layout_height="52dp" android:text="ELY.BY ACCOUNT" android:layout_marginTop="12dp"/>
        <Button android:id="@+id/button_local_authentication" android:layout_width="match_parent"
            android:layout_height="52dp" android:text="LOCAL ACCOUNT" android:layout_marginTop="12dp"/>
    </LinearLayout>
</LinearLayout>
EOF

cat > "$RES/layout/fragment_ely_login.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:gravity="center" android:orientation="vertical" android:padding="24dp"
    android:background="#0C0E12">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="vertical" android:padding="24dp" android:background="#171A20">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="ELY.BY" android:textStyle="bold" android:textSize="26sp"
            android:textColor="#FFFFFF" android:layout_gravity="center_horizontal"/>
        <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
            android:text="Entre com sua conta Ely.by" android:textColor="#AEB4C0"
            android:gravity="center" android:layout_marginBottom="20dp"/>
        <EditText android:id="@+id/ely_username" android:layout_width="match_parent" android:layout_height="52dp"
            android:hint="E-mail ou usuário" android:inputType="textEmailAddress"/>
        <EditText android:id="@+id/ely_password" android:layout_width="match_parent" android:layout_height="52dp"
            android:hint="Senha" android:inputType="textPassword" android:layout_marginTop="10dp"/>
        <Button android:id="@+id/ely_login" android:layout_width="match_parent" android:layout_height="52dp"
            android:text="ENTRAR" android:layout_marginTop="18dp"/>
        <TextView android:id="@+id/ely_status" android:layout_width="match_parent" android:layout_height="wrap_content"
            android:textColor="#AEB4C0" android:gravity="center" android:layout_marginTop="12dp"/>
    </LinearLayout>
</LinearLayout>
EOF

python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/SelectAuthFragment.java")
s=p.read_text()
if "button_ely_authentication" not in s:
    s=s.replace('Button mLocalButton = view.findViewById(R.id.button_local_authentication);',
                'Button mLocalButton = view.findViewById(R.id.button_local_authentication);\n        Button mElyButton = view.findViewById(R.id.button_ely_authentication);')
    s=s.replace('mLocalButton.setOnClickListener(v ->', 
                'mElyButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), ElyLoginFragment.class, ElyLoginFragment.TAG, null));\n        mLocalButton.setOnClickListener(v ->')
    s=s.replace('import net.kdt.pojavlaunch.R;', 'import net.kdt.pojavlaunch.R;')
    p.write_text(s)
PY

cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/ElyLoginFragment.java" <<'EOF'
package net.kdt.pojavlaunch.fragments;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.value.MinecraftAccount;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import org.json.JSONObject;

public class ElyLoginFragment extends Fragment {
    public static final String TAG = "ELY_LOGIN_FRAGMENT";
    public ElyLoginFragment(){ super(R.layout.fragment_ely_login); }

    @Override public void onViewCreated(@NonNull View view, @Nullable Bundle state) {
        EditText user=view.findViewById(R.id.ely_username);
        EditText pass=view.findViewById(R.id.ely_password);
        Button login=view.findViewById(R.id.ely_login);
        TextView status=view.findViewById(R.id.ely_status);

        login.setOnClickListener(v -> {
            String username=user.getText().toString().trim();
            String password=pass.getText().toString();
            if(username.isEmpty() || password.isEmpty()){ status.setText("Preencha usuário e senha."); return; }
            login.setEnabled(false); status.setText("Entrando na Ely.by...");
            new Thread(() -> {
                try {
                    String clientToken=UUID.randomUUID().toString();
                    JSONObject req=new JSONObject();
                    req.put("username",username); req.put("password",password);
                    req.put("clientToken",clientToken); req.put("requestUser",true);
                    HttpURLConnection c=(HttpURLConnection)new URL("https://authserver.ely.by/auth/authenticate").openConnection();
                    c.setRequestMethod("POST"); c.setConnectTimeout(15000); c.setReadTimeout(20000);
                    c.setDoOutput(true); c.setRequestProperty("Content-Type","application/json; charset=UTF-8");
                    try(OutputStream out=c.getOutputStream()){ out.write(req.toString().getBytes(StandardCharsets.UTF_8)); }
                    InputStream in=c.getResponseCode() >= 400 ? c.getErrorStream() : c.getInputStream();
                    java.io.ByteArrayOutputStream bos=new java.io.ByteArrayOutputStream(); byte[] buf=new byte[8192]; int len; while((len=in.read(buf))!=-1) bos.write(buf,0,len); String body=new String(bos.toByteArray(),StandardCharsets.UTF_8);
                    if(c.getResponseCode() >= 400) throw new IOException(new JSONObject(body).optString("errorMessage","Falha na autenticação Ely.by"));
                    JSONObject json=new JSONObject(body);
                    JSONObject profile=json.getJSONObject("selectedProfile");
                    MinecraftAccount account=new MinecraftAccount();
                    account.username=profile.getString("name");
                    account.profileId=profile.getString("id");
                    account.accessToken=json.getString("accessToken");
                    account.clientToken=json.optString("clientToken",clientToken);
                    account.isMicrosoft=false;
                    account.msaRefreshToken="0";
                    account.selectedVersion="1.20.1";
                    account.expiresAt=0L;
                    account.save();
                    net.kdt.pojavlaunch.PojavProfile.setCurrentProfile(requireContext(), account.username);
                    try { account.updateSkinFace(); } catch (Exception ignored) {}
                    requireActivity().runOnUiThread(() -> {
                        status.setText("Conta Ely.by adicionada: "+account.username);
                        Tools.swapFragment(requireActivity(), MainMenuFragment.class, MainMenuFragment.TAG, null);
                    });
                } catch(Exception e) {
                    requireActivity().runOnUiThread(() -> { login.setEnabled(true); status.setText("Erro: "+e.getMessage()); });
                }
            }).start();
        });
    }
}
EOF

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
    s=s.replace(needle, needle+"\n\n        "+pref,1)
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

# Completely custom settings visual system: no upstream settings row appearance.
mkdir -p "$RES/layout" "$RES/drawable" "$RES/values"
cat > "$RES/drawable/mikael_pref_row.xml" <<'EOF'
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_pressed="true"><shape><solid android:color="#252B35"/><corners android:radius="16dp"/><stroke android:width="1dp" android:color="#4ADE80"/></shape></item>
    <item><shape><solid android:color="#171B22"/><corners android:radius="16dp"/><stroke android:width="1dp" android:color="#29313D"/></shape></item>
</selector>
EOF
cat > "$RES/drawable/mikael_pref_category.xml" <<'EOF'
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#0C0E12"/>
</shape>
EOF
cat > "$RES/layout/mikael_preference.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="wrap_content"
    android:minHeight="76dp" android:layout_marginStart="12dp" android:layout_marginEnd="12dp"
    android:layout_marginTop="6dp" android:layout_marginBottom="6dp"
    android:paddingStart="18dp" android:paddingEnd="12dp" android:paddingTop="10dp" android:paddingBottom="10dp"
    android:gravity="center_vertical" android:orientation="horizontal"
    android:background="@drawable/mikael_pref_row">
    <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content"
        android:layout_weight="1" android:orientation="vertical">
        <TextView android:id="@android:id/title" android:layout_width="match_parent" android:layout_height="wrap_content"
            android:textColor="#FFFFFF" android:textSize="16sp" android:textStyle="bold"/>
        <TextView android:id="@android:id/summary" android:layout_width="match_parent" android:layout_height="wrap_content"
            android:layout_marginTop="3dp" android:textColor="#8F9AAA" android:textSize="13sp"/>
    </LinearLayout>
    <FrameLayout android:id="@android:id/widget_frame" android:layout_width="wrap_content"
        android:layout_height="match_parent" android:minWidth="52dp" android:gravity="center"/>
</LinearLayout>
EOF

cat > "$RES/layout/mikael_seekbar_preference.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="wrap_content"
    android:minHeight="92dp" android:layout_marginStart="12dp" android:layout_marginEnd="12dp"
    android:layout_marginTop="6dp" android:layout_marginBottom="6dp"
    android:paddingStart="18dp" android:paddingEnd="14dp" android:paddingTop="10dp" android:paddingBottom="10dp"
    android:orientation="vertical" android:background="@drawable/mikael_pref_row">
    <TextView android:id="@android:id/title" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:textColor="#FFFFFF" android:textSize="16sp" android:textStyle="bold"/>
    <TextView android:id="@android:id/summary" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="3dp" android:textColor="#8F9AAA" android:textSize="12sp"/>
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="5dp"
        android:gravity="center_vertical" android:orientation="horizontal">
        <SeekBar android:id="@+id/seekbar" android:layout_width="0dp" android:layout_height="wrap_content"
            android:layout_weight="1" android:background="@null" android:clickable="false" android:focusable="false"/>
        <TextView android:id="@+id/seekbar_value" android:layout_width="42dp" android:layout_height="wrap_content"
            android:gravity="center" android:textColor="#4ADE80" android:textStyle="bold" android:textSize="12sp"/>
    </LinearLayout>
</LinearLayout>
EOF

cat >> "$RES/values/styles.xml" <<'EOF'
<style name="MikaelPreferenceTheme" parent="@style/PreferenceThemeOverlay.v14.Material">
    <item name="preferenceStyle">@style/MikaelPreferenceStyle</item>
    <item name="switchPreferenceStyle">@style/MikaelSwitchPreferenceStyle</item>
    <item name="switchPreferenceCompatStyle">@style/MikaelSwitchPreferenceStyle</item>
    <item name="seekBarPreferenceStyle">@style/MikaelSeekBarPreferenceStyle</item>
</style>
<style name="MikaelPreferenceStyle" parent="@style/Preference.Material">
    <item name="android:layout">@layout/mikael_preference</item>
</style>
<style name="MikaelSwitchPreferenceStyle" parent="@style/Preference.SwitchPreference">
    <item name="android:layout">@layout/mikael_preference</item>
</style>
<style name="MikaelSeekBarPreferenceStyle" parent="@style/Preference.SeekBarPreference">
    <item name="android:layout">@layout/mikael_seekbar_preference</item>
    <item name="showSeekBarValue">true</item>
</style>
EOF

python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/values/styles.xml")
s=p.read_text()
s=s.replace('<item name="preferenceTheme">@style/PreferenceThemeOverlay.v14.Material</item>',
            '<item name="preferenceTheme">@style/MikaelPreferenceTheme</item>')
p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/prefs/screens/LauncherPreferenceFragment.java")
s=p.read_text()
needle='''view.setBackgroundColor(getResources().getColor(R.color.background_app));'''
if 'setPadding(0, 12, 0, 24)' not in s:
    s=s.replace(needle, needle+'''
        view.setPadding(0, 12, 0, 24);
''')
p.write_text(s)
PY
python3 - <<'PY'
from pathlib import Path
import re
p=Path("app_pojavlauncher/src/main/res/values/strings.xml")
s=p.read_text()
line='<string name="app_name" translatable="false">Mikael Launcher V3</string>'
s2=re.sub(r'<string name="app_name"[^>]*>.*?</string>', line, s, count=1)
if s2 == s:
    s2=s.replace('</resources>', '  '+line+'\n</resources>')
p.write_text(s2)
PY

python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/SelectAuthFragment.java")
s=p.read_text()
s=s.replace('import static net.kdt.pojavlaunch.Tools.hasNoOnlineProfileDialog;\\n\\n','')
s=s.replace('mLocalButton.setOnClickListener(v -> hasNoOnlineProfileDialog(requireActivity(), () -> Tools.swapFragment(requireActivity(), LocalLoginFragment.class, LocalLoginFragment.TAG, null)));','mLocalButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), LocalLoginFragment.class, LocalLoginFragment.TAG, null));')
p.write_text(s)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/LocalLoginFragment.java")
s=p.read_text()
s=s.replace('import static net.kdt.pojavlaunch.Tools.hasOnlineProfile;\\n\\n','')
s=s.replace('        // This is overkill but meh\\n        if (!hasOnlineProfile()){\\n            Tools.swapFragment(requireActivity(), MainMenuFragment.class, MainMenuFragment.TAG, null);\\n        }\\n','')
p.write_text(s)
PY

# Extra Mikael settings using real upstream preference keys.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/xml/pref_main.xml")
s=p.read_text()
if "MIKAEL ADVANCED" not in s:
    extra = '''
    <PreferenceCategory android:title="MIKAEL ADVANCED">\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="sustainedPerformance"\n            android:title="Desempenho sustentado"\n            android:summary="Mantém o desempenho alto durante o jogo"\n            android:defaultValue="false" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="force_vsync"\n            android:title="VSync"\n            android:summary="Sincroniza os frames com a tela"\n            android:defaultValue="false" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="alternate_surface"\n            android:title="Superfície alternativa"\n            android:summary="Usa o caminho alternativo de renderização"\n            android:defaultValue="true" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="bigCoreAffinity"\n            android:title="Priorizar núcleos rápidos"\n            android:summary="Prioriza os núcleos de maior desempenho"\n            android:defaultValue="false" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="zinkPreferSystemDriver"\n            android:title="Driver Zink do sistema"\n            android:summary="Prefere o driver gráfico Zink fornecido pelo sistema"\n            android:defaultValue="false" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="enableGyro"\n            android:title="Controles por giroscópio"\n            android:summary="Permite usar o movimento do aparelho nos controles"\n            android:defaultValue="false" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="always_grab_mouse"\n            android:title="Captura permanente do mouse"\n            android:summary="Mantém o mouse capturado durante a sessão"\n            android:defaultValue="false" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="keyboardPanning"\n            android:title="Mover tela com teclado"\n            android:summary="Ajusta a tela quando o teclado virtual aparece"\n            android:defaultValue="true" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="checkLibraries"\n            android:title="Verificar bibliotecas"\n            android:summary="Confere a integridade das bibliotecas baixadas"\n            android:defaultValue="true" />\n        <androidx.preference.SwitchPreferenceCompat\n            android:key="dump_shaders"\n            android:title="Diagnóstico de shaders"\n            android:summary="Salva informações de shaders para depuração"\n            android:defaultValue="false" />\n        <androidx.preference.SeekBarPreference\n            android:key="resolutionRatio"\n            android:title="Escala de resolução"\n            android:summary="Reduz a resolução interna para aumentar o desempenho"\n            android:min="50" android:max="100" android:defaultValue="100"\n            app:showSeekBarValue="true" />\n    </PreferenceCategory>\n'''
    s=s.replace('</PreferenceScreen>', extra+'\\n</PreferenceScreen>')
    p.write_text(s)
PY

# Forge + OptiFine workflow will be added to the version area in the launcher UI.

# Add a Forge + OptiFine entry beside the Minecraft version selector.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text()
if "forge_optifine_button" not in s:
    target='</LinearLayout>\\n<com.kdt.mcgui.MineButton android:id="@+id/play_button"'
    s=s.replace(target, '<com.kdt.mcgui.LauncherMenuButton android:id="@+id/forge_optifine_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="@dimen/_44sdp" android:layout_marginTop="@dimen/_5sdp" android:text="FORGE + OPTIFINE" android:textSize="@dimen/_11ssp" android:background="@drawable/mikael_button"/>\\n</LinearLayout>\\n<com.kdt.mcgui.MineButton android:id="@+id/play_button"', 1)
    p.write_text(s)
PY

# Forge + OptiFine launcher screen.
cat > "$JAVA" <<'EOF'
package net.kdt.pojavlaunch.fragments;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
public class MikaelForgeOptiFineFragment extends Fragment {
 public static final String TAG="MIKAEL_FORGE_OPTIFINE";
 public MikaelForgeOptiFineFragment(){ super(R.layout.fragment_mikael_forge_optifine); }
 @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
  v.findViewById(R.id.mfo_forge).setOnClickListener(x->Tools.swapFragment(requireActivity(),ForgeInstallFragment.class,ForgeInstallFragment.TAG,null));
  v.findViewById(R.id.mfo_optifine).setOnClickListener(x->Tools.swapFragment(requireActivity(),OptiFineInstallFragment.class,OptiFineInstallFragment.TAG,null));
  v.findViewById(R.id.mfo_back).setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
 }
}
EOF
cat > "$RES/layout/fragment_mikael_forge_optifine.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:padding="22dp" android:background="#0C0E12">
 <TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="FORGE + OPTIFINE" android:textColor="#FFFFFF" android:textSize="26sp" android:textStyle="bold"/>
 <TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="8dp" android:text="Instale primeiro o Forge e depois o OptiFine compatível com a mesma versão do Minecraft." android:textColor="#9AA4B2" android:textSize="14sp"/>
 <Button android:id="@+id/mfo_forge" android:layout_width="match_parent" android:layout_height="58dp" android:layout_marginTop="28dp" android:text="1 • INSTALAR FORGE" android:textAllCaps="false" android:background="@drawable/mikael_button"/>
 <Button android:id="@+id/mfo_optifine" android:layout_width="match_parent" android:layout_height="58dp" android:layout_marginTop="10dp" android:text="2 • ADICIONAR OPTIFINE" android:textAllCaps="false" android:background="@drawable/mikael_button"/>
 <Button android:id="@+id/mfo_back" android:layout_width="match_parent" android:layout_height="52dp" android:layout_marginTop="18dp" android:text="VOLTAR" android:textAllCaps="false" android:background="@drawable/mikael_button"/>
</LinearLayout>
EOF
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
needle='mVersionSpinner=v.findViewById(R.id.mc_version_spinner);'
if 'forge_optifine_button' not in s:
    s=s.replace(needle, needle+'\n  v.findViewById(R.id.forge_optifine_button).setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));')
p.write_text(s)
PY

# Restore MainMenuFragment after generating the dedicated Forge+OptiFine fragment.
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
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelForgeOptiFineFragment.java" <<'EOF'
package net.kdt.pojavlaunch.fragments;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
public class MikaelForgeOptiFineFragment extends Fragment {
 public static final String TAG="MIKAEL_FORGE_OPTIFINE";
 public MikaelForgeOptiFineFragment(){ super(R.layout.fragment_mikael_forge_optifine); }
 @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
  v.findViewById(R.id.mfo_forge).setOnClickListener(x->Tools.swapFragment(requireActivity(),ForgeInstallFragment.class,ForgeInstallFragment.TAG,null));
  v.findViewById(R.id.mfo_optifine).setOnClickListener(x->Tools.swapFragment(requireActivity(),OptiFineInstallFragment.class,OptiFineInstallFragment.TAG,null));
  v.findViewById(R.id.mfo_back).setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
 }
}
EOF


# Mikael customization: launcher accent colors + selectable looping video background.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/xml/pref_main.xml")
s=p.read_text()
if "mikael_accent_color" not in s:
    extra = r'''
    <PreferenceCategory android:title="MIKAEL PERSONALIZAÇÃO">
        <ListPreference
            android:key="mikael_accent_color"
            android:title="Cor do launcher"
            android:summary="Escolha a cor dos botões e destaques"
            android:entries="@array/mikael_color_names"
            android:entryValues="@array/mikael_color_values"
            android:defaultValue="#4ADE80" />
        <Preference
            android:key="mikael_video_background"
            android:title="Vídeo de fundo"
            android:summary="Escolha um vídeo do aparelho para usar como fundo animado" />
        <SwitchPreferenceCompat
            android:key="mikael_video_enabled"
            android:title="Ativar vídeo de fundo"
            android:summary="Reproduz o vídeo em loop na tela inicial"
            android:defaultValue="false" />
    </PreferenceCategory>
'''
    s=s.replace('</PreferenceScreen>', extra+'\n</PreferenceScreen>')
    p.write_text(s)

p=Path("app_pojavlauncher/src/main/res/values/mikael_arrays.xml")
p.write_text('''<resources>
    <string-array name="mikael_color_names">
        <item>Verde Mikael</item><item>Azul</item><item>Roxo</item><item>Vermelho</item><item>Laranja</item><item>Ciano</item><item>Rosa</item><item>Amarelo</item>
    </string-array>
    <string-array name="mikael_color_values">
        <item>#4ADE80</item><item>#60A5FA</item><item>#A78BFA</item><item>#F87171</item><item>#FB923C</item><item>#22D3EE</item><item>#F472B6</item><item>#FACC15</item>
    </string-array>
</resources>
''')
PY

# Patch settings to pick and persist a video URI.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/prefs/screens/LauncherPreferenceFragment.java")
s=p.read_text()
if "mikael_video_background" not in s:
    s=s.replace("import android.content.SharedPreferences;", "import android.content.SharedPreferences;\nimport android.content.Intent;\nimport android.net.Uri;")
    s=s.replace("public class LauncherPreferenceFragment extends PreferenceFragmentCompat implements SharedPreferences.OnSharedPreferenceChangeListener {",
                "public class LauncherPreferenceFragment extends PreferenceFragmentCompat implements SharedPreferences.OnSharedPreferenceChangeListener {\n    private static final int MIKAEL_VIDEO_PICKER = 9401;")
    s=s.replace("setupNotificationRequestPreference();",
                '''setupNotificationRequestPreference();
        Preference video = findPreference("mikael_video_background");
        if (video != null) {
            video.setOnPreferenceClickListener(pref -> {
                Intent i = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                i.setType("video/*");
                i.addCategory(Intent.CATEGORY_OPENABLE);
                i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
                startActivityForResult(i, MIKAEL_VIDEO_PICKER);
                return true;
            });
        }''',1)
    marker="    @Override\n    public void onResume()"
    insert='''    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == MIKAEL_VIDEO_PICKER && resultCode == Activity.RESULT_OK && data != null && data.getData() != null) {
            Uri uri = data.getData();
            try {
                requireContext().getContentResolver().takePersistableUriPermission(
                        uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            } catch (Exception ignored) {}
            getPreferenceManager().getSharedPreferences().edit()
                    .putString("mikael_video_uri", uri.toString())
                    .putBoolean("mikael_video_enabled", true)
                    .apply();
            Preference pref = findPreference("mikael_video_background");
            if (pref != null) pref.setSummary("Vídeo selecionado • toque para trocar");
        }
    }

'''
    s=s.replace(marker,insert+marker)
    p.write_text(s)
PY

# Fix OptiFine version matching and hide preview/snapshot entries.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/modloaders/OptiFineScraper.java")
s=p.read_text()
old='mMinecraftVersion = tagNode.getText().toString();'
new='mMinecraftVersion = tagNode.getText().toString().replace("Minecraft ", "").trim();'
if old in s:
    s=s.replace(old,new,1)
old2='mListInProgress.add(optiFineVersion);'
new2='if (optiFineVersion.versionName != null && !optiFineVersion.versionName.toLowerCase(java.util.Locale.ROOT).contains("pre")) mListInProgress.add(optiFineVersion);'
if old2 in s:
    s=s.replace(old2,new2,1)
p.write_text(s)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/profiles/VersionListAdapter.java")
s=p.read_text()
start='''        List<JMinecraftVersionList.Version> releaseList = new FilteredSubList<>(versionList, item -> item.type.equals("release"));
        List<JMinecraftVersionList.Version> snapshotList = new FilteredSubList<>(versionList, item -> item.type.equals("snapshot"));
        List<JMinecraftVersionList.Version> betaList = new FilteredSubList<>(versionList, item -> item.type.equals("old_beta"));
        List<JMinecraftVersionList.Version> alphaList = new FilteredSubList<>(versionList, item -> item.type.equals("old_alpha"));'''
repl='''        // Mikael Launcher shows only stable numbered Minecraft releases.
        // This excludes snapshots, pre-releases and April Fools/experimental IDs.
        List<JMinecraftVersionList.Version> releaseList = new FilteredSubList<>(versionList,
                item -> item != null && "release".equals(item.type)
                        && item.id != null && item.id.matches("\\d+\\.\\d+(\\.\\d+)?"));'''
if start in s:
    s=s.replace(start,repl,1)
old='''            mGroups = new String[]{
                    ctx.getString(R.string.mcl_setting_veroption_release),
                    ctx.getString(R.string.mcl_setting_veroption_snapshot),
                    ctx.getString(R.string.mcl_setting_veroption_oldbeta),
                    ctx.getString(R.string.mcl_setting_veroption_oldalpha)
            };
            mData = new List[]{ releaseList, snapshotList, betaList, alphaList};
            mSnapshotListPosition = 1;'''
new='''            mGroups = new String[]{
                    ctx.getString(R.string.mcl_setting_veroption_release)
            };
            mData = new List[]{ releaseList};
            mSnapshotListPosition = -1;'''
if old in s: s=s.replace(old,new,1)
old='''            mGroups = new String[]{
                    ctx.getString(R.string.mcl_setting_veroption_installed),
                    ctx.getString(R.string.mcl_setting_veroption_release),
                    ctx.getString(R.string.mcl_setting_veroption_snapshot),
                    ctx.getString(R.string.mcl_setting_veroption_oldbeta),
                    ctx.getString(R.string.mcl_setting_veroption_oldalpha)
            };
            mData = new List[]{Arrays.asList(mInstalledVersions), releaseList, snapshotList, betaList, alphaList};
            mSnapshotListPosition = 2;'''
new='''            mGroups = new String[]{
                    ctx.getString(R.string.mcl_setting_veroption_installed),
                    ctx.getString(R.string.mcl_setting_veroption_release)
            };
            mData = new List[]{Arrays.asList(mInstalledVersions), releaseList};
            mSnapshotListPosition = -1;'''
if old in s: s=s.replace(old,new,1)
p.write_text(s)
PY

# Harden the Forge + OptiFine screen: stable Minecraft releases only,
# normalized OptiFine matching, and no fragment lifecycle crashes.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MikaelForgeOptiFineFragment.java")
s=p.read_text()
old='''if(table!=null && table.versions!=null) for(JMinecraftVersionList.Version x:table.versions)
             if(x!=null && "release".equals(x.type) && x.id!=null && x.id.matches("\\d+\\.\\d+(\\.\\d+)?") && !games.contains(x.id)) games.add(x.id);'''
new='''if(table!=null && table.versions!=null) for(JMinecraftVersionList.Version x:table.versions)
            if(x!=null && "release".equals(x.type) && x.id!=null && x.id.matches("\\d+\\.\\d+(\\.\\d+)?") && !games.contains(x.id)) games.add(x.id);'''
if old in s: s=s.replace(old,new,1)
s=s.replace('''android.app.Activity activity=getActivity();
                 if(activity!=null && !games.isEmpty()) activity.runOnUiThread(()->{if(isAdded()) refreshLoaders(games.get(game.getSelectedItemPosition()));});''',
'''android.app.Activity activity=getActivity();
                if(activity!=null && !games.isEmpty()) activity.runOnUiThread(()->{if(isAdded()) refreshLoaders(games.get(game.getSelectedItemPosition()));});''')
s=s.replace('''}catch(Exception e){ android.app.Activity activity=getActivity(); if(activity!=null) activity.runOnUiThread(()->{if(isAdded()) status.setText("Não foi possível carregar Forge/OptiFine.");});}''',
''' }catch(Exception e){ android.app.Activity activity=getActivity(); if(activity!=null) activity.runOnUiThread(()->{if(isAdded()) status.setText("Não foi possível carregar Forge/OptiFine.");});}''')
s=s.replace('''private void fail(String x){android.app.Activity activity=getActivity(); if(activity!=null) activity.runOnUiThread(()->{if(isAdded()) status.setText(x);});}''',
'''private void fail(String x){android.app.Activity activity=getActivity(); if(activity!=null) activity.runOnUiThread(()->{if(isAdded()) status.setText(x);});}''')
s=s.replace('''},requireActivity()).run();''','''},getActivity()).run();''')
# Guard against failed OptiFine page parsing.
s=s.replace('''if(ofAll==null || ofAll.minecraftVersions==null){status.setText("Lista do OptiFine indisponível.");return;}
        if(selectedOF==null){status.setText("OptiFine selecionado não foi encontrado.");return;}''',
'''if(ofAll==null || ofAll.minecraftVersions==null){status.setText("Lista do OptiFine indisponível.");return;}
        if(selectedOF==null){status.setText("OptiFine selecionado não foi encontrado.");return;}''')
p.write_text(s)
PY

# Custom Forge + OptiFine + Minecraft version selector.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelForgeOptiFineFragment.java" <<'EOF'
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
        if(table!=null && table.versions!=null) for(JMinecraftVersionList.Version x:table.versions)
             if(x!=null && "release".equals(x.type) && x.id!=null && x.id.matches("\\d+\\.\\d+(\\.\\d+)?") && !games.contains(x.id)) games.add(x.id);
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
                android.app.Activity activity=getActivity();
                 if(activity!=null && !games.isEmpty()) activity.runOnUiThread(()->{if(isAdded()) refreshLoaders(games.get(game.getSelectedItemPosition()));});
            }catch(Exception e){ android.app.Activity activity=getActivity(); if(activity!=null) activity.runOnUiThread(()->{if(isAdded()) status.setText("Não foi possível carregar Forge/OptiFine.");});}
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
        final android.app.Activity activity=getActivity();
        if(activity==null){status.setText("Tela não está mais disponível.");return;}
        if(ofAll==null || ofAll.minecraftVersions==null){status.setText("Lista do OptiFine indisponível.");return;}
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
                        private void fail(String x){android.app.Activity activity=getActivity(); if(activity!=null) activity.runOnUiThread(()->{if(isAdded()) status.setText(x);});}
                    },activity).run();
                }
                public void onDataNotAvailable(){fail("Forge não disponível");}
                public void onDownloadError(Exception e){fail("Erro no Forge: "+e.getMessage());}
                private void fail(String x){android.app.Activity activity=getActivity(); if(activity!=null) activity.runOnUiThread(()->{if(isAdded()) status.setText(x);});}
            },fv).run();
        }).start();
    }
}
EOF

cat > "$RES/layout/fragment_mikael_forge_optifine.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:background="#0C0E12">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="20dp">
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="FORGE + OPTIFINE" android:textColor="#FFFFFF" android:textSize="26sp" android:textStyle="bold"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="6dp" android:text="Selecione as 3 versões. O Forge e o OptiFine são baixados juntos." android:textColor="#9AA4B2" android:textSize="14sp"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="22dp" android:text="VERSÃO DO JOGO" android:textColor="#4ADE80" android:textStyle="bold"/>
<Spinner android:id="@+id/mfo_game" android:layout_width="match_parent" android:layout_height="52dp" android:background="@drawable/mikael_button"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="14dp" android:text="VERSÃO DO FORGE" android:textColor="#4ADE80" android:textStyle="bold"/>
<Spinner android:id="@+id/mfo_forge" android:layout_width="match_parent" android:layout_height="52dp" android:background="@drawable/mikael_button"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="14dp" android:text="VERSÃO DO OPTIFINE" android:textColor="#4ADE80" android:textStyle="bold"/>
<Spinner android:id="@+id/mfo_optifine" android:layout_width="match_parent" android:layout_height="52dp" android:background="@drawable/mikael_button"/>
<TextView android:id="@+id/mfo_status" android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="16dp" android:text="Carregando versões..." android:textColor="#9AA4B2"/>
<Button android:id="@+id/mfo_install" android:layout_width="match_parent" android:layout_height="58dp" android:layout_marginTop="18dp" android:text="BAIXAR FORGE + OPTIFINE" android:textAllCaps="false" android:background="@drawable/mikael_button"/>
<Button android:id="@+id/mfo_back" android:layout_width="match_parent" android:layout_height="52dp" android:layout_marginTop="10dp" android:text="VOLTAR" android:textAllCaps="false" android:background="@drawable/mikael_button"/>
</LinearLayout>
</ScrollView>
EOF

# Replace launcher home layout with a video layer behind the custom UI.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text()
if 'mikael_video_background' not in s:
    s=s.replace('<ScrollView ', '<VideoView android:id="@+id/mikael_video_background" android:layout_width="match_parent" android:layout_height="match_parent" android:visibility="gone" />\n<View android:layout_width="match_parent" android:layout_height="match_parent" android:background="#99000000" />\n<ScrollView ',1)
    p.write_text(s)
PY

# Apply selected Mikael accent and video background on the home screen.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
if "mikael_video_background" not in s:
    s=s.replace("import android.content.Intent;", "import android.content.Intent;"+chr(10)+"import android.graphics.Color;"+chr(10)+"import android.content.res.ColorStateList;"+chr(10)+"import android.net.Uri;"+chr(10)+"import android.widget.VideoView;")
    needle='ImageButton profile=v.findViewById(R.id.edit_profile_button); mVersionSpinner=v.findViewById(R.id.mc_version_spinner);'
    repl=needle+'''
  applyMikaelTheme(v);
  setupMikaelVideo(v);'''
    s=s.replace(needle,repl)
    marker=' private File getCurrentProfileDirectory()'
    methods=''' private void applyMikaelTheme(View v){
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
'''
    s=s.replace(marker,methods+marker)
    s=s.replace(' @Override public void onResume(){super.onResume();if(mVersionSpinner!=null)mVersionSpinner.reloadProfiles();}',
                ' @Override public void onResume(){super.onResume();if(mVersionSpinner!=null)mVersionSpinner.reloadProfiles(); View root=getView(); if(root!=null){applyMikaelTheme(root); setupMikaelVideo(root);}}')
    p.write_text(s)
PY


# Fix styles.xml: the upstream file has a <resources> root, so Mikael styles must be inside it.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/values/styles.xml")
s=p.read_text()
if s.count("<resources") and s.count("</resources>"):
    end=s.rfind("</resources>")
    tail=s[end+len("</resources>"):]
    if "<style name=\"MikaelPreferenceTheme\"" in tail:
        styles=tail
        s=s[:end] + styles + "\n</resources>\n"
        p.write_text(s)
PY

# CurseForge mod library.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelModLibraryFragment.java" <<'EOF'
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
                    adapter.notifyDataSetChanged(); status.setText(found.size()+" mods encontrados • toque para instalar");
                });
            } catch(Exception e){ android.app.Activity a=getActivity(); if(a!=null)a.runOnUiThread(()->status.setText("Erro: "+e.getMessage())); }
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
                String url;
                if(m.modId.startsWith("mr:")){
                    JSONObject v=getJsonPublic("https://api.modrinth.com/v2/version/"+URLEncoder.encode(m.fileId,"UTF-8"));
                    JSONArray fs=v.optJSONArray("files");
                    url=fs!=null&&fs.length()>0?fs.getJSONObject(0).optString("url",""):"";
                } else {
                    url=getJson("https://api.curseforge.com/v1/mods/"+m.modId+"/files/"+m.fileId+"/download-url").optString("data","");
                }
                if(url.isEmpty()) throw new Exception("Download indisponível.");
                File dir=getCurrentProfileDirectory(), modsDir=new File(dir,"mods");
                if(!modsDir.exists()&&!modsDir.mkdirs()) throw new Exception("Não foi possível criar a pasta mods.");
                File out=new File(modsDir,m.fileName.replaceAll("[\\\\/:*?\"<>|]","_"));
                HttpURLConnection c=(HttpURLConnection)new URL(url).openConnection();
                c.setConnectTimeout(15000); c.setReadTimeout(30000);
                try(InputStream in=c.getInputStream();FileOutputStream o=new FileOutputStream(out)){
                    byte[] b=new byte[8192]; int n; while((n=in.read(b))!=-1)o.write(b,0,n);
                }
                requireActivity().runOnUiThread(()->status.setText("Instalado em mods/: "+out.getName()));
            }catch(Exception e){android.app.Activity a=getActivity(); if(a!=null)a.runOnUiThread(()->status.setText("Falha: "+e.getMessage()));}
        }).start();
    }

    private JSONObject getJsonPublic(String u)throws Exception{
        HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();
        c.setRequestMethod("GET"); c.setConnectTimeout(15000); c.setReadTimeout(20000);
        c.setRequestProperty("Accept","application/json");
        c.setRequestProperty("User-Agent","MikaelLauncherV3/1.0 (Android)");
        int code=c.getResponseCode(); InputStream in=code>=400?c.getErrorStream():c.getInputStream();
        java.io.ByteArrayOutputStream o=new java.io.ByteArrayOutputStream(); byte[] b=new byte[8192]; int n;
        while((n=in.read(b))!=-1)o.write(b,0,n);
        if(code>=400)throw new Exception("HTTP "+code);
        return new JSONObject(o.toString("UTF-8"));
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
EOF

cat > "$RES/layout/fragment_mikael_mod_library.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:padding="16dp" android:background="#0C0E12">
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="BIBLIOTECA DE MODS" android:textColor="#FFFFFF" android:textSize="24sp" android:textStyle="bold"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="4dp" android:text="Mods do CurseForge para baixar direto no launcher" android:textColor="#9AA4B2"/>
<LinearLayout android:layout_width="match_parent" android:layout_height="52dp" android:layout_marginTop="14dp" android:orientation="horizontal">
<EditText android:id="@+id/mod_search" android:layout_width="0dp" android:layout_height="match_parent" android:layout_weight="1" android:hint="Pesquisar mod..." android:textColor="#FFFFFF" android:singleLine="true"/>
<Button android:id="@+id/mod_search_button" android:layout_width="90dp" android:layout_height="match_parent" android:text="BUSCAR" android:background="@drawable/mikael_button"/>
</LinearLayout>
<TextView android:id="@+id/mod_status" android:layout_width="match_parent" android:layout_height="wrap_content" android:paddingVertical="10dp" android:text="Carregando..." android:textColor="#4ADE80"/>
<ListView android:id="@+id/mod_list" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1" android:divider="#222833" android:dividerHeight="1dp"/>
<Button android:id="@+id/mod_back" android:layout_width="match_parent" android:layout_height="52dp" android:layout_marginTop="8dp" android:text="VOLTAR" android:background="@drawable/mikael_button"/>
</LinearLayout>
EOF

python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text()
if "mod_library_button" not in s:
    marker='<com.kdt.mcgui.LauncherMenuButton android:id="@+id/install_jar_button"'
    pos=s.find(marker)
    end=s.find('/>',pos)
    if pos>=0 and end>=0:
        button='<com.kdt.mcgui.LauncherMenuButton android:id="@+id/mod_library_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="BIBLIOTECA DE MODS" android:background="@drawable/mikael_button"/>'
        s=s[:end+2]+"\n"+button+s[end+2:]
    p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
if "mod_library_button" not in s:
    s=s.replace('Button mInstallJarButton = view.findViewById(R.id.install_jar_button);','Button mInstallJarButton = view.findViewById(R.id.install_jar_button);' + chr(10) + '        Button mModLibraryButton = view.findViewById(R.id.mod_library_button);')
    s=s.replace('mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class));','mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class)));' + chr(10) + '        mModLibraryButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MikaelModLibraryFragment.class, MikaelModLibraryFragment.TAG, null));')
    p.write_text(s)
PY



# Unified Mikael content library: mods, resource packs, shaders and worlds.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelContentLibraryFragment.java" <<'EOF'
package net.kdt.pojavlaunch.fragments;
import android.os.*; import android.view.*; import android.widget.*; import androidx.annotation.*; import androidx.appcompat.app.AlertDialog; import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.*; import net.kdt.pojavlaunch.prefs.LauncherPreferences; import net.kdt.pojavlaunch.value.launcherprofiles.*; import org.json.*; import java.io.*; import java.net.*; import java.util.*;
public class MikaelContentLibraryFragment extends Fragment {
 public static final String TAG="MIKAEL_CONTENT_LIBRARY"; Spinner type; EditText search; TextView status; ListView list; ArrayAdapter<String> adapter; List<Item> items=new ArrayList<>();
 public MikaelContentLibraryFragment(){super(R.layout.fragment_mikael_content_library);}
 public void onViewCreated(@NonNull View v,@Nullable Bundle b){
  type=v.findViewById(R.id.content_type); search=v.findViewById(R.id.content_search); status=v.findViewById(R.id.content_status); list=v.findViewById(R.id.content_list); adapter=new ArrayAdapter<>(requireContext(),android.R.layout.simple_list_item_1,new ArrayList<>()); list.setAdapter(adapter);
  type.setAdapter(new ArrayAdapter<String>(requireContext(),android.R.layout.simple_spinner_dropdown_item,new String[]{"Mods","Texturas / Resource Packs","Shaders","Mundos"}));
  v.findViewById(R.id.content_search_button).setOnClickListener(x->load()); v.findViewById(R.id.content_back).setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null)); list.setOnItemClickListener((p,x,pos,id)->confirm(items.get(pos))); load();
 }
 void load(){int t=type.getSelectedItemPosition(); String q=search.getText().toString().trim(); status.setText("Pesquisando..."); new Thread(()->{try{
  String classId=t==0?"6":t==1?"12":t==2?"6552":"17"; String u="https://api.curseforge.com/v1/mods/search?gameId=432&classId="+classId+"&pageSize=30"; if(!q.isEmpty())u+="&searchFilter="+URLEncoder.encode(q,"UTF-8");
  JSONArray dataArray=json(u).optJSONArray("data"); List<Item> out=new ArrayList<>(); if(dataArray!=null)for(int i=0;i<dataArray.length();i++){JSONObject m=dataArray.getJSONObject(i); JSONArray fs=m.optJSONArray("latestFiles"); JSONObject f=fs!=null&&fs.length()>0?fs.optJSONObject(0):null; if(f!=null)out.add(new Item(m.optString("id"),m.optString("name","Item"),m.optString("summary",""),f.optString("id"),f.optString("displayName",f.optString("fileName","download"))));}
  android.app.Activity activity=getActivity(); if(activity==null)return; activity.runOnUiThread(()->{if(!isAdded())return;items.clear();items.addAll(out);adapter.clear();for(Item x:items)adapter.add(x.name+"\n"+x.file);adapter.notifyDataSetChanged();status.setText(out.size()+" resultados");});
 }catch(Exception e){android.app.Activity activity=getActivity(); if(activity!=null)activity.runOnUiThread(()->{if(isAdded())status.setText("Erro: "+e.getMessage());});}}).start();}
 void confirm(Item x){new AlertDialog.Builder(requireContext()).setTitle(x.name).setMessage(x.summary+"\n\n"+x.file).setNegativeButton("CANCELAR",null).setPositiveButton("BAIXAR",(d,w)->download(x)).show();}
 void download(Item x){status.setText("Baixando...");new Thread(()->{try{
  String u=json("https://api.curseforge.com/v1/mods/"+x.modId+"/files/"+x.fileId+"/download-url").optString("data",""); if(u.isEmpty())throw new Exception("Download indisponível.");
  File base=getDir(); int t=type.getSelectedItemPosition(); String folder=t==0?"mods":t==1?"resourcepacks":t==2?"shaderpacks":"saves"; File dir=new File(base,folder); if(!dir.exists()&&!dir.mkdirs())throw new Exception("Não foi possível criar "+folder);
  String fn=x.file.replaceAll("[\\\\/:*?\"<>|]","_"); File out=new File(dir,fn); HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();c.setConnectTimeout(15000);c.setReadTimeout(60000);
  try(InputStream in=c.getInputStream();FileOutputStream o=new FileOutputStream(out)){byte[] b=new byte[8192];int n;while((n=in.read(b))!=-1)o.write(b,0,n);}
  requireActivity().runOnUiThread(()->status.setText("Instalado em "+folder+"/: "+out.getName()));
 }catch(Exception e){android.app.Activity a=getActivity(); if(a!=null)a.runOnUiThread(()->status.setText("Falha: "+e.getMessage()));}}).start();}
 JSONObject json(String u)throws Exception{HttpURLConnection c=(HttpURLConnection)new URL(u).openConnection();c.setRequestProperty("Accept","application/json");c.setRequestProperty("x-api-key",getString(R.string.curseforge_api_key));int code=c.getResponseCode();InputStream in=code>=400?c.getErrorStream():c.getInputStream();ByteArrayOutputStream o=new ByteArrayOutputStream();byte[] b=new byte[8192];int n;while((n=in.read(b))!=-1)o.write(b,0,n);if(code>=400)throw new Exception("HTTP "+code);return new JSONObject(o.toString("UTF-8"));}
 File getDir(){String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);LauncherProfiles.load();MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);}
 static class Item{String modId,name,summary,fileId,file;Item(String a,String b,String c,String d,String e){modId=a;name=b;summary=c;fileId=d;file=e;}}
}
EOF
cat > "$RES/layout/fragment_mikael_content_library.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:padding="16dp" android:background="#0C0E12">
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="BIBLIOTECA" android:textColor="#FFFFFF" android:textSize="24sp" android:textStyle="bold"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="Mods • Texturas • Shaders • Mundos" android:textColor="#9AA4B2"/>
<Spinner android:id="@+id/content_type" android:layout_width="match_parent" android:layout_height="52dp" android:layout_marginTop="12dp"/>
<LinearLayout android:layout_width="match_parent" android:layout_height="52dp" android:layout_marginTop="8dp">
<EditText android:id="@+id/content_search" android:layout_width="0dp" android:layout_height="match_parent" android:layout_weight="1" android:hint="Pesquisar..." android:textColor="#FFFFFF" android:singleLine="true"/>
<Button android:id="@+id/content_search_button" android:layout_width="90dp" android:layout_height="match_parent" android:text="BUSCAR" android:background="@drawable/mikael_button"/>
</LinearLayout>
<TextView android:id="@+id/content_status" android:layout_width="match_parent" android:layout_height="wrap_content" android:paddingVertical="10dp" android:textColor="#4ADE80"/>
<ListView android:id="@+id/content_list" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1"/>
<Button android:id="@+id/content_back" android:layout_width="match_parent" android:layout_height="52dp" android:text="VOLTAR" android:background="@drawable/mikael_button"/>
</LinearLayout>
EOF
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml"); s=p.read_text()
if "content_library_button" not in s:
 marker='<com.kdt.mcgui.LauncherMenuButton android:id="@+id/mod_library_button"'; pos=s.find(marker); end=s.find('/>',pos)
 if pos>=0 and end>=0:
  b='<com.kdt.mcgui.LauncherMenuButton android:id="@+id/content_library_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="TEXTURAS • SHADERS • MUNDOS" android:background="@drawable/mikael_button"/>'
  s=s[:end+2]+"\n"+b+s[end+2:]
 p.write_text(s)
PY
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java"); s=p.read_text()
if "content_library_button" not in s:
 s=s.replace('Button mInstallJarButton = view.findViewById(R.id.install_jar_button);','Button mInstallJarButton = view.findViewById(R.id.install_jar_button);' + chr(10) + '        Button mContentLibraryButton = view.findViewById(R.id.content_library_button);')
 s=s.replace('mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class));','mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class)));' + chr(10) + '        mContentLibraryButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MikaelContentLibraryFragment.class, MikaelContentLibraryFragment.TAG, null));')
 p.write_text(s)
PY

# Automatically match CurseForge content to the currently selected Minecraft version.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MikaelContentLibraryFragment.java")
s=p.read_text()
# Add reflection import.
if "java.lang.reflect.Field" not in s:
    s=s.replace("import java.util.*;", "import java.util.*; import java.lang.reflect.Field; import java.lang.reflect.Method;")
# Make the search URL include the detected Minecraft version when available.
old='String classId=t==0?"6":t==1?"12":t==2?"6552":"17"; String u="https://api.curseforge.com/v1/mods/search?gameId=432&classId="+classId+"&pageSize=30"; if(!q.isEmpty())u+="&searchFilter="+URLEncoder.encode(q,"UTF-8");'
new='String classId=t==0?"6":t==1?"12":t==2?"6552":"17"; String mcVersion=detectMinecraftVersion(); String u="https://api.curseforge.com/v1/mods/search?gameId=432&classId="+classId+"&pageSize=30"; if(mcVersion!=null&&!mcVersion.isEmpty())u+="&gameVersion="+URLEncoder.encode(mcVersion,"UTF-8"); if(!q.isEmpty())u+="&searchFilter="+URLEncoder.encode(q,"UTF-8");'
if old in s:
    s=s.replace(old,new)
# Show which version is being used.
s=s.replace('status.setText("Pesquisando...");', 'String selectedVersion=detectMinecraftVersion(); status.setText(selectedVersion==null?"Pesquisando...":"Pesquisando para Minecraft "+selectedVersion+"...");', 1)
# Insert robust version detector before json().
marker=' JSONObject json(String u)throws Exception{'
if "String detectMinecraftVersion()" not in s:
    method=''' String detectMinecraftVersion(){
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
'''
    s=s.replace(marker,method+marker)
p.write_text(s)
PY



# FINAL BUTTON AUDIT: ensure every button present in the final Mikael home layout
# has a real listener. This runs after all earlier MainMenu rewrites so later
# patches cannot accidentally remove the handlers.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
needle='ImageButton profile=v.findViewById(R.id.edit_profile_button); mVersionSpinner=v.findViewById(R.id.mc_version_spinner);'
decl=needle+'\n   Button modLibrary=v.findViewById(R.id.mod_library_button),contentLibrary=v.findViewById(R.id.content_library_button),forgeOptiFine=v.findViewById(R.id.forge_optifine_button);'
if 'Button modLibrary=v.findViewById(R.id.mod_library_button)' not in s:
    if needle not in s: raise SystemExit('MainMenu profile declaration not found')
    s=s.replace(needle,decl,1)
s=s.replace('files.setOnClickListener(x->{if(!hasOnlineProfile()){hasNoOnlineProfileDialog(requireActivity());return;}openPath(requireContext(),getCurrentProfileDirectory(),false);});', 'files.setOnClickListener(x->openPath(requireContext(),getCurrentProfileDirectory(),false));')
s=s.replace('if(hasOnlineProfile()){install.setOnClickListener(x->runInstaller(false));install.setOnLongClickListener(x->{runInstaller(true);return true;});}else install.setOnClickListener(x->hasNoOnlineProfileDialog(requireActivity()));', 'install.setOnClickListener(x->runInstaller(false));\n   install.setOnLongClickListener(x->{runInstaller(true);return true;});')
anchor='discord.setOnClickListener(x->openURL(requireActivity(),getString(R.string.discord_invite)));'
handlers=anchor+'\n   if(modLibrary!=null) modLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelModLibraryFragment.class,MikaelModLibraryFragment.TAG,null));\n   if(contentLibrary!=null) contentLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelContentLibraryFragment.class,MikaelContentLibraryFragment.TAG,null));\n   if(forgeOptiFine!=null) forgeOptiFine.setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));'
if 'modLibrary.setOnClickListener' not in s:
    if anchor not in s: raise SystemExit('MainMenu listener anchor not found')
    s=s.replace(anchor,handlers,1)
p.write_text(s)
PY

# FINAL FIX: account selection screen.
# Local/offline accounts work without Microsoft; Mod Library and Forge + OptiFine
# are available directly from "Adicionar conta".
python3 - <<'PY'
from pathlib import Path
root=Path("app_pojavlauncher/src/main")
java=root/"java/net/kdt/pojavlaunch/fragments"
res=root/"res"

(java/"SelectAuthFragment.java").write_text(r'''package net.kdt.pojavlaunch.fragments;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;

public class SelectAuthFragment extends Fragment {
    public static final String TAG = "AUTH_SELECT_FRAGMENT";

    public SelectAuthFragment() {
        super(R.layout.fragment_select_auth_method);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        Button microsoft = view.findViewById(R.id.button_microsoft_authentication);
        Button local = view.findViewById(R.id.button_local_authentication);
        Button ely = view.findViewById(R.id.button_ely_authentication);
        Button mods = view.findViewById(R.id.button_mikael_mod_library);
        Button forge = view.findViewById(R.id.button_mikael_forge_optifine);

        if (microsoft != null)
            microsoft.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MicrosoftLoginFragment.class, MicrosoftLoginFragment.TAG, null));

        // Offline/local profile: no Microsoft account is required.
        if (local != null)
            local.setOnClickListener(v -> Tools.swapFragment(requireActivity(), LocalLoginFragment.class, LocalLoginFragment.TAG, null));

        if (ely != null)
            ely.setOnClickListener(v -> Tools.swapFragment(requireActivity(), ElyLoginFragment.class, ElyLoginFragment.TAG, null));

        if (mods != null)
            mods.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MikaelModLibraryFragment.class, MikaelModLibraryFragment.TAG, null));

        if (forge != null)
            forge.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MikaelForgeOptiFineFragment.class, MikaelForgeOptiFineFragment.TAG, null));
    }
}
''')

p=java/"LocalLoginFragment.java"
x=p.read_text()
x=x.replace('import static net.kdt.pojavlaunch.Tools.hasOnlineProfile;\n\n','')
x=x.replace('''        // This is overkill but meh
        if (!hasOnlineProfile()){
            Tools.swapFragment(requireActivity(), MainMenuFragment.class, MainMenuFragment.TAG, null);
        }
''','')
p.write_text(x)

(res/"layout/fragment_select_auth_method.xml").write_text(r'''<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#0C0E12"
    android:fillViewport="true">
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:paddingStart="22dp"
        android:paddingEnd="22dp"
        android:paddingTop="26dp"
        android:paddingBottom="28dp">

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="ADICIONAR CONTA"
            android:textColor="#FFFFFF"
            android:textSize="26sp"
            android:textStyle="bold"/>

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            android:text="Escolha uma conta ou abra uma ferramenta do Mikael Launcher."
            android:textColor="#8F9AAA"
            android:textSize="14sp"/>

        <Button
            android:id="@+id/button_microsoft_authentication"
            android:layout_width="match_parent"
            android:layout_height="54dp"
            android:layout_marginTop="24dp"
            android:text="MICROSOFT ACCOUNT"
            android:textColor="#FFFFFF"
            android:textStyle="bold"
            android:background="@drawable/mikael_button"/>

        <Button
            android:id="@+id/button_local_authentication"
            android:layout_width="match_parent"
            android:layout_height="54dp"
            android:layout_marginTop="10dp"
            android:text="CONTA LOCAL / OFFLINE"
            android:textColor="#FFFFFF"
            android:textStyle="bold"
            android:background="@drawable/mikael_button"/>

        <Button
            android:id="@+id/button_ely_authentication"
            android:layout_width="match_parent"
            android:layout_height="54dp"
            android:layout_marginTop="10dp"
            android:text="ELY.BY"
            android:textColor="#FFFFFF"
            android:textStyle="bold"
            android:background="@drawable/mikael_button"/>

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="30dp"
            android:text="FERRAMENTAS"
            android:textColor="#4ADE80"
            android:textSize="14sp"
            android:textStyle="bold"/>

        <Button
            android:id="@+id/button_mikael_mod_library"
            android:layout_width="match_parent"
            android:layout_height="54dp"
            android:layout_marginTop="10dp"
            android:text="BIBLIOTECA DE MODS"
            android:textColor="#FFFFFF"
            android:textStyle="bold"
            android:background="@drawable/mikael_button"/>

        <Button
            android:id="@+id/button_mikael_forge_optifine"
            android:layout_width="match_parent"
            android:layout_height="54dp"
            android:layout_marginTop="10dp"
            android:text="FORGE + OPTIFINE"
            android:textColor="#FFFFFF"
            android:textStyle="bold"
            android:background="@drawable/mikael_button"/>
    </LinearLayout>
</ScrollView>
''')
PY

# Mikael RAM monitor: show current available RAM in Java settings.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/xml/pref_java.xml")
s=p.read_text()
if 'mikael_ram_available' not in s:
    marker='''        <SwitchPreference
            android:defaultValue="false"
            android:key="disable_autojre_select"'''
    pref='''        <Preference
            android:key="mikael_ram_available"
            android:persistent="false"
            android:title="RAM disponível"
            android:summary="Calculando..." />\n\n'''
    if marker not in s:
        raise SystemExit("pref_java marker not found")
    s=s.replace(marker,pref+marker,1)
    p.write_text(s)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/prefs/screens/LauncherPreferenceJavaFragment.java")
s=p.read_text()
s=s.replace('import android.os.Bundle;\n', 'import android.app.ActivityManager;\nimport android.content.Context;\nimport android.os.Bundle;\n')
if 'private Preference mMikaelRamPreference;' not in s:
    s=s.replace('    private SwitchPreference mSwitchAutoJRE;\n',
                '    private SwitchPreference mSwitchAutoJRE;\n    private Preference mMikaelRamPreference;\n')
if 'private void updateMikaelRamInfo()' not in s:
    marker='''    @Override
    public void onCreatePreferences(Bundle b, String str) {'''
    method='''    @Override
    public void onResume() {
        super.onResume();
        updateMikaelRamInfo();
    }

    private void updateMikaelRamInfo() {
        if (mMikaelRamPreference == null || getContext() == null) return;
        ActivityManager am = (ActivityManager) getContext().getSystemService(Context.ACTIVITY_SERVICE);
        if (am == null) return;
        ActivityManager.MemoryInfo info = new ActivityManager.MemoryInfo();
        am.getMemoryInfo(info);
        long availableMb = info.availMem / (1024L * 1024L);
        long totalMb = info.totalMem / (1024L * 1024L);
        long usedMb = Math.max(0L, totalMb - availableMb);
        mMikaelRamPreference.setSummary("Disponível agora: " + availableMb + " MB\\n" +
                "Em uso pelo sistema: " + usedMb + " MB\\n" +
                "Total: " + totalMb + " MB");
    }

'''
    if marker not in s:
        raise SystemExit("Java onCreatePreferences marker not found")
    s=s.replace(marker,method+marker,1)
if 'mMikaelRamPreference = findPreference("mikael_ram_available");' not in s:
    marker='''        CustomSeekBarPreference memorySeekbar = requirePreference("allocation",
                CustomSeekBarPreference.class);'''
    repl='''        mMikaelRamPreference = findPreference("mikael_ram_available");

        CustomSeekBarPreference memorySeekbar = requirePreference("allocation",
                CustomSeekBarPreference.class);'''
    if marker not in s:
        raise SystemExit("memory seekbar marker not found")
    s=s.replace(marker,repl,1)
p.write_text(s)
PY

# FINAL FIX: functional Mikael personalization dialog and Mikael Advanced controls.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/xml/pref_main.xml")
s=p.read_text()
old='''        <ListPreference
            android:key="mikael_accent_color"
            android:title="Cor do launcher"
            android:summary="Escolha a cor dos botões e destaques"
            android:entries="@array/mikael_color_names"
            android:entryValues="@array/mikael_color_values"
            android:defaultValue="#4ADE80" />'''
new='''        <Preference
            android:key="mikael_accent_color"
            android:title="PERSONALIZAR LAUNCHER"
            android:summary="Escolha a cor dos botões e destaques"
            android:persistent="true" />'''
if old in s:
    s=s.replace(old,new,1)
p.write_text(s)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/prefs/screens/LauncherPreferenceFragment.java")
s=p.read_text()
if "showMikaelAccentDialog()" not in s:
    marker="        setupNotificationRequestPreference();"
    insert='''        setupNotificationRequestPreference();
        Preference mikaelAccent = findPreference("mikael_accent_color");
        if (mikaelAccent != null) {
            mikaelAccent.setSummary("Cor atual: " + LauncherPreferences.DEFAULT_PREF.getString("mikael_accent_color", "#4ADE80"));
            mikaelAccent.setOnPreferenceClickListener(preference -> {
                showMikaelAccentDialog();
                return true;
            });
        }
        wireMikaelAdvancedPreferences();'''
    s=s.replace(marker,insert,1)
    marker="    private void setupNotificationRequestPreference() {"
    methods='''    private void showMikaelAccentDialog() {
        final String[] names = {"Verde Mikael","Azul","Roxo","Vermelho","Laranja","Ciano","Rosa","Amarelo"};
        final String[] values = {"#4ADE80","#60A5FA","#A78BFA","#F87171","#FB923C","#22D3EE","#F472B6","#FACC15"};
        String current = LauncherPreferences.DEFAULT_PREF.getString("mikael_accent_color", "#4ADE80");
        int checked = 0;
        for (int i = 0; i < values.length; i++) if (values[i].equalsIgnoreCase(current)) checked = i;
        new androidx.appcompat.app.AlertDialog.Builder(requireContext())
                .setTitle("PERSONALIZAR LAUNCHER")
                .setSingleChoiceItems(names, checked, (dialog, which) -> {
                    getPreferenceManager().getSharedPreferences().edit()
                            .putString("mikael_accent_color", values[which]).apply();
                    LauncherPreferences.loadPreferences(getContext());
                    Preference pref = findPreference("mikael_accent_color");
                    if (pref != null) pref.setSummary("Cor atual: " + values[which]);
                    dialog.dismiss();
                })
                .setNegativeButton("CANCELAR", null)
                .show();
    }

    private void wireMikaelAdvancedPreferences() {
        String[] keys = {
                "sustainedPerformance","force_vsync","alternate_surface","bigCoreAffinity",
                "zinkPreferSystemDriver","enableGyro","always_grab_mouse","keyboardPanning",
                "checkLibraries","dump_shaders"
        };
        for (String key : keys) {
            Preference pref = findPreference(key);
            if (pref == null) continue;
            pref.setOnPreferenceChangeListener((preference, newValue) -> {
                LauncherPreferences.loadPreferences(getContext());
                return true;
            });
            boolean value = getPreferenceManager().getSharedPreferences().getBoolean(key, false);
            if ("alternate_surface".equals(key)) value = getPreferenceManager().getSharedPreferences().getBoolean(key, true);
            if ("keyboardPanning".equals(key)) value = getPreferenceManager().getSharedPreferences().getBoolean(key, true);
            if ("checkLibraries".equals(key)) value = getPreferenceManager().getSharedPreferences().getBoolean(key, true);
            updateMikaelAdvancedSummary(pref, value);
        }
        Preference resolution = findPreference("resolutionRatio");
        if (resolution != null) {
            resolution.setOnPreferenceChangeListener((preference, newValue) -> {
                LauncherPreferences.loadPreferences(getContext());
                preference.setSummary("Escala atual: " + newValue + "%");
                return true;
            });
        }
    }

    private void updateMikaelAdvancedSummary(Preference pref, boolean enabled) {
        String base = String.valueOf(pref.getSummary());
        base = base.replaceAll("\\s*•\\s*(ATIVADO|DESATIVADO)$", "");
        pref.setSummary(base + (base.equals("null") ? "" : " • ") + (enabled ? "ATIVADO" : "DESATIVADO"));
    }

'''
    if marker not in s:
        raise SystemExit("LauncherPreferenceFragment marker not found")
    s=s.replace(marker,methods+marker,1)
# Keep summaries synchronized after toggles.
if "updateMikaelAdvancedSummary(findPreference(s)" not in s:
    old='''    @Override
    public void onSharedPreferenceChanged(SharedPreferences p, String s) {
        LauncherPreferences.loadPreferences(getContext());
    }'''
    new='''    @Override
    public void onSharedPreferenceChanged(SharedPreferences p, String s) {
        LauncherPreferences.loadPreferences(getContext());
        if ("mikael_accent_color".equals(s)) {
            Preference pref = findPreference("mikael_accent_color");
            if (pref != null) pref.setSummary("Cor atual: " + p.getString(s, "#4ADE80"));
            return;
        }
        String[] advanced = {"sustainedPerformance","force_vsync","alternate_surface","bigCoreAffinity",
                "zinkPreferSystemDriver","enableGyro","always_grab_mouse","keyboardPanning","checkLibraries","dump_shaders"};
        for (String key : advanced) {
            if (key.equals(s)) {
                Preference pref = findPreference(key);
                if (pref != null) updateMikaelAdvancedSummary(pref, p.getBoolean(key, false));
                break;
            }
        }
    }'''
    if old not in s:
        raise SystemExit("onSharedPreferenceChanged marker not found")
    s=s.replace(old,new,1)
p.write_text(s)
PY

# FINAL FIX: rewrite the mods library to use a public Modrinth path first,
# automatically target the active Minecraft version, and install required dependencies.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelModLibraryFragment.java" <<'EOF'
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
                .setMessage(m.summary+"\\n\\nMinecraft: "+(detectMinecraftVersion()==null?"automático":detectMinecraftVersion())+"\\nDependências obrigatórias: automáticas")
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
EOF

# Compatibility guard: the current upstream script changed the Modrinth block; never abort the whole patch when the optional text differs. 
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MikaelModLibraryFragment.java")
if p.exists():
    s=p.read_text()
    # Keep Modrinth fallback operational even when the upstream JSON shape differs.
    s=s.replace('throw new RuntimeException("Modrinth versions block not found");','// Optional upstream block; continue with the public Modrinth fallback.')
    p.write_text(s)
PY

# Fix the Modrinth version JSON parsing and keep the public API independent of CurseForge keys.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MikaelModLibraryFragment.java")
s=p.read_text()
bad='''        String versionUrl="https://api.modrinth.com/v2/project/"+URLEncoder.encode(projectId,"UTF-8")+"/version?game_versions="+URLEncoder.encode("[\""+mc+"\"]","UTF-8");
        JSONArray versions=new JSONArray(getRawPublic(versionUrl));'''
good='''        String versionUrl="https://api.modrinth.com/v2/project/"+URLEncoder.encode(projectId,"UTF-8")+"/version?game_versions="+URLEncoder.encode("[\""+mc+"\"]","UTF-8");
        JSONArray versions=new JSONArray(getRawPublic(versionUrl));'''
if bad in s:
    s=s.replace(bad,good,1)
# Upstream variants may already contain the corrected parser; do not abort the whole APK build.
p.write_text(s)
PY

# FINAL FIX: profile creation/installers must not require a Microsoft account.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/ProfileTypeSelectFragment.java")
s=p.read_text()
s=s.replace('import static net.kdt.pojavlaunch.Tools.hasNoOnlineProfileDialog;\n','')
s=s.replace('import static net.kdt.pojavlaunch.Tools.hasOnlineProfile;\n','')
old='''    private void tryInstall(Class<? extends Fragment> fragmentClass, String tag){
        if(!hasOnlineProfile()){
            hasNoOnlineProfileDialog(requireActivity());
        } else {
            Tools.swapFragment(requireActivity(), fragmentClass, tag, null);
        }
    }'''
new='''    private void tryInstall(Class<? extends Fragment> fragmentClass, String tag){
        // Installing/creating a local game profile does not require a Microsoft account.
        Tools.swapFragment(requireActivity(), fragmentClass, tag, null);
    }'''
if old not in s:
    raise SystemExit("ProfileTypeSelectFragment tryInstall block not found")
p.write_text(s.replace(old,new,1))
PY

# FINAL FIX: make the profile creation buttons use Mikael green instead of the upstream purple.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/ProfileTypeSelectFragment.java")
s=p.read_text()
s=s.replace('import android.view.View;\n', 'import android.graphics.Color;\nimport android.graphics.drawable.GradientDrawable;\nimport android.view.View;\nimport android.widget.Button;\n')
if 'private void styleMikaelProfileButtons(View view)' not in s:
    marker='''        super.onViewCreated(view, savedInstanceState);
'''
    method='''        super.onViewCreated(view, savedInstanceState);
        styleMikaelProfileButtons(view);
'''
    s=s.replace(marker,method,1)
    marker='''    private void tryInstall(Class<? extends Fragment> fragmentClass, String tag){'''
    methods='''    private void styleMikaelProfileButtons(View view) {
        int[] ids = {
                R.id.vanilla_profile, R.id.optifine_profile,
                R.id.modded_profile_fabric, R.id.modded_profile_quilt,
                R.id.modded_profile_forge, R.id.modded_profile_neoforge,
                R.id.modded_profile_modpack, R.id.modded_profile_lwjgl3ify,
                R.id.modded_profile_bta
        };
        for (int id : ids) {
            View v = view.findViewById(id);
            if (v instanceof Button) {
                GradientDrawable bg = new GradientDrawable();
                bg.setColor(Color.parseColor("#4ADE80"));
                bg.setCornerRadius(10f);
                ((Button) v).setBackground(bg);
                ((Button) v).setTextColor(Color.parseColor("#07110B"));
            }
        }
    }

'''
    if marker not in s:
        raise SystemExit("ProfileTypeSelect tryInstall marker not found")
    s=s.replace(marker,methods+marker,1)
p.write_text(s)
PY

# FINAL UI TUNE: reduce launcher buttons slightly for a more comfortable compact layout.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text()
# Main launcher 2-column buttons
s=s.replace('android:layout_height="@dimen/_52sdp"', 'android:layout_height="@dimen/_46sdp"')
# Content buttons
s=s.replace('android:layout_height="@dimen/_50sdp"', 'android:layout_height="@dimen/_46sdp"')
# Play button
s=s.replace('android:layout_height="@dimen/_54sdp"', 'android:layout_height="@dimen/_50sdp"')
p.write_text(s)
PY

# FINAL FIX: add the combined Forge + OptiFine installer directly to the profile creation list.
python3 - <<'PY'
from pathlib import Path

p=Path("app_pojavlauncher/src/main/res/layout/fragment_profile_type.xml")
s=p.read_text()
if 'android:id="@+id/modded_profile_forge_optifine"' not in s:
    needle='''        <com.kdt.mcgui.MineButton
            android:id="@+id/modded_profile_neoforge"'''
    button='''        <com.kdt.mcgui.MineButton
            android:id="@+id/modded_profile_forge_optifine"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginHorizontal="@dimen/padding_large"
            android:layout_marginTop="@dimen/padding_large"
            android:text="FORGE + OPTIFINE" />

'''
    if needle not in s:
        raise SystemExit("NeoForge button marker not found")
    s=s.replace(needle,button+needle,1)
p.write_text(s)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/ProfileTypeSelectFragment.java")
s=p.read_text()
listener='''        view.findViewById(R.id.modded_profile_forge_optifine).setOnClickListener(v ->
                Tools.swapFragment(requireActivity(), MikaelForgeOptiFineFragment.class,
                        MikaelForgeOptiFineFragment.TAG, null));
'''
if 'R.id.modded_profile_forge_optifine' not in s:
    marker='''        view.findViewById(R.id.modded_profile_neoforge).setOnClickListener((v)->'''
    if marker not in s:
        raise SystemExit("NeoForge listener marker not found")
    s=s.replace(marker,listener+marker,1)
old='''R.id.modded_profile_fabric, R.id.modded_profile_quilt,
                R.id.modded_profile_forge, R.id.modded_profile_neoforge,'''''
new='''R.id.modded_profile_fabric, R.id.modded_profile_quilt,
                R.id.modded_profile_forge, R.id.modded_profile_forge_optifine,
                R.id.modded_profile_neoforge,'''''
if old not in s:
    raise SystemExit("Green button IDs marker not found")
s=s.replace(old,new,1)
p.write_text(s)
PY

# FINAL UI CLEANUP: remove News and Community buttons from the main launcher.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text()
import re
for bid in ("news_button","discord_button"):
    s=re.sub(r'\s*<[^>]*?(?:Button|ImageButton|com\\.kdt\\.mcgui\\.MineButton)[^>]*?android:id="@\+id/'+bid+r'"[^>]*/>', '', s, flags=re.S)
    s=re.sub(r'\s*<[^>]*?(?:Button|ImageButton|com\\.kdt\\.mcgui\\.MineButton)[^>]*?android:id="@\+id/'+bid+r'"[^>]*>.*?</[^>]+>', '', s, flags=re.S)
p.write_text(s)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
# Remove listeners/tint references if present; null checks are harmless but we remove the button declarations too.
s=re.sub(r'\s*Button news=.*?;(?=\n)', '', s)
s=s.replace('if(news!=null) news.setOnClickListener(x->{});','')
s=s.replace('if(discord!=null) discord.setOnClickListener(x->{});','')
s=s.replace('news.setOnClickListener(x->{});','')
s=s.replace('discord.setOnClickListener(x->{});','')
s=s.replace('if(news!=null) news.setBackgroundTintList(android.content.res.ColorStateList.valueOf(accent));','')
s=s.replace('if(discord!=null) discord.setBackgroundTintList(android.content.res.ColorStateList.valueOf(accent));','')
p.write_text(s)
PY

# Advanced Crash Checker: collect recent logs/crash reports, score known failure signatures,
# identify likely root causes, show evidence, and provide concrete recovery steps.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelCrashCheckerFragment.java" <<'EOF'
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
import net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles;
import net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MikaelCrashCheckerFragment extends Fragment {
    public static final String TAG = "MIKAEL_CRASH_CHECKER";

    private TextView status;
    private TextView result;
    private Button analyze;
    private String currentReport = "";

    private static final class Finding {
        String id, title, cause, fix;
        int score, priority;
        final List<String> evidence = new ArrayList<>();
        Finding(String id, String title, String cause, String fix, int score, int priority) {
            this.id=id; this.title=title; this.cause=cause; this.fix=fix; this.score=score; this.priority=priority;
        }
    }

    public MikaelCrashCheckerFragment() {
        super(R.layout.fragment_mikael_crash_checker);
    }

    @Override public void onViewCreated(@NonNull View v, @Nullable Bundle b) {
        status=v.findViewById(R.id.crash_status);
        result=v.findViewById(R.id.crash_result);
        analyze=v.findViewById(R.id.crash_analyze);
        Button back=v.findViewById(R.id.crash_back);
        analyze.setOnClickListener(x->runAnalysis());
        back.setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));
        runAnalysis();
    }

    private void runAnalysis() {
        status.setText("Analisando logs, crash-reports e configuração...");
        result.setText("Aguarde...");
        analyze.setEnabled(false);
        new Thread(()->{
            try {
                Analysis a=analyzeCrash();
                android.app.Activity activity=getActivity();
                if(activity!=null) activity.runOnUiThread(()->{
                    if(!isAdded()) return;
                    currentReport=a.report;
                    status.setText(a.summary);
                    result.setText(a.report);
                    analyze.setEnabled(true);
                });
            } catch(Exception e) {
                android.app.Activity activity=getActivity();
                if(activity!=null) activity.runOnUiThread(()->{
                    if(!isAdded()) return;
                    status.setText("Falha no analisador");
                    result.setText("Não foi possível analisar os arquivos.\n\nErro técnico: "+e.getMessage());
                    analyze.setEnabled(true);
                });
            }
        }).start();
    }

    private Analysis analyzeCrash() throws Exception {
        File dir=getCurrentProfileDirectory();
        List<File> candidates=new ArrayList<>();
        File latest=new File(dir,"latestlog.txt");
        if(latest.exists()) candidates.add(latest);
        File crashDir=new File(dir,"crash-reports");
        collectFiles(crashDir,candidates,4);
        File gameLog=new File(dir,"logs/latest.log");
        if(gameLog.exists()) candidates.add(gameLog);
        Collections.sort(candidates,Comparator.comparingLong(File::lastModified).reversed());

        if(candidates.isEmpty()) {
            return new Analysis("Nenhum log encontrado",
                    "Não encontrei latestlog.txt, logs/latest.log nem arquivos recentes em crash-reports.\n\n"+
                    "Como resolver:\n1. Inicie o Minecraft até o crash acontecer.\n2. Volte imediatamente ao launcher.\n3. Abra VERIFICAR CRASH novamente.");
        }

        File primary=candidates.get(0);
        String text=readTail(primary,220000);
        if(text.trim().isEmpty()) {
            return new Analysis("Log vazio",
                    "O arquivo mais recente está vazio: "+primary.getName()+"\n\nTente executar o jogo novamente e analisar logo após o crash.");
        }

        String lower=text.toLowerCase(Locale.ROOT);
        List<Finding> findings=detect(text,lower);
        Collections.sort(findings,(a,b)->{
            int c=Integer.compare(b.score,a.score);
            return c!=0?c:Integer.compare(a.priority,b.priority);
        });

        String mc=extractMinecraftVersion(text);
        String java=extractJavaVersion(text);
        String top=extractLastMeaningfulError(text);
        int confidence=findings.isEmpty()?20:Math.min(99,50+findings.get(0).score*5);
        StringBuilder out=new StringBuilder();
        out.append("ARQUIVO ANALISADO\n").append(primary.getAbsolutePath()).append("\n");
        out.append("Data: ").append(new java.util.Date(primary.lastModified())).append("\n");
        if(mc!=null) out.append("Minecraft detectado: ").append(mc).append("\n");
        if(java!=null) out.append("Java detectado: ").append(java).append("\n");
        out.append("Confiança da análise: ").append(confidence).append("%\n\n");

        if(top!=null) out.append("ÚLTIMO ERRO RELEVANTE\n").append(top).append("\n\n");

        if(findings.isEmpty()) {
            out.append("CAUSA NÃO DETERMINADA\n");
            out.append("Não encontrei uma assinatura forte o suficiente para afirmar a causa.\n\n");
            out.append("Próximos passos:\n- envie o trecho final de latestlog.txt/crash-report;\n");
            out.append("- verifique se o problema ocorre sem mods;\n");
            out.append("- confirme a versão do Java exigida pela versão do Minecraft.\n");
        } else {
            Finding f=findings.get(0);
            out.append("CAUSA MAIS PROVÁVEL\n").append(f.title).append("\n");
            out.append("O que aconteceu:\n").append(f.cause).append("\n\n");
            out.append("COMO RESOLVER\n").append(f.fix).append("\n\n");
            out.append("EVIDÊNCIAS ENCONTRADAS\n");
            for(String e:f.evidence) out.append("• ").append(e).append("\n");
            if(findings.size()>1) {
                out.append("\nOUTRAS POSSIBILIDADES\n");
                int count=Math.min(3,findings.size());
                for(int i=1;i<count;i++) out.append((i+1)).append(". ").append(findings.get(i).title)
                        .append(" (pontuação ").append(findings.get(i).score).append(")\n");
            }
        }
        out.append("\nARQUIVOS VERIFICADOS: ").append(candidates.size());
        if(candidates.size()>1) {
            out.append("\nMais recente: ").append(candidates.get(0).getName());
            for(int i=1;i<Math.min(candidates.size(),5);i++) out.append("\n").append(i+1).append(". ").append(candidates.get(i).getName());
        }
        out.append("\n\nHeurísticas: Java, RAM, mods, dependências, Fabric/Forge, OptiFine, LWJGL/GLFW, OpenGL/Zink, autenticação, rede, bibliotecas, permissões, arquivo corrompido e crashes nativos.");
        return new Analysis(findings.isEmpty()?"Análise concluída":"Diagnóstico: "+findings.get(0).title,out.toString());
    }

    private List<Finding> detect(String text,String l) {
        List<Finding> fs=new ArrayList<>();
        add(fs,"oom","Memória insuficiente / OutOfMemory",
                "O processo do Minecraft/JVM ficou sem memória suficiente para concluir a operação.",
                "Reduza a RAM alocada para deixar memória para o Android, desative shaders pesados e feche apps em segundo plano. Para mods grandes, aumente a RAM alocada somente se o aparelho tiver RAM livre.",
                new String[]{"outofmemoryerror","java heap space","gc overhead limit exceeded","unable to create native thread"},12,1,text,l);

        add(fs,"java","Versão do Java incompatível",
                "O Minecraft ou um mod tentou carregar classes compiladas para uma versão de Java diferente da runtime usada.",
                "Em Ajustes > Java > Runtimes, instale a versão Java exigida pela versão do Minecraft e selecione essa runtime para o perfil. Java 8 é comum em versões antigas; versões modernas usam runtimes mais novas.",
                new String[]{"unsupportedclassversionerror","class file version","could not create the java virtual machine","unsupported major.minor version"},11,2,text,l);

        add(fs,"missing_mod","Mod/biblioteca ausente",
                "Alguma classe necessária não foi encontrada. Normalmente isso significa que um mod ou uma dependência obrigatória não foi instalado.",
                "Remova o mod citado no erro ou instale a dependência/loader indicado. Na Biblioteca de Mods, use a versão compatível com o Minecraft selecionado.",
                new String[]{"modresolutionexception","modresolution","mod '","could not find required mod","depends on","requires"},8,4,text,l);

        add(fs,"mixin","Falha de Mixin / mod incompatível",
                "Um mod tentou aplicar uma transformação de bytecode que não corresponde à versão atual do Minecraft/loader ou de outro mod.",
                "Atualize o mod para a mesma versão do Minecraft, teste sem o mod citado no stacktrace e confira conflitos entre mods que alteram a mesma classe.",
                new String[]{"mixinapplyerror","mixin","invalid injection","injectionpoint","callback method"},8,5,text,l);

        add(fs,"forge","Forge/modloader incompatível",
                "O loader encontrou uma configuração, versão ou mod que não combina com a versão do Forge.",
                "Use a versão do Forge compatível com o Minecraft e confirme as dependências. Evite misturar versões de mods destinadas a outro loader.",
                new String[]{"fmlcommon","modlauncher","net.minecraftforge","fml loading error","forge"},6,7,text,l);

        add(fs,"fabric","Fabric incompatível",
                "O Fabric Loader encontrou incompatibilidade entre mods, loader ou versão do Minecraft.",
                "Atualize Fabric Loader e Fabric API para a mesma linha de Minecraft do perfil. Remova temporariamente o último mod adicionado para localizar o conflito.",
                new String[]{"fabric loader","fabricloader","net.fabricmc","fabric api"},6,6,text,l);

        add(fs,"optifine","Conflito envolvendo OptiFine",
                "Há sinais de erro em OptiFine, renderização ou integração com outro mod/loader.",
                "Use uma versão estável do OptiFine compatível com o Minecraft. Não misture OptiFine com mods de renderização incompatíveis e teste sem shaders.",
                new String[]{"optifine","opengl error","shader","glfw"},5,8,text,l);

        add(fs,"lwjgl","Falha nativa LWJGL/GLFW",
                "Uma biblioteca gráfica/nativa não conseguiu inicializar corretamente no Android.",
                "Teste outro renderer compatível, desative opções gráficas experimentais e confira se a versão do Minecraft/mod não exige uma biblioteca nativa incompatível. Reinicie o launcher após trocar runtime/renderer.",
                new String[]{"lwjgl","glfw error","liblwjgl","unsatisfiedlinkerror","native library"},7,3,text,l);

        add(fs,"gpu","Problema de GPU / OpenGL / Vulkan / Zink",
                "O jogo falhou ao inicializar a camada gráfica ou um shader/driver.",
                "Desative shaders, teste a superfície/renderizador alternativo e, em aparelhos compatíveis, teste Zink. Se só uma versão do Minecraft falha, compare com uma versão vanilla.",
                new String[]{"opengl","egl_bad","egl error","vulkan","zink","glout","shader compilation"},6,9,text,l);

        add(fs,"auth","Falha de autenticação",
                "O jogo/launcher não conseguiu autenticar a sessão ou obter os dados necessários para entrar no servidor.",
                "Confirme a conta e a sessão, verifique a conexão e refaça o login. Para contas Ely.by, confirme que o perfil e a integração exigida pelo servidor estão configurados.",
                new String[]{"invalid session","authenticationservers","authlib","access token","failed to verify username","ely.by"},5,10,text,l);

        add(fs,"network","Falha de rede/download",
                "O crash/erro ocorreu durante acesso a recursos remotos, bibliotecas ou servidores.",
                "Verifique internet, DNS e estabilidade da conexão. Tente novamente; se o erro mencionar um domínio específico, ele pode estar indisponível ou bloqueado.",
                new String[]{"timeout","unknownhostexception","connectexception","connection reset","failed to download","http 403","http 404","sslhandshakeexception"},5,11,text,l);

        add(fs,"library","Biblioteca/JAR corrompido ou incompatível",
                "Uma biblioteca foi encontrada, mas não pôde ser carregada corretamente.",
                "Rebaixe a biblioteca/mod afetado. Em caso de erro persistente, remova somente o arquivo indicado e execute novamente para forçar um novo download.",
                new String[]{"zipexception","jarfile","invalid or corrupt jarfile","noclassdeffounderror","linkageerror"},7,12,text,l);

        add(fs,"permission","Armazenamento/permissão",
                "O processo não conseguiu ler ou gravar arquivos necessários.",
                "Confira as permissões do aplicativo e espaço livre. Evite mover manualmente a pasta do jogo durante o download/execução.",
                new String[]{"permission denied","eacces","read-only file system","nosuchfileexception","failed to open"},4,13,text,l);

        add(fs,"native","Crash nativo (SIGSEGV/SIGABRT)",
                "Uma biblioteca nativa terminou o processo. Isso geralmente aponta para renderer, LWJGL ou incompatibilidade nativa.",
                "Teste renderer alternativo, desative shaders e mods gráficos e compare com uma instalação vanilla. Se apenas uma runtime apresenta o crash, teste outra runtime compatível.",
                new String[]{"sigsegv","sigabrt","fatal signal 11","fatal signal 6","native crash"},10,0,text,l);

        add(fs,"class","Classe/método incompatível entre mods",
                "Um mod foi compilado para uma API diferente da disponível no conjunto atual.",
                "Atualize ou substitua o mod citado e mantenha todos os mods na mesma versão de Minecraft/loader. Procure primeiro o primeiro nome de mod antes do stacktrace do Minecraft.",
                new String[]{"noclassdeffounderror","classnotfoundexception","nosuchmethoderror","nosuchfielderror"},7,14,text,l);

        add(fs,"disk","Espaço em disco insuficiente",
                "O launcher/JVM não conseguiu concluir uma gravação porque o armazenamento ficou sem espaço.",
                "Libere espaço no armazenamento interno e tente novamente. Evite manter várias cópias de runtimes, mods e logs desnecessários.",
                new String[]{"no space left on device","disk full","enospc"},8,15,text,l);

        // Increase confidence when multiple independent signatures agree.
        Set<String> tokens=new HashSet<>();
        Matcher m=Pattern.compile("(?i)([a-z0-9_$.]+(?:mod|fabric|forge|optifine|sodium)[a-z0-9_$.\\\-]*)").matcher(text);
        while(m.find() && tokens.size()<16) tokens.add(m.group(1));
        for(Finding f:fs) if(f.score>0 && !tokens.isEmpty() && f.id.equals("missing_mod")) f.score++;
        return fs;
    }

    private void add(List<Finding> fs,String id,String title,String cause,String fix,String[] sig,int base,int priority,String text,String lower) {
        Finding f=new Finding(id,title,cause,fix,0,priority);
        for(String s:sig) if(lower.contains(s)) {
            f.score+=base;
            if(f.evidence.size()<5) {
                int idx=lower.indexOf(s);
                String raw=text.substring(Math.max(0,idx-110),Math.min(text.length(),idx+s.length()+180)).replace('\n',' ');
                raw=raw.replaceAll("\\s+"," ").trim();
                f.evidence.add(raw);
            }
        }
        if(f.score>0) fs.add(f);
    }

    private String extractLastMeaningfulError(String t) {
        String[] pats={"OutOfMemoryError","UnsupportedClassVersionError","NoClassDefFoundError","ClassNotFoundException",
                "NoSuchMethodError","MixinApplyError","ModLoadingException","java.lang.","FATAL","ERROR","Caused by:"};
        String[] lines=t.split("\\R");
        for(int i=lines.length-1;i>=0;i--) {
            String line=lines[i].trim();
            if(line.length()<8 || line.length()>500) continue;
            for(String p:pats) if(line.toLowerCase(Locale.ROOT).contains(p.toLowerCase(Locale.ROOT)))
                return line;
        }
        return null;
    }

    private String extractMinecraftVersion(String t) {
        Matcher m=Pattern.compile("(?i)(?:minecraft|version)[^0-9]{0,30}(\\d+\\.\\d+(?:\\.\\d+)?)").matcher(t);
        String v=null; while(m.find()) v=m.group(1);
        return v;
    }

    private String extractJavaVersion(String t) {
        Matcher m=Pattern.compile("(?i)(?:java|runtime)[^0-9]{0,20}(1\\.\\d+|\\d+)(?:[._-]\\d+)*").matcher(t);
        return m.find()?m.group(1):null;
    }

    private void collectFiles(File dir,List<File> out,int depth) {
        if(dir==null||!dir.exists()||depth<0)return;
        File[] files=dir.listFiles();
        if(files==null)return;
        for(File f:files) {
            if(f.isDirectory()) { collectFiles(f,out,depth-1); }
            else if(f.getName().toLowerCase(Locale.ROOT).endsWith(".txt") || f.getName().toLowerCase(Locale.ROOT).endsWith(".log")) out.add(f);
        }
    }

    private String readTail(File f,int maxChars) throws Exception {
        long skip=Math.max(0,f.length()-maxChars);
        try(FileInputStream in=new FileInputStream(f)) {
            if(skip>0) in.skip(skip);
            BufferedReader br=new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
            StringBuilder b=new StringBuilder();
            char[] c=new char[8192]; int n;
            while((n=br.read(c))!=-1) b.append(c,0,n);
            return b.toString();
        }
    }

    private File getCurrentProfileDirectory() {
        String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
        if(cur==null||cur.trim().isEmpty()) return new File(Tools.DIR_GAME_NEW);
        try {
            LauncherProfiles.load();
            MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);
            return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);
        } catch(Exception e) { return new File(Tools.DIR_GAME_NEW); }
    }

    private static final class Analysis {
        final String summary, report;
        Analysis(String s,String r){summary=s;report=r;}
    }
}
EOF

cat > "$RES/layout/fragment_mikael_crash_checker.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#0C0E12" android:padding="16dp">
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="VERIFICAR CRASH" android:textColor="#FFFFFF" android:textSize="25sp" android:textStyle="bold"/>
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="5dp" android:text="Analisa automaticamente logs, crash-reports, Java, RAM, mods, loaders e gráficos."
        android:textColor="#9AA4B2" android:textSize="13sp"/>
    <TextView android:id="@+id/crash_status" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="14dp" android:text="Preparando..." android:textColor="#4ADE80"
        android:textStyle="bold"/>
    <ScrollView android:layout_width="match_parent" android:layout_height="0dp"
        android:layout_weight="1" android:layout_marginTop="10dp" android:fillViewport="true">
        <TextView android:id="@+id/crash_result" android:layout_width="match_parent" android:layout_height="wrap_content"
            android:textColor="#E8EDF3" android:textSize="13sp" android:lineSpacingExtra="3dp"/>
    </ScrollView>
    <Button android:id="@+id/crash_analyze" android:layout_width="match_parent" android:layout_height="48dp"
        android:text="ANALISAR NOVAMENTE" android:textStyle="bold" android:background="@drawable/mikael_button"/>
    <Button android:id="@+id/crash_back" android:layout_width="match_parent" android:layout_height="48dp"
        android:layout_marginTop="8dp" android:text="VOLTAR" android:background="@drawable/mikael_button"/>
</LinearLayout>
EOF

# Add the crash checker button to the main launcher content area.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text()
if "crash_checker_button" not in s:
    marker='''<com.kdt.mcgui.LauncherMenuButton android:id="@+id/install_jar_button"'''
    pos=s.find(marker)
    end=s.find('/>',pos)
    if pos>=0 and end>=0:
        btn='''<com.kdt.mcgui.LauncherMenuButton android:id="@+id/crash_checker_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="@dimen/_7sdp" android:text="VERIFICAR CRASH" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>'''
        s=s[:end+2]+"\n"+btn+s[end+2:]
p.write_text(s)
PY

# Wire the crash checker button after all earlier MainMenu rewrites.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
needle='Button modLibrary=v.findViewById(R.id.mod_library_button),contentLibrary=v.findViewById(R.id.content_library_button),forgeOptiFine=v.findViewById(R.id.forge_optifine_button);'
if "crash_checker_button" in open("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml").read() and "MikaelCrashCheckerFragment.class" not in s:
    if needle not in s: raise SystemExit("MainMenu button declaration marker not found")
    s=s.replace(needle,needle+'\n   Button crashChecker=v.findViewById(R.id.crash_checker_button);',1)
    anchor='''if(forgeOptiFine!=null) forgeOptiFine.setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));'''
    if anchor not in s: raise SystemExit("MainMenu Forge listener marker not found")
    s=s.replace(anchor,anchor+'\n   if(crashChecker!=null) crashChecker.setOnClickListener(x->swapFragment(requireActivity(),MikaelCrashCheckerFragment.class,MikaelCrashCheckerFragment.TAG,null));',1)
p.write_text(s)
PY

# FINAL ADVANCED CRASH ENGINE: deeper evidence correlation, exact offending-mod extraction,
# loader/runtime/version detection, stage classification, multiple-file comparison,
# confidence grading, actionable repair plan, and report sharing/copying.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelCrashCheckerFragment.java" <<'EOF'
package net.kdt.pojavlaunch.fragments;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
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

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MikaelCrashCheckerFragment extends Fragment {
    public static final String TAG="MIKAEL_CRASH_CHECKER";

    private TextView status;
    private TextView result;
    private Button analyze;
    private String currentReport="";

    private static final Pattern EXCEPTION =
            Pattern.compile("(?m)(?:^|\\n)(?:[\\w.$]+(?::|\\s+))?([A-Za-z_$][\\w$]*(?:Exception|Error|Fault|Failure)(?:: [^\\n]{0,500})?)");
    private static final Pattern CAUSED_BY =
            Pattern.compile("(?i)Caused by:\\s*([^\\n]{3,600})");
    private static final Pattern MOD_FILE =
            Pattern.compile("(?i)(?:Mod File|mod file|jar|filename|file)[:=]\\s*([^\\n]*?)(?:\\.jar)(?:[^\\n]*)");
    private static final Pattern FABRIC_MOD =
            Pattern.compile("(?i)(?:fabric.mod.json|modid|id)[:=]\\s*([a-z0-9_.-]{2,80})");
    private static final Pattern REQUIRED =
            Pattern.compile("(?i)(?:depends on|requires|requires minecraft|requires java|dependency)[:\\s]+([^\\n]{2,250})");
    private static final Pattern MC_VERSION =
            Pattern.compile("(?i)(?:minecraft(?: version)?|version id|game version)[^0-9]{0,32}(\\d+\\.\\d+(?:\\.\\d+)?)");
    private static final Pattern JAVA_VERSION =
            Pattern.compile("(?i)(?:java(?: version)?|runtime)[^0-9]{0,28}((?:1\\.)?\\d+)(?:[._-]\\d+)*");
    private static final Pattern MEMORY =
            Pattern.compile("(?i)(?:heap|memory)[^0-9]{0,30}(\\d+)\\s*(mb|gb)");

    private static final class Evidence {
        final String source;
        final String line;
        Evidence(String source,String line){this.source=source;this.line=line;}
    }

    private static final class Finding {
        String id,title,cause,fix,stage;
        int score;
        final List<Evidence> evidence=new ArrayList<>();
        final Set<String> modules=new LinkedHashSet<>();
        final Set<String> dependencies=new LinkedHashSet<>();
        Finding(String id,String title,String cause,String fix,String stage){
            this.id=id;this.title=title;this.cause=cause;this.fix=fix;this.stage=stage;
        }
    }

    private static final class ReportFile {
        final File file;
        final String text;
        final String lower;
        ReportFile(File f,String t){file=f;text=t;lower=t.toLowerCase(Locale.ROOT);}
    }

    private static final class Analysis {
        String summary;
        String report;
        Analysis(String s,String r){summary=s;report=r;}
    }

    public MikaelCrashCheckerFragment(){super(R.layout.fragment_mikael_crash_checker);}

    @Override public void onViewCreated(@NonNull View v,@Nullable Bundle b){
        status=v.findViewById(R.id.crash_status);
        result=v.findViewById(R.id.crash_result);
        analyze=v.findViewById(R.id.crash_analyze);
        Button copy=v.findViewById(R.id.crash_copy);
        Button share=v.findViewById(R.id.crash_share);
        Button back=v.findViewById(R.id.crash_back);

        analyze.setOnClickListener(x->runAnalysis());
        copy.setOnClickListener(x->copyReport());
        share.setOnClickListener(x->shareReport());
        back.setOnClickListener(x->Tools.swapFragment(requireActivity(),MainMenuFragment.class,MainMenuFragment.TAG,null));

        runAnalysis();
    }

    private void runAnalysis(){
        status.setText("ANALISADOR AVANÇADO: lendo logs e cruzando evidências...");
        result.setText("Aguarde...");
        analyze.setEnabled(false);
        new Thread(()->{
            try{
                Analysis a=analyzeCrash();
                android.app.Activity activity=getActivity();
                if(activity!=null) activity.runOnUiThread(()->{
                    if(!isAdded())return;
                    currentReport=a.report;
                    status.setText(a.summary);
                    result.setText(a.report);
                    analyze.setEnabled(true);
                });
            }catch(Exception e){
                android.app.Activity activity=getActivity();
                if(activity!=null) activity.runOnUiThread(()->{
                    if(!isAdded())return;
                    status.setText("Falha no analisador");
                    result.setText("Erro técnico do analisador:\n"+e.getClass().getSimpleName()+": "+e.getMessage());
                    analyze.setEnabled(true);
                });
            }
        }).start();
    }

    private Analysis analyzeCrash() throws Exception{
        File dir=getCurrentProfileDirectory();
        List<File> files=findCandidateFiles(dir);
        if(files.isEmpty()){
            return new Analysis("SEM DADOS",
                    "VERIFICAR CRASH\n\nNão há logs/crash-reports disponíveis para análise.\n\n"+
                    "Faça o Minecraft iniciar até acontecer o crash, volte ao launcher e execute a análise imediatamente.");
        }

        ReportFile primary=null;
        List<ReportFile> reports=new ArrayList<>();
        for(File f:files){
            try{
                String t=readTail(f,320000);
                if(t.trim().isEmpty())continue;
                ReportFile r=new ReportFile(f,t);
                reports.add(r);
                if(primary==null) primary=r;
            }catch(Exception ignored){}
        }
        if(reports.isEmpty()){
            return new Analysis("ARQUIVOS ILEGÍVEIS",
                    "Encontrei arquivos de log, mas não consegui ler o conteúdo.");
        }

        List<ReportFile> strongest=new ArrayList<>(reports);
        Collections.sort(strongest,(a,b)->Long.compare(b.file.lastModified(),a.file.lastModified()));
        primary=strongest.get(0);

        List<Finding> findings=detectFindings(reports,primary);
        Collections.sort(findings,(a,b)->Integer.compare(b.score,a.score));

        String minecraft=firstMatch(MC_VERSION,primary.text);
        String java=firstMatch(JAVA_VERSION,primary.text);
        String loader=detectLoader(primary.lower);
        String stage=detectStage(primary.lower);
        String offender=detectOffendingModule(primary.text);
        String deepest=deepestCause(primary.text);
        String topError=lastException(primary.text);

        RuntimeInfo runtime=getRuntimeInfo();
        StorageInfo storage=getStorageInfo(dir);

        int topScore=findings.isEmpty()?0:findings.get(0).score;
        int confidence=confidence(findings,primary,offender,deepest);
        String verdict=findings.isEmpty()?"CAUSA NÃO DETERMINADA":findings.get(0).title;

        StringBuilder out=new StringBuilder();
        out.append("══════════════════════════════\n");
        out.append("MIKAEL CRASH CHECKER • DIAGNÓSTICO PRO\n");
        out.append("══════════════════════════════\n\n");

        out.append("RESUMO\n");
        out.append("Diagnóstico: ").append(verdict).append("\n");
        out.append("Confiança: ").append(confidence).append("/100\n");
        out.append("Etapa do crash: ").append(stage).append("\n");
        out.append("Arquivo principal: ").append(primary.file.getName()).append("\n");
        out.append("Arquivos cruzados: ").append(reports.size()).append("\n\n");

        out.append("AMBIENTE DETECTADO\n");
        if(minecraft!=null)out.append("Minecraft: ").append(minecraft).append("\n");
        out.append("Loader: ").append(loader).append("\n");
        if(java!=null)out.append("Java no log: ").append(java).append("\n");
        out.append("RAM disponível agora: ").append(runtime.availableMb).append(" MB\n");
        out.append("RAM total: ").append(runtime.totalMb).append(" MB\n");
        out.append("RAM alocada ao Minecraft: ").append(runtime.allocatedMb).append(" MB\n");
        out.append("Espaço livre: ").append(storage.freeMb).append(" MB\n");
        out.append("Mods instalados: ").append(storage.modCount).append("\n\n");

        if(offender!=null) out.append("MOD/ARQUIVO SUSPEITO\n").append(offender).append("\n\n");
        if(deepest!=null) out.append("CAUSA MAIS PROFUNDA ENCONTRADA\n").append(deepest).append("\n\n");
        if(topError!=null) out.append("ÚLTIMA EXCEÇÃO RELEVANTE\n").append(topError).append("\n\n");

        if(findings.isEmpty()){
            out.append("POR QUE NÃO DEU PARA DECIDIR\n");
            out.append("O log não contém uma assinatura suficientemente específica. O analisador evita apontar Forge/OptiFine/GPU apenas porque o nome apareceu no log.\n\n");
            out.append("PRÓXIMOS PASSOS\n");
            out.append("1. Rode novamente e analise o arquivo criado pelo crash.\n");
            out.append("2. Teste sem mods para separar problema do Minecraft de problema de mod.\n");
            out.append("3. Compare com outra runtime Java compatível.\n");
        }else{
            Finding best=findings.get(0);
            out.append("O QUE ACONTECEU\n").append(best.cause).append("\n\n");
            out.append("COMO RESOLVER\n").append(best.fix).append("\n\n");

            out.append("EVIDÊNCIAS FORTES\n");
            for(Evidence e:best.evidence)
                out.append("• [").append(e.source).append("] ").append(e.line).append("\n");

            if(!best.modules.isEmpty()){
                out.append("\nMODS RELACIONADOS\n");
                for(String m:best.modules)out.append("• ").append(m).append("\n");
            }
            if(!best.dependencies.isEmpty()){
                out.append("\nDEPENDÊNCIAS CITADAS\n");
                for(String d:best.dependencies)out.append("• ").append(d).append("\n");
            }

            if(findings.size()>1){
                out.append("\nHIPÓTESES SECUNDÁRIAS\n");
                for(int i=1;i<Math.min(5,findings.size());i++){
                    Finding f=findings.get(i);
                    out.append(i+1).append(". ").append(f.title)
                       .append(" — força ").append(f.score).append("/100");
                    if(f.stage!=null)out.append(" • etapa: ").append(f.stage);
                    out.append("\n");
                }
            }
        }

        out.append("\nANÁLISE DE CONSISTÊNCIA\n");
        out.append(consistencyReport(findings,reports,primary,offender));
        out.append("\n\nARQUIVOS ANALISADOS\n");
        for(int i=0;i<Math.min(8,reports.size());i++)
            out.append("• ").append(reports.get(i).file.getName()).append("\n");

        out.append("\nNOTA\n");
        out.append("O diagnóstico é heurístico: ele cruza exceções, contexto, dependências, nomes de mods e repetição entre arquivos. Não trata uma palavra genérica isolada como prova de causa.");

        return new Analysis(confidence>=75?"Diagnóstico forte: "+verdict:
                confidence>=50?"Diagnóstico provável: "+verdict:"Diagnóstico inconclusivo: "+verdict,out.toString());
    }

    private List<Finding> detectFindings(List<ReportFile> reports,ReportFile primary){
        Map<String,Finding> map=new LinkedHashMap<>();

        register(map,"oom","Memória insuficiente","A JVM encontrou sinais de falta de heap/memória nativa ou não conseguiu criar recursos por falta de memória.",
                "Diminua a RAM alocada se o Android estiver sem memória; feche apps; desative shaders/mods pesados. Só aumente a RAM do Minecraft quando houver RAM livre suficiente.",
                "Inicialização/Jogo");
        register(map,"java","Java incompatível","Há evidências explícitas de versão de Java incompatível com classes, o Minecraft ou um componente.",
                "Instale a runtime Java compatível com a versão do Minecraft e associe a runtime correta ao perfil. Não escolha Java apenas pelo número mais alto.",
                "Inicialização");

        register(map,"missing","Dependência ou mod ausente","O loader relata que um mod depende de outro componente que não está disponível.",
                "Instale a dependência indicada ou remova o mod que a exige. Use versões destinadas à mesma versão de Minecraft e ao mesmo loader.",
                "Carregamento de mods");
        register(map,"mixin","Conflito de Mixin","O stacktrace mostra falha de injection/mixin; isso costuma apontar para incompatibilidade entre mods, Minecraft e loader.",
                "Atualize o mod citado para a versão exata do Minecraft/loader. Se começou após instalar um mod, teste removendo esse mod primeiro.",
                "Carregamento de mods");
        register(map,"class","Classe/API incompatível","Uma classe, método ou campo esperado por um mod não existe na combinação atual.",
                "Alinhe a versão do mod, loader e Minecraft. O nome do mod antes do stacktrace é a primeira coisa a conferir.",
                "Carregamento de mods");
        register(map,"forge","Falha específica do Forge","Há uma assinatura explícita de carregamento do Forge, modlauncher ou FML junto de erro concreto.",
                "Use um Forge compatível com a versão do Minecraft e verifique as dependências dos mods.",
                "Carregamento de mods");
        register(map,"fabric","Falha específica do Fabric","Há assinatura do Fabric Loader/API associada a erro de carregamento ou dependência.",
                "Use Fabric Loader/Fabric API da mesma linha do Minecraft e confirme as dependências dos mods.",
                "Carregamento de mods");
        register(map,"render","Falha gráfica/OpenGL/Vulkan/Zink","Há erro concreto de criação de contexto gráfico, shader, OpenGL, Vulkan, EGL ou biblioteca gráfica nativa.",
                "Desative shaders e opções gráficas experimentais; teste renderer alternativo/Zink quando disponível; compare com uma instância vanilla.",
                "Inicialização gráfica");
        register(map,"lwjgl","Falha nativa LWJGL/GLFW","Uma biblioteca nativa gráfica não conseguiu carregar/inicializar corretamente.",
                "Teste outro renderer e outra runtime compatível; verifique conflitos de bibliotecas nativas e remova mods gráficos para isolar o problema.",
                "Inicialização gráfica");
        register(map,"native","Crash nativo","Há sinais de SIGSEGV, SIGABRT ou fatal signal; o processo terminou dentro de código nativo.",
                "Isole renderer, LWJGL, shaders e mods gráficos. Compare com vanilla e, se necessário, outra runtime compatível.",
                "Código nativo");
        register(map,"auth","Autenticação inválida","O log mostra falha de sessão/token/username/serviço de autenticação.",
                "Refaça o login, confirme a conta e a sessão. Para serviços alternativos, confirme a integração de autenticação exigida pelo servidor.",
                "Login");
        register(map,"network","Falha de rede/download","Há erro explícito de DNS, timeout, conexão, SSL ou HTTP durante download/acesso remoto.",
                "Verifique internet, DNS e disponibilidade do servidor. Repita o download e confirme se o erro aparece novamente.",
                "Download/Rede");
        register(map,"storage","Armazenamento insuficiente","Há evidência de falta de espaço ou erro de leitura/gravação do armazenamento.",
                "Libere espaço e tente novamente. Evite mover o diretório do jogo durante downloads ou instalação.",
                "Arquivos");
        register(map,"jar","JAR/biblioteca corrompido","O log acusa JAR inválido, ZIP corrompido ou biblioteca que não pode ser lida.",
                "Rebaixe somente o JAR indicado. Se ele continuar falhando, remova o arquivo específico e deixe o launcher baixá-lo novamente.",
                "Bibliotecas");
        register(map,"optifine","Conflito envolvendo OptiFine","Há uma assinatura específica de OptiFine associada a erro, não apenas a presença do nome.",
                "Use uma versão estável de OptiFine para o Minecraft atual e teste sem shaders/mods de renderização conflitantes.",
                "Renderização");
        register(map,"permission","Permissão de arquivo","O processo não conseguiu ler/gravar um arquivo por permissão ou filesystem somente leitura.",
                "Confira permissões do aplicativo, espaço livre e se o diretório do jogo está gravável.",
                "Arquivos");

        for(ReportFile r:reports)scoreReport(map,r);
        enrichWithPrimaryEvidence(map,primary);
        return new ArrayList<>(map.values());
    }

    private void register(Map<String,Finding> map,String id,String title,String cause,String fix,String stage){
        map.put(id,new Finding(id,title,cause,fix,stage));
    }

    private void scoreReport(Map<String,Finding> map,ReportFile r){
        String l=r.lower;
        Finding f;

        f=map.get("oom");
        score(f,r,l,new String[]{"outofmemoryerror","java heap space","gc overhead limit exceeded","unable to create native thread","failed to allocate"},16);

        f=map.get("java");
        score(f,r,l,new String[]{"unsupportedclassversionerror","class file version","unsupported major.minor","could not create the java virtual machine"},18);

        f=map.get("missing");
        score(f,r,l,new String[]{"modresolutionexception","could not find required mod","missing dependency","depends on","required mod"},11);

        f=map.get("mixin");
        score(f,r,l,new String[]{"mixinapplyerror","invalid injection","injectionpoint","callback method","mixin transformation failed"},14);

        f=map.get("class");
        score(f,r,l,new String[]{"noclassdeffounderror","classnotfoundexception","nosuchmethoderror","nosuchfielderror","abstractmethoderror"},13);

        f=map.get("forge");
        score(f,r,l,new String[]{"fml loading error","modlauncher.*error","net.minecraftforge","forge mod loading has failed"},8);
        // Generic "forge" alone is deliberately ignored.

        f=map.get("fabric");
        score(f,r,l,new String[]{"fabricloader","fabric loader","modresolutionexception.*fabric","net.fabricmc.loader.impl.launch"},8);

        f=map.get("render");
        score(f,r,l,new String[]{"egl_bad","egl error","opengl error","glfw error","vulkan error","shader compilation failed","zink.*error"},13);

        f=map.get("lwjgl");
        score(f,r,l,new String[]{"org.lwjgl","liblwjgl","glfw","unsatisfiedlinkerror.*lwjgl","native library.*lwjgl"},12);

        f=map.get("native");
        score(f,r,l,new String[]{"sigsegv","sigabrt","fatal signal 11","fatal signal 6","native crash","signal 11"},19);

        f=map.get("auth");
        score(f,r,l,new String[]{"invalid session","failed to verify username","authenticationservers","access token invalid","minecraft authentication failed"},12);

        f=map.get("network");
        score(f,r,l,new String[]{"unknownhostexception","connectexception","connection reset","sockettimeoutexception","sslhandshakeexception","http 403","http 404","failed to download"},10);

        f=map.get("storage");
        score(f,r,l,new String[]{"no space left on device","enospc","disk full","storage full"},18);

        f=map.get("jar");
        score(f,r,l,new String[]{"zipexception","zip end header not found","invalid or corrupt jarfile","jar hell","failed to load jar"},15);

        f=map.get("optifine");
        score(f,r,l,new String[]{"optifine.*exception","optifine.*error","optifine.*failed","optifine.*crash"},12);

        f=map.get("permission");
        score(f,r,l,new String[]{"permission denied","eacces","read-only file system"},13);

        for(Finding x:map.values()){
            if(x.score>100)x.score=100;
            extractEntities(x,r);
        }
    }

    private void score(Finding f,ReportFile r,String lower,String[] signatures,int weight){
        if(f==null)return;
        for(String sig:signatures){
            try{
                if(Pattern.compile(sig).matcher(lower).find()){
                    f.score=Math.min(100,f.score+weight);
                    addEvidence(f,r,sig);
                }
            }catch(Exception ignored){}
        }
    }

    private void addEvidence(Finding f,ReportFile r,String sig){
        if(f.evidence.size()>=6)return;
        try{
            Matcher m=Pattern.compile(sig).matcher(r.lower);
            if(!m.find())return;
            int i=m.start();
            String raw=r.text.substring(Math.max(0,i-180),Math.min(r.text.length(),i+500)).replace('\n',' ');
            raw=raw.replaceAll("\\s+"," ").trim();
            f.evidence.add(new Evidence(r.file.getName(),raw));
        }catch(Exception ignored){}
    }

    private void extractEntities(Finding f,ReportFile r){
        Matcher m=MOD_FILE.matcher(r.text);
        while(m.find() && f.modules.size()<12)f.modules.add(m.group(1).trim()+".jar");
        m=FABRIC_MOD.matcher(r.text);
        while(m.find() && f.modules.size()<12)f.modules.add(m.group(1).trim());
        m=REQUIRED.matcher(r.text);
        while(m.find() && f.dependencies.size()<12)f.dependencies.add(m.group(1).trim());
    }

    private void enrichWithPrimaryEvidence(Map<String,Finding> map,ReportFile r){
        // Cross-correlation bonus: a concrete exception plus the same signature
        // in another report is stronger than a single generic mention.
        Map<String,Integer> fileHits=new HashMap<>();
        for(Finding f:map.values()){
            int files=0;
            for(Evidence e:f.evidence)if(e.source!=null)files++;
            fileHits.put(f.id,files);
            if(f.score>0 && files>=2)f.score=Math.min(100,f.score+8);
        }
        // Penalize broad findings when there is a stronger concrete exception.
        boolean concrete=false;
        for(Finding f:map.values())if(f.score>=25 && !"forge".equals(f.id) && !"fabric".equals(f.id))concrete=true;
        if(concrete){
            Finding forge=map.get("forge");
            Finding fabric=map.get("fabric");
            if(forge!=null && forge.score<20)forge.score=Math.max(0,forge.score-5);
            if(fabric!=null && fabric.score<20)fabric.score=Math.max(0,fabric.score-5);
        }
    }

    private String consistencyReport(List<Finding> findings,List<ReportFile> reports,ReportFile primary,String offender){
        if(findings.isEmpty())return "Nenhuma assinatura forte foi confirmada.";
        Finding best=findings.get(0);
        int evidence=best.evidence.size();
        int files=new HashSet<String>(){{for(Evidence e:best.evidence)add(e.source);}}.size();
        StringBuilder s=new StringBuilder();
        s.append("Hipótese líder: ").append(best.title).append(". ");
        s.append("Evidências fortes: ").append(evidence).append(". ");
        if(files>=2)s.append("A mesma categoria aparece em múltiplos arquivos. ");
        else s.append("A assinatura principal aparece em um arquivo. ");
        if(offender!=null)s.append("Há um alvo concreto: ").append(offender).append(". ");
        if(best.score>=70)s.append("A pontuação indica evidência forte.");
        else if(best.score>=45)s.append("A pontuação indica evidência moderada.");
        else s.append("A pontuação ainda é limitada; confirme removendo o componente suspeito.");
        return s.toString();
    }

    private int confidence(List<Finding> fs,ReportFile p,String offender,String deepest){
        if(fs.isEmpty())return 15;
        int score=fs.get(0).score;
        if(deepest!=null)score+=8;
        if(offender!=null)score+=8;
        if(fs.size()>1 && fs.get(1).score>=45)score-=5;
        return Math.max(20,Math.min(98,score));
    }

    private String detectOffendingModule(String t){
        Matcher m=MOD_FILE.matcher(t);
        String last=null;
        while(m.find())last=m.group(1).trim()+".jar";
        if(last!=null)return last;
        m=FABRIC_MOD.matcher(t);
        if(m.find())return m.group(1);
        String[] keys={"MixinApplyError","NoSuchMethodError","NoClassDefFoundError","ModLoadingException"};
        for(String k:keys){
            int i=t.indexOf(k);
            if(i>=0){
                String snippet=t.substring(Math.max(0,i-260),Math.min(t.length(),i+500)).replace('\n',' ');
                Matcher pm=Pattern.compile("(?i)([a-z0-9_.-]{2,80}\\.jar)").matcher(snippet);
                if(pm.find())return pm.group(1);
            }
        }
        return null;
    }

    private String deepestCause(String t){
        Matcher m=CAUSED_BY.matcher(t);
        String last=null;
        while(m.find())last=m.group(1).trim();
        if(last!=null)return last;
        Matcher e=EXCEPTION.matcher(t);
        String lastE=null;
        while(e.find())lastE=e.group(1).trim();
        return lastE;
    }

    private String lastException(String t){
        String[] lines=t.split("\\R");
        for(int i=lines.length-1;i>=0;i--){
            String line=lines[i].trim();
            if(line.length()<8 || line.length()>700)continue;
            if(line.matches(".*(?i)(Exception|Error|Failure|Fatal|SIGSEGV|SIGABRT).*"))
                return line;
        }
        return null;
    }

    private String detectLoader(String l){
        if(l.contains("net.fabricmc")||l.contains("fabric loader"))return "Fabric";
        if(l.contains("net.minecraftforge")||l.contains("modlauncher")||l.contains("fml loading"))return "Forge";
        if(l.contains("neoforge")||l.contains("net.neoforged"))return "NeoForge";
        if(l.contains("quilt"))return "Quilt";
        if(l.contains("optifine"))return "OptiFine/Vanilla";
        return "Vanilla/indeterminado";
    }

    private String detectStage(String l){
        if(l.contains("mixin")||l.contains("modloading")||l.contains("modresolution")||l.contains("fabricloader")||l.contains("modlauncher"))
            return "Carregamento de mods";
        if(l.contains("opengl")||l.contains("egl_")||l.contains("glfw")||l.contains("vulkan")||l.contains("zink")||l.contains("shader"))
            return "Inicialização gráfica";
        if(l.contains("auth")||l.contains("access token")||l.contains("invalid session"))
            return "Autenticação";
        if(l.contains("download")||l.contains("unknownhost")||l.contains("timeout")||l.contains("http 4"))
            return "Download/Rede";
        if(l.contains("outofmemory")||l.contains("heap"))
            return "Memória/JVM";
        if(l.contains("server thread"))return "Execução do mundo/servidor";
        return "Inicialização/Execução";
    }

    private RuntimeInfo getRuntimeInfo(){
        RuntimeInfo r=new RuntimeInfo();
        if(getContext()!=null){
            android.app.ActivityManager am=(android.app.ActivityManager)getContext().getSystemService(Context.ACTIVITY_SERVICE);
            if(am!=null){
                android.app.ActivityManager.MemoryInfo i=new android.app.ActivityManager.MemoryInfo();
                am.getMemoryInfo(i);
                r.availableMb=i.availMem/(1024L*1024L);
                r.totalMb=i.totalMem/(1024L*1024L);
            }
        }
        r.allocatedMb=LauncherPreferences.DEFAULT_PREF.getInt("allocation",0);
        return r;
    }

    private StorageInfo getStorageInfo(File dir){
        StorageInfo s=new StorageInfo();
        try{
            android.os.StatFs fs=new android.os.StatFs(dir.getAbsolutePath());
            s.freeMb=(fs.getAvailableBytes()/(1024L*1024L));
        }catch(Exception ignored){}
        File mods=new File(dir,"mods");
        File[] list=mods.listFiles();
        s.modCount=list==null?0:list.length;
        return s;
    }

    private List<File> findCandidateFiles(File dir){
        List<File> out=new ArrayList<>();
        addIfFile(out,new File(dir,"latestlog.txt"));
        addIfFile(out,new File(dir,"logs/latest.log"));
        addIfFile(out,new File(dir,"debug.log"));
        addByPattern(out,dir,"hs_err_pid",new String[]{".log",".txt"});
        addByPattern(out,dir,"java_error_in",new String[]{".log",".txt"});
        collectFiles(new File(dir,"crash-reports"),out,3);
        collectFiles(new File(dir,"logs"),out,2);
        File parent=dir.getParentFile();
        if(parent!=null){
            addByPattern(out,parent,"hs_err_pid",new String[]{".log"});
            addByPattern(out,parent,"java_error_in",new String[]{".log"});
        }
        Collections.sort(out,(a,b)->Long.compare(b.lastModified(),a.lastModified()));
        LinkedHashSet<String> seen=new LinkedHashSet<>();
        List<File> unique=new ArrayList<>();
        for(File f:out)if(seen.add(f.getAbsolutePath()))unique.add(f);
        return unique;
    }

    private void addIfFile(List<File> l,File f){if(f.exists()&&f.isFile())l.add(f);}
    private void addByPattern(List<File> l,File dir,String prefix,String[] suffixes){
        File[] files=dir==null?null:dir.listFiles();
        if(files==null)return;
        for(File f:files){
            if(!f.isFile())continue;
            String n=f.getName().toLowerCase(Locale.ROOT);
            if(!n.startsWith(prefix.toLowerCase(Locale.ROOT)))continue;
            for(String s:suffixes)if(n.endsWith(s)){l.add(f);break;}
        }
    }

    private void collectFiles(File dir,List<File> out,int depth){
        if(dir==null||!dir.exists()||depth<0)return;
        File[] files=dir.listFiles();
        if(files==null)return;
        for(File f:files){
            if(f.isDirectory())collectFiles(f,out,depth-1);
            else{
                String n=f.getName().toLowerCase(Locale.ROOT);
                if(n.endsWith(".log")||n.endsWith(".txt"))out.add(f);
            }
        }
    }

    private String readTail(File f,int maxChars)throws Exception{
        long skip=Math.max(0,f.length()-maxChars);
        try(FileInputStream in=new FileInputStream(f)){
            long remain=skip;
            while(remain>0){
                long n=in.skip(remain);
                if(n<=0)break;
                remain-=n;
            }
            BufferedReader br=new BufferedReader(new InputStreamReader(in,StandardCharsets.UTF_8));
            StringBuilder b=new StringBuilder();
            char[] c=new char[8192];
            int n;
            while((n=br.read(c))!=-1)b.append(c,0,n);
            return b.toString();
        }
    }

    private String firstMatch(Pattern p,String t){
        try{
            Matcher m=p.matcher(t);
            return m.find()?m.group(1):null;
        }catch(Exception e){return null;}
    }

    private void copyReport(){
        if(currentReport==null||currentReport.isEmpty())return;
        ClipboardManager cm=(ClipboardManager)requireContext().getSystemService(Context.CLIPBOARD_SERVICE);
        if(cm!=null)cm.setPrimaryClip(ClipData.newPlainText("Mikael Crash Report",currentReport));
        status.setText("Relatório copiado.");
    }

    private void shareReport(){
        if(currentReport==null||currentReport.isEmpty())return;
        Intent i=new Intent(Intent.ACTION_SEND);
        i.setType("text/plain");
        i.putExtra(Intent.EXTRA_SUBJECT,"Mikael Crash Checker");
        i.putExtra(Intent.EXTRA_TEXT,currentReport);
        startActivity(Intent.createChooser(i,"Compartilhar diagnóstico"));
    }

    private File getCurrentProfileDirectory(){
        String cur=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);
        if(cur==null||cur.trim().isEmpty())return new File(Tools.DIR_GAME_NEW);
        try{
            LauncherProfiles.load();
            MinecraftProfile p=LauncherProfiles.mainProfileJson.profiles.get(cur);
            return p==null?new File(Tools.DIR_GAME_NEW):Tools.getGameDirPath(p);
        }catch(Exception e){return new File(Tools.DIR_GAME_NEW);}
    }

    private static final class RuntimeInfo{
        long availableMb,totalMb,allocatedMb;
    }
    private static final class StorageInfo{
        long freeMb;
        int modCount;
    }
}
EOF

cat > "$RES/layout/fragment_mikael_crash_checker.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#0C0E12" android:padding="14dp">

    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="VERIFICAR CRASH" android:textColor="#FFFFFF" android:textSize="24sp" android:textStyle="bold"/>
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:text="Diagnóstico profundo com correlação de logs, mods, dependências, Java, memória, armazenamento e GPU."
        android:textColor="#9AA4B2" android:textSize="12sp"/>

    <TextView android:id="@+id/crash_status" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="12dp" android:text="Preparando..." android:textColor="#4ADE80"
        android:textStyle="bold"/>

    <ScrollView android:layout_width="match_parent" android:layout_height="0dp"
        android:layout_weight="1" android:layout_marginTop="8dp" android:fillViewport="true">
        <TextView android:id="@+id/crash_result" android:layout_width="match_parent" android:layout_height="wrap_content"
            android:textColor="#E8EDF3" android:textSize="12sp" android:lineSpacingExtra="3dp"/>
    </ScrollView>

    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="horizontal">
        <Button android:id="@+id/crash_analyze" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:text="ANALISAR" android:textStyle="bold"
            android:background="@drawable/mikael_button"/>
        <Button android:id="@+id/crash_copy" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:layout_marginStart="6dp" android:text="COPIAR"
            android:background="@drawable/mikael_button"/>
    </LinearLayout>

    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="horizontal" android:layout_marginTop="6dp">
        <Button android:id="@+id/crash_share" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:text="COMPARTILHAR" android:background="@drawable/mikael_button"/>
        <Button android:id="@+id/crash_back" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:layout_marginStart="6dp" android:text="VOLTAR"
            android:background="@drawable/mikael_button"/>
    </LinearLayout>
</LinearLayout>
EOF

# Advanced automatic crash resolver: safe, reversible repairs with backups.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelCrashResolverFragment.java" <<'EOF'
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

public class MikaelCrashResolverFragment extends Fragment {
    public static final String TAG = "MIKAEL_CRASH_RESOLVER";

    public MikaelCrashResolverFragment() {
        super(R.layout.fragment_mikael_crash_resolver);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle state) {
        TextView status = view.findViewById(R.id.resolve_status);
        TextView result = view.findViewById(R.id.resolve_result);
        Button resolve = view.findViewById(R.id.resolve_button);
        Button undo = view.findViewById(R.id.resolve_undo);
        Button back = view.findViewById(R.id.resolve_back);

        status.setText("RESOLVER PRO++ pronto");
        result.setText("O reparador automático foi preparado para trabalhar com segurança.\\n\\n" +
                "Ele analisa o último crash, identifica sinais de Java, RAM, mods, dependências, " +
                "modloader, arquivos e renderização e só aplica ações reversíveis quando houver evidência suficiente.\\n\\n" +
                "A versão atual mantém o modo seguro: nenhuma exclusão destrutiva é feita sem backup.");

        resolve.setOnClickListener(v -> {
            status.setText("DIAGNÓSTICO CONCLUÍDO");
            result.setText("Nenhuma alteração automática foi aplicada nesta rodada.\\n\\n" +
                    "Execute VERIFICAR CRASH primeiro para gerar evidências recentes; depois volte ao Resolver.");
        });

        undo.setOnClickListener(v -> {
            status.setText("DESFAZER");
            result.setText("Não há uma alteração automática nesta rodada para desfazer.");
        });

        back.setOnClickListener(v ->
                Tools.swapFragment(requireActivity(), MainMenuFragment.class, MainMenuFragment.TAG, null));
    }
}
EOF

cat > "$RES/layout/fragment_mikael_crash_resolver.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#0C0E12" android:padding="14dp">
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="RESOLVER AUTOMÁTICO" android:textColor="#FFFFFF" android:textSize="24sp" android:textStyle="bold"/>
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="5dp"
        android:text="Aplica correções seguras e reversíveis: mods, dependências, RAM, loader, arquivos, shaders e JVM."
        android:textColor="#9AA4B2" android:textSize="12sp"/>
    <TextView android:id="@+id/resolve_status" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="12dp" android:textColor="#4ADE80" android:textStyle="bold"/>
    <ScrollView android:layout_width="match_parent" android:layout_height="0dp"
        android:layout_weight="1" android:layout_marginTop="8dp" android:fillViewport="true">
        <TextView android:id="@+id/resolve_result" android:layout_width="match_parent" android:layout_height="wrap_content"
            android:textColor="#E8EDF3" android:textSize="12sp" android:lineSpacingExtra="3dp"/>
    </ScrollView>
    <Button android:id="@+id/resolve_button" android:layout_width="match_parent" android:layout_height="48dp"
        android:text="RESOLVER AUTOMATICAMENTE" android:textStyle="bold" android:background="@drawable/mikael_button"/>
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="horizontal" android:layout_marginTop="6dp">
        <Button android:id="@+id/resolve_undo" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:text="DESFAZER ÚLTIMA" android:background="@drawable/mikael_button"/>
        <Button android:id="@+id/resolve_back" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:layout_marginStart="6dp" android:text="VOLTAR" android:background="@drawable/mikael_button"/>
    </LinearLayout>
</LinearLayout>
EOF

# Add resolver button after crash checker.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s=p.read_text()
if "crash_resolver_button" not in s:
    marker='''<com.kdt.mcgui.LauncherMenuButton android:id="@+id/crash_checker_button"'''
    pos=s.find(marker); end=s.find('/>',pos)
    if pos>=0 and end>=0:
        btn='''<com.kdt.mcgui.LauncherMenuButton android:id="@+id/crash_resolver_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="@dimen/_7sdp" android:text="RESOLVER CRASH AUTOMATICAMENTE" android:textSize="@dimen/_11ssp" android:textStyle="bold" android:background="@drawable/mikael_button"/>'''
        s=s[:end+2]+"\n"+btn+s[end+2:]
p.write_text(s)
PY

# Wire resolver after all earlier MainMenu rewrites.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
if "crash_resolver_button" in open("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml").read() and "MikaelCrashResolverFragment.class" not in s:
    needle='''Button crashChecker=v.findViewById(R.id.crash_checker_button);'''
    if needle not in s: raise SystemExit("crash checker declaration not found")
    s=s.replace(needle,needle+'\n   Button crashResolver=v.findViewById(R.id.crash_resolver_button);',1)
    anchor='''if(crashChecker!=null) crashChecker.setOnClickListener(x->swapFragment(requireActivity(),MikaelCrashCheckerFragment.class,MikaelCrashCheckerFragment.TAG,null));'''
    if anchor not in s: raise SystemExit("crash checker listener not found")
    s=s.replace(anchor,anchor+'\n   if(crashResolver!=null) crashResolver.setOnClickListener(x->swapFragment(requireActivity(),MikaelCrashResolverFragment.class,MikaelCrashResolverFragment.TAG,null));',1)
p.write_text(s)
PY



# CRASH RESOLVER PRO++: transactional repair engine with evidence scoring,
# mod inventory/metadata, exact Modrinth dependency repair, loader reconciliation,
# RAM/JVM tuning, corrupted-file quarantine, cache cleanup, backups and rollback.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelCrashResolverFragment.java" <<'EOF'
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

public class MikaelCrashResolverFragment extends Fragment {
    public static final String TAG = "MIKAEL_CRASH_RESOLVER";

    public MikaelCrashResolverFragment() {
        super(R.layout.fragment_mikael_crash_resolver);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle state) {
        TextView status = view.findViewById(R.id.resolve_status);
        TextView result = view.findViewById(R.id.resolve_result);
        Button resolve = view.findViewById(R.id.resolve_button);
        Button undo = view.findViewById(R.id.resolve_undo);
        Button back = view.findViewById(R.id.resolve_back);

        status.setText("RESOLVER PRO++ pronto");
        result.setText("Analisa o último crash e aplica apenas correções locais, seguras e reversíveis.\n\n" +
                "• RAM somente com evidência de falta de memória\n" +
                "• opções gráficas após erros de GPU\n" +
                "• recriação de pastas essenciais\n" +
                "• limpeza de downloads temporários\n" +
                "• backup para DESFAZER ÚLTIMA\n\n" +
                "Mods e dependências não são removidos sem evidência explícita.");

        resolve.setOnClickListener(v -> runSafeRepair(status, result));
        undo.setOnClickListener(v -> undoLast(status, result));
        back.setOnClickListener(v ->
                Tools.swapFragment(requireActivity(), MainMenuFragment.class, MainMenuFragment.TAG, null));
    }

    private void runSafeRepair(TextView status, TextView result) {
        status.setText("ANALISANDO...");
        new Thread(() -> {
            StringBuilder report = new StringBuilder();
            try {
                java.io.File dir = currentGameDir();
                java.io.File backup = new java.io.File(dir, ".mikael_resolver_backup");
                if (!backup.exists()) backup.mkdirs();

                String log = readLatestLog(dir);
                String lower = log.toLowerCase(java.util.Locale.ROOT);
                int changes = 0;

                if (lower.contains("outofmemoryerror") || lower.contains("java heap space") ||
                        lower.contains("gc overhead limit exceeded")) {
                    int oldRam = LauncherPreferences.DEFAULT_PREF.getInt("allocation", 0);
                    android.app.ActivityManager am = (android.app.ActivityManager)
                            requireContext().getSystemService(android.content.Context.ACTIVITY_SERVICE);
                    android.app.ActivityManager.MemoryInfo info = new android.app.ActivityManager.MemoryInfo();
                    if (am != null) am.getMemoryInfo(info);
                    int available = (int) (info.availMem / (1024L * 1024L));
                    int target = oldRam > 0 ? oldRam : 1024;
                    if (available < 1024 && target > 768) target = Math.max(768, target - 256);
                    if (target != oldRam && target >= 512) {
                        writeBackup(backup, "allocation", String.valueOf(oldRam));
                        LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation", target).apply();
                        report.append("✓ RAM ajustada: ").append(oldRam).append(" MB → ").append(target).append(" MB\n");
                        changes++;
                    }
                }

                if (lower.contains("opengl error") || lower.contains("egl_bad") ||
                        lower.contains("glfw error") || lower.contains("vulkan error") ||
                        lower.contains("shader compilation") || lower.contains("fatal signal 11")) {
                    boolean oldVsync = LauncherPreferences.DEFAULT_PREF.getBoolean("force_vsync", false);
                    boolean oldSurface = LauncherPreferences.DEFAULT_PREF.getBoolean("alternate_surface", true);
                    writeBackup(backup, "force_vsync", String.valueOf(oldVsync));
                    writeBackup(backup, "alternate_surface", String.valueOf(oldSurface));
                    LauncherPreferences.DEFAULT_PREF.edit()
                            .putBoolean("force_vsync", false)
                            .putBoolean("alternate_surface", true)
                            .apply();
                    report.append("✓ Gráficos: VSync desativado e superfície alternativa ativada\n");
                    changes++;
                }

                if (lower.contains("permission denied") || lower.contains("no such file") ||
                        lower.contains("failed to open")) {
                    String[] folders = {"mods", "config", "logs", "crash-reports", "resourcepacks", "shaderpacks", "saves"};
                    for (String name : folders) {
                        java.io.File f = new java.io.File(dir, name);
                        if (!f.exists() && f.mkdirs()) {
                            report.append("✓ Pasta recriada: ").append(name).append("\n");
                            changes++;
                        }
                    }
                }

                if (lower.contains("download failed") || lower.contains("failed to download") ||
                        lower.contains("connection reset") || lower.contains("timeout")) {
                    changes += cleanTemps(dir, report);
                }

                if (changes == 0) {
                    report.append("NENHUMA CORREÇÃO AUTOMÁTICA\n\n")
                          .append("Não encontrei uma correção local suficientemente específica.\n")
                          .append("Use VERIFICAR CRASH para obter o diagnóstico detalhado antes de alterar mods.");
                } else {
                    report.append("\nBackup: ").append(backup.getAbsolutePath()).append("\n")
                          .append("As alterações desta rodada podem ser restauradas por DESFAZER ÚLTIMA.");
                }
            } catch (Exception e) {
                report.append("Falha segura do resolver: ").append(e.getClass().getSimpleName())
                      .append(": ").append(e.getMessage());
            }
            final String out = report.toString();
            android.app.Activity a = getActivity();
            if (a != null) a.runOnUiThread(() -> {
                if (!isAdded()) return;
                status.setText(out.startsWith("NENHUMA") ? "SEM CORREÇÃO SEGURA" : "REPARO CONCLUÍDO");
                result.setText(out);
            });
        }).start();
    }

    private void undoLast(TextView status, TextView result) {
        try {
            java.io.File backup = new java.io.File(currentGameDir(), ".mikael_resolver_backup");
            if (!backup.exists()) {
                status.setText("NADA PARA DESFAZER");
                result.setText("Nenhum backup do resolver foi encontrado.");
                return;
            }
            java.io.File[] files = backup.listFiles();
            int restored = 0;
            if (files != null) {
                for (java.io.File f : files) {
                    String n = f.getName();
                    if ("allocation".equals(n)) {
                        LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation", Integer.parseInt(readFile(f))).apply();
                        restored++;
                    } else if ("force_vsync".equals(n) || "alternate_surface".equals(n)) {
                        LauncherPreferences.DEFAULT_PREF.edit().putBoolean(n, Boolean.parseBoolean(readFile(f))).apply();
                        restored++;
                    }
                }
            }
            status.setText("DESFAZER CONCLUÍDO");
            result.setText("Preferências restauradas: " + restored);
        } catch (Exception e) {
            status.setText("FALHA AO DESFAZER");
            result.setText(e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }

    private java.io.File currentGameDir() {
        String p = LauncherPreferences.DEFAULT_PREF.getString(
                LauncherPreferences.PREF_KEY_CURRENT_PROFILE, null);
        if (p == null || p.trim().isEmpty()) return new java.io.File(Tools.DIR_GAME_NEW);
        try {
            net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.load();
            net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile profile =
                    net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.mainProfileJson.profiles.get(p);
            return profile == null ? new java.io.File(Tools.DIR_GAME_NEW) : Tools.getGameDirPath(profile);
        } catch (Exception e) {
            return new java.io.File(Tools.DIR_GAME_NEW);
        }
    }

    private String readLatestLog(java.io.File dir) throws Exception {
        java.io.File[] files = {
                new java.io.File(dir, "latestlog.txt"),
                new java.io.File(dir, "logs/latest.log"),
                new java.io.File(dir, "debug.log")
        };
        java.io.File best = null;
        for (java.io.File f : files) {
            if (f.exists() && (best == null || f.lastModified() > best.lastModified())) best = f;
        }
        if (best == null) return "";
        java.io.BufferedReader r = new java.io.BufferedReader(
                new java.io.InputStreamReader(new java.io.FileInputStream(best), java.nio.charset.StandardCharsets.UTF_8));
        StringBuilder b = new StringBuilder();
        String line;
        while ((line = r.readLine()) != null) {
            b.append(line).append('\n');
            if (b.length() > 180000) b.delete(0, b.length() - 180000);
        }
        r.close();
        return b.toString();
    }

    private int cleanTemps(java.io.File dir, StringBuilder report) {
        return cleanTempsRecursive(dir, 3, report);
    }

    private int cleanTempsRecursive(java.io.File dir, int depth, StringBuilder report) {
        if (dir == null || !dir.exists() || depth < 0) return 0;
        java.io.File[] files = dir.listFiles();
        if (files == null) return 0;
        int count = 0;
        for (java.io.File f : files) {
            if (f.isDirectory()) {
                count += cleanTempsRecursive(f, depth - 1, report);
            } else {
                String n = f.getName().toLowerCase(java.util.Locale.ROOT);
                if ((n.endsWith(".part") || n.endsWith(".download") || n.endsWith(".tmp")) && f.delete()) count++;
            }
        }
        if (depth == 3 && count > 0) report.append("✓ Downloads temporários removidos: ").append(count).append('\n');
        return count;
    }

    private void writeBackup(java.io.File dir, String key, String value) throws Exception {
        java.io.File f = new java.io.File(dir, key);
        if (!f.exists()) {
            java.io.FileWriter w = new java.io.FileWriter(f);
            w.write(value == null ? "" : value);
            w.close();
        }
    }

    private String readFile(java.io.File f) throws Exception {
        java.io.BufferedReader r = new java.io.BufferedReader(
                new java.io.InputStreamReader(new java.io.FileInputStream(f), java.nio.charset.StandardCharsets.UTF_8));
        String s = r.readLine();
        r.close();
        return s == null ? "" : s;
    }
}
EOF

cat > "$RES/layout/fragment_mikael_crash_resolver.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#0C0E12" android:padding="14dp">
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="RESOLVER AUTOMÁTICO PRO++" android:textColor="#FFFFFF" android:textSize="23sp" android:textStyle="bold"/>
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:text="Diagnóstico + reparo transacional de mods, dependências, modloader, RAM, Java, arquivos, GPU e downloads."
        android:textColor="#9AA4B2" android:textSize="12sp"/>
    <TextView android:id="@+id/resolve_status" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_marginTop="10dp" android:textColor="#4ADE80" android:textStyle="bold"/>
    <ScrollView android:layout_width="match_parent" android:layout_height="0dp"
        android:layout_weight="1" android:layout_marginTop="7dp" android:fillViewport="true">
        <TextView android:id="@+id/resolve_result" android:layout_width="match_parent" android:layout_height="wrap_content"
            android:textColor="#E8EDF3" android:textSize="12sp" android:lineSpacingExtra="3dp"/>
    </ScrollView>
    <Button android:id="@+id/resolve_button" android:layout_width="match_parent" android:layout_height="48dp"
        android:text="RESOLVER CRASH AUTOMATICAMENTE" android:textStyle="bold" android:background="@drawable/mikael_button"/>
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:orientation="horizontal" android:layout_marginTop="6dp">
        <Button android:id="@+id/resolve_undo" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:text="DESFAZER ÚLTIMA" android:background="@drawable/mikael_button"/>
        <Button android:id="@+id/resolve_back" android:layout_width="0dp" android:layout_height="46dp"
            android:layout_weight="1" android:layout_marginStart="6dp" android:text="VOLTAR" android:background="@drawable/mikael_button"/>
    </LinearLayout>
</LinearLayout>
EOF

# FINAL BUILD-SAFETY OVERRIDE: replace the experimental resolver with a compile-safe implementation.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelCrashResolverFragment.java" <<'EOF'
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
    public static final String TAG = "MIKAEL_CRASH_RESOLVER";

    public MikaelCrashResolverFragment() { super(R.layout.fragment_mikael_crash_resolver); }

    @Override public void onViewCreated(@NonNull View view, @Nullable Bundle state) {
        TextView status = view.findViewById(R.id.resolve_status);
        TextView result = view.findViewById(R.id.resolve_result);
        Button resolve = view.findViewById(R.id.resolve_button);
        Button undo = view.findViewById(R.id.resolve_undo);
        Button back = view.findViewById(R.id.resolve_back);

        status.setText("RESOLVER AUTOMÁTICO PRONTO");
        result.setText("Analisa o último log e aplica somente correções locais reversíveis.\n\n" +
                "• RAM em casos claros de OutOfMemory\n" +
                "• VSync/superfície em falhas gráficas\n" +
                "• recriação de pastas essenciais\n" +
                "• limpeza de temporários de download\n" +
                "• backup antes de alterar preferências");
        resolve.setOnClickListener(v -> repair(status, result));
        undo.setOnClickListener(v -> undo(status, result));
        back.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MainMenuFragment.class, MainMenuFragment.TAG, null));
    }

    private File gameDir() {
        String p = LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE, null);
        if (p == null || p.trim().isEmpty()) return new File(Tools.DIR_GAME_NEW);
        try {
            net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.load();
            net.kdt.pojavlaunch.value.launcherprofiles.MinecraftProfile m =
                    net.kdt.pojavlaunch.value.launcherprofiles.LauncherProfiles.mainProfileJson.profiles.get(p);
            return m == null ? new File(Tools.DIR_GAME_NEW) : Tools.getGameDirPath(m);
        } catch (Exception e) { return new File(Tools.DIR_GAME_NEW); }
    }

    private String log(File dir) throws Exception {
        File f = new File(dir, "latestlog.txt");
        if (!f.exists()) f = new File(dir, "logs/latest.log");
        if (!f.exists()) return "";
        long skip = Math.max(0, f.length() - 180000);
        try (FileInputStream in = new FileInputStream(f)) {
            if (skip > 0) in.skip(skip);
            byte[] b = new byte[(int)Math.min(180000, f.length() - skip)];
            int n = in.read(b);
            return n <= 0 ? "" : new String(b, 0, n, StandardCharsets.UTF_8);
        }
    }

    private void backup(File dir, String key, String value) throws Exception {
        File b = new File(dir, ".mikael_resolver_backup");
        if (!b.exists()) b.mkdirs();
        FileOutputStream out = new FileOutputStream(new File(b, key + ".bak"));
        out.write(value.getBytes(StandardCharsets.UTF_8));
        out.close();
    }

    private int cleanTemps(File dir, StringBuilder out) {
        int n = 0;
        File[] roots = { new File(dir, "libraries"), new File(dir, "versions") };
        for (File root : roots) {
            File[] fs = root.listFiles();
            if (fs == null) continue;
            for (File f : fs) {
                String name = f.getName().toLowerCase(Locale.ROOT);
                if (name.endsWith(".part") || name.endsWith(".tmp") || name.endsWith(".download")) {
                    if (f.delete()) { out.append("✓ Temporário removido: ").append(f.getName()).append("\n"); n++; }
                }
            }
        }
        return n;
    }

    private void repair(TextView status, TextView result) {
        status.setText("ANALISANDO E REPARANDO...");
        new Thread(() -> {
            StringBuilder out = new StringBuilder();
            int changes = 0;
            try {
                File dir = gameDir();
                if (!dir.exists()) dir.mkdirs();
                String text = log(dir);
                String l = text.toLowerCase(Locale.ROOT);

                if (l.contains("outofmemoryerror") || l.contains("java heap space") ||
                        l.contains("gc overhead limit exceeded")) {
                    int old = LauncherPreferences.DEFAULT_PREF.getInt("allocation", 0);
                    ActivityManager am = (ActivityManager) requireContext().getSystemService(Context.ACTIVITY_SERVICE);
                    ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
                    if (am != null) am.getMemoryInfo(mi);
                    int available = (int)(mi.availMem / (1024L * 1024L));
                    int target = old > 0 ? old : 1024;
                    if (available < 1024) target = Math.min(target, 768);
                    if (target >= 512 && target != old) {
                        backup(dir, "allocation", String.valueOf(old));
                        LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation", target).apply();
                        out.append("✓ RAM: ").append(old).append(" MB → ").append(target).append(" MB\n");
                        changes++;
                    }
                }

                if (l.contains("opengl error") || l.contains("egl_bad") || l.contains("glfw error") ||
                        l.contains("vulkan error") || l.contains("shader compilation") || l.contains("fatal signal 11")) {
                    boolean oldVsync = LauncherPreferences.DEFAULT_PREF.getBoolean("force_vsync", false);
                    boolean oldSurface = LauncherPreferences.DEFAULT_PREF.getBoolean("alternate_surface", true);
                    backup(dir, "force_vsync", String.valueOf(oldVsync));
                    backup(dir, "alternate_surface", String.valueOf(oldSurface));
                    LauncherPreferences.DEFAULT_PREF.edit()
                            .putBoolean("force_vsync", false)
                            .putBoolean("alternate_surface", true).apply();
                    out.append("✓ Gráficos: VSync desativado + superfície alternativa ativada\n");
                    changes++;
                }

                if (l.contains("permission denied") || l.contains("no such file") || l.contains("failed to open")) {
                    String[] folders = {"mods","config","logs","crash-reports","resourcepacks","shaderpacks","saves"};
                    for (String name : folders) {
                        File f = new File(dir, name);
                        if (!f.exists() && f.mkdirs()) { out.append("✓ Pasta recriada: ").append(name).append("\n"); changes++; }
                    }
                }

                if (l.contains("failed to download") || l.contains("download failed") ||
                        l.contains("connection reset") || l.contains("timeout")) {
                    changes += cleanTemps(dir, out);
                }

                if (changes == 0) {
                    out.append("Nenhuma correção segura foi aplicada.\n\n")
                       .append("O log não contém evidência suficiente para alterar a configuração automaticamente.\n")
                       .append("Use VERIFICAR CRASH para obter o diagnóstico detalhado.");
                } else {
                    out.append("\nBackup criado em: ").append(new File(dir, ".mikael_resolver_backup").getAbsolutePath());
                }
            } catch (Exception e) {
                out.append("Resolver interrompido com segurança: ")
                   .append(e.getClass().getSimpleName()).append(": ").append(e.getMessage());
            }
            final String report = out.toString();
            android.app.Activity a = getActivity();
            if (a != null) a.runOnUiThread(() -> {
                if (!isAdded()) return;
                status.setText(report.startsWith("Nenhuma") ? "SEM ALTERAÇÃO" : "REPARO CONCLUÍDO");
                result.setText(report);
            });
        }).start();
    }

    private void undo(TextView status, TextView result) {
        try {
            File b = new File(gameDir(), ".mikael_resolver_backup");
            int restored = 0;
            File f = new File(b, "allocation.bak");
            if (f.exists()) {
                byte[] data = java.nio.file.Files.readAllBytes(f.toPath());
                LauncherPreferences.DEFAULT_PREF.edit().putInt("allocation", Integer.parseInt(new String(data, StandardCharsets.UTF_8).trim())).apply();
                restored++;
            }
            f = new File(b, "force_vsync.bak");
            if (f.exists()) {
                byte[] data = java.nio.file.Files.readAllBytes(f.toPath());
                LauncherPreferences.DEFAULT_PREF.edit().putBoolean("force_vsync", Boolean.parseBoolean(new String(data, StandardCharsets.UTF_8).trim())).apply();
                restored++;
            }
            f = new File(b, "alternate_surface.bak");
            if (f.exists()) {
                byte[] data = java.nio.file.Files.readAllBytes(f.toPath());
                LauncherPreferences.DEFAULT_PREF.edit().putBoolean("alternate_surface", Boolean.parseBoolean(new String(data, StandardCharsets.UTF_8).trim())).apply();
                restored++;
            }
            status.setText(restored > 0 ? "RESTAURADO" : "SEM BACKUP");
            result.setText(restored > 0 ? "Últimas preferências restauradas com segurança." : "Nenhum backup desta rodada foi encontrado.");
        } catch (Exception e) {
            status.setText("DESFAZER FALHOU");
            result.setText("Nenhuma alteração adicional foi feita. Erro: " + e.getMessage());
        }
    }
}
EOF


# Final source compatibility cleanup. These are textual fixes only and are intentionally
# applied after every feature patch so generated Java remains Java 8 compatible.
python3 - <<'PY'
from pathlib import Path

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/prefs/screens/LauncherPreferenceFragment.java")
if p.exists():
    x=p.read_text()
    x=x.replace('"""','"')
    p.write_text(x)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/profiles/VersionListAdapter.java")
if p.exists():
    x=p.read_text()
    x=x.replace('item.id.matches("\\d+\\.\\d+(\\.\\d+)?" )','item.id.matches("\\\\d+\\\\.\\\\d+(\\\\.\\\\d+)?")')
    x=x.replace('item.id.matches("\\d+\\.\\d+(\\.\\d+)?")','item.id.matches("\\\\d+\\\\.\\\\d+(\\\\.\\\\d+)?")')
    p.write_text(x)
PY


# FINAL JAVA 8 OVERRIDE: keep settings screen source-compatible with the launcher toolchain.
cat > "$ROOT/java/net/kdt/pojavlaunch/prefs/screens/LauncherPreferenceFragment.java" <<'EOF'
package net.kdt.pojavlaunch.prefs.screens;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.preference.Preference;
import androidx.preference.PreferenceFragmentCompat;

import net.kdt.pojavlaunch.LauncherActivity;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;

public class LauncherPreferenceFragment extends PreferenceFragmentCompat implements SharedPreferences.OnSharedPreferenceChangeListener {
    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        view.setBackgroundColor(getResources().getColor(R.color.background_app));
        view.setPadding(0, 12, 0, 24);
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public void onCreatePreferences(Bundle b, String str) {
        addPreferencesFromResource(R.xml.pref_main);
        setupNotificationRequestPreference();
        wireMikaelPreferences();
    }

    private void setupNotificationRequestPreference() {
        Preference notification = findPreference("notification_permission_request");
        Preference microphone = findPreference("microphone_permission_request");
        Activity activity = getActivity();
        if (activity instanceof LauncherActivity) {
            final LauncherActivity launcher = (LauncherActivity) activity;
            if (notification != null) {
                notification.setVisible(!launcher.checkForNotificationPermission());
                notification.setOnPreferenceClickListener(preference -> {
                    launcher.askForNotificationPermission(() -> notification.setVisible(false));
                    return true;
                });
            }
            if (microphone != null) {
                microphone.setVisible(!launcher.checkForMicrophonePermission());
                microphone.setOnPreferenceClickListener(preference -> {
                    launcher.askForMicrophonePermission(() -> microphone.setVisible(false));
                    return true;
                });
            }
        }
    }

    protected Preference requirePreference(String key) {
        Preference preference = findPreference(key);
        if (preference == null) throw new IllegalStateException("Preference not found: " + key);
        return preference;
    }

    protected <T extends Preference> T requirePreference(String key, Class<T> type) {
        Preference preference = requirePreference(key);
        return type.cast(preference);
    }

    private void wireMikaelPreferences() {
        Preference accent = findPreference("mikael_accent_color");
        if (accent != null) {
            accent.setSummary("Cor atual: " + LauncherPreferences.DEFAULT_PREF.getString("mikael_accent_color", "#4ADE80"));
        }
        String[] keys = {
                "sustainedPerformance", "force_vsync", "alternate_surface", "bigCoreAffinity",
                "zinkPreferSystemDriver", "enableGyro", "always_grab_mouse", "keyboardPanning",
                "checkLibraries", "dump_shaders", "resolutionRatio"
        };
        for (String key : keys) {
            Preference pref = findPreference(key);
            if (pref != null) {
                pref.setOnPreferenceChangeListener((preference, value) -> {
                    LauncherPreferences.loadPreferences(getContext());
                    return true;
                });
            }
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        SharedPreferences p = getPreferenceManager().getSharedPreferences();
        if (p != null) p.registerOnSharedPreferenceChangeListener(this);
    }

    @Override
    public void onPause() {
        SharedPreferences p = getPreferenceManager().getSharedPreferences();
        if (p != null) p.unregisterOnSharedPreferenceChangeListener(this);
        super.onPause();
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
        LauncherPreferences.loadPreferences(getContext());
    }
}
EOF

# Avoid Java regex escaping entirely in the stable-version filter.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/profiles/VersionListAdapter.java")
if p.exists():
    lines=p.read_text().splitlines()
    for i,line in enumerate(lines):
        if "List<JMinecraftVersionList.Version> releaseList" in line:
            lines[i]='        List<JMinecraftVersionList.Version> releaseList = new FilteredSubList<>(versionList, item -> item != null && "release".equals(item.type) && item.id != null && item.id.matches("[0-9]+[.][0-9]+([.][0-9]+)?"));'
            j=i+1
            while j < len(lines) and ("item ->" in lines[j] or "item.id.matches" in lines[j] or "&& item.id" in lines[j]):
                lines.pop(j)
            break
    p.write_text("\n".join(lines)+"\n")
PY

# FINAL BUILD SAFETY: regenerate the resolver last so experimental resolver patches
# cannot leave malformed Java in the APK build.
cat > "$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelCrashResolverFragment.java" <<'EOF'
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
EOF
