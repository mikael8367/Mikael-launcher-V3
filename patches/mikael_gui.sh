#!/usr/bin/env bash
set -euo pipefail
# Build safety: optional Modrinth compatibility patches must never abort the entire patch.
ROOT=app_pojavlauncher/src/main
RES=$ROOT/res
JAVA=$ROOT/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java
MFO_JAVA=$ROOT/java/net/kdt/pojavlaunch/fragments/MikaelForgeOptiFineFragment.java
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
  Button controls=v.findViewById(R.id.custom_control_button),settings=v.findViewById(R.id.settings_button),files=v.findViewById(R.id.open_files_button),logs=v.findViewById(R.id.share_logs_button),install=v.findViewById(R.id.install_jar_button),play=v.findViewById(R.id.play_button);
  ImageButton profile=v.findViewById(R.id.edit_profile_button); mVersionSpinner=v.findViewById(R.id.mc_version_spinner);
  Button modLibrary=v.findViewById(R.id.mod_library_button),contentLibrary=v.findViewById(R.id.content_library_button),forgeOptiFine=v.findViewById(R.id.forge_optifine_button);
  if(controls!=null) controls.setOnClickListener(x->startActivity(new Intent(requireContext(),CustomControlsActivity.class)));
  if(settings!=null) settings.setOnClickListener(x->swapFragment(requireActivity(),LauncherPreferenceFragment.class,LauncherActivity.SETTING_FRAGMENT_TAG,null));
  if(logs!=null) logs.setOnClickListener(x->shareLog(requireContext()));
  if(files!=null) files.setOnClickListener(x->openPath(requireContext(),getCurrentProfileDirectory(),false));
  if(install!=null) { install.setOnClickListener(x->runInstaller(false)); install.setOnLongClickListener(x->{runInstaller(true);return true;}); }
  if(modLibrary!=null) modLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelModLibraryFragment.class,MikaelModLibraryFragment.TAG,null));
  if(contentLibrary!=null) contentLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelContentLibraryFragment.class,MikaelContentLibraryFragment.TAG,null));
  if(forgeOptiFine!=null) forgeOptiFine.setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));
  if(profile!=null && mVersionSpinner!=null) profile.setOnClickListener(x->mVersionSpinner.openProfileEditor(requireActivity()));
  if(play!=null) play.setOnClickListener(x->{if(hasMods("sodium")&&!LauncherPreferences.DEFAULT_PREF.getBoolean("sodium_override",false)){new AlertDialog.Builder(requireContext()).setTitle(R.string.sodium_warning_title).setMessage(R.string.sodium_warning_message).setNeutralButton(R.string.delete_sodium,(d,w)->{deleteSodiumMods();ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);}).show();}else ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);});
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
cat > "$MFO_JAVA" <<'EOF'
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
