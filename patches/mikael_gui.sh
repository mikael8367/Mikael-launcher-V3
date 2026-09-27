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
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/open_files_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="ARQUIVOS" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/share_logs_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="LOGS" android:background="@drawable/mikael_button"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal">
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/news_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="NOTÍCIAS" android:background="@drawable/mikael_button"/>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/discord_button" style="@style/LauncherMenuButton.Universal" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="@dimen/_6sdp" android:text="COMUNIDADE" android:background="@drawable/mikael_button"/>
</LinearLayout>
<com.kdt.mcgui.LauncherMenuButton android:id="@+id/install_jar_button" style="@style/LauncherMenuButton.Universal" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="INSTALAR MOD / JAR" android:background="@drawable/mikael_button"/>
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
                'Button mLocalButton = view.findViewById(R.id.button_local_authentication);\\n        Button mElyButton = view.findViewById(R.id.button_ely_authentication);')
    s=s.replace('mLocalButton.setOnClickListener(v ->', 
                'mElyButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), ElyLoginFragment.class, ElyLoginFragment.TAG, null));\\n        mLocalButton.setOnClickListener(v ->')
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
                    account.expiresAt=System.currentTimeMillis()+24L*60L*60L*1000L;
                    account.save();
                    requireActivity().runOnUiThread(() -> {
                        status.setText("Conta Ely.by adicionada.");
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

cat >> "$RES/values/styles.xml" <<'EOF'
<style name="MikaelPreferenceTheme" parent="@style/PreferenceThemeOverlay.v14.Material">
    <item name="preferenceStyle">@style/MikaelPreferenceStyle</item>
    <item name="switchPreferenceStyle">@style/MikaelSwitchPreferenceStyle</item>
    <item name="switchPreferenceCompatStyle">@style/MikaelSwitchPreferenceStyle</item>
    <item name="seekBarPreferenceStyle">@style/MikaelPreferenceStyle</item>
    <item name="preferenceCategoryStyle">@style/MikaelPreferenceCategoryStyle</item>
</style>
<style name="MikaelPreferenceStyle" parent="@style/Preference.Material">
    <item name="android:layout">@layout/mikael_preference</item>
</style>
<style name="MikaelSwitchPreferenceStyle" parent="@style/Preference.SwitchPreference">
    <item name="android:layout">@layout/mikael_preference</item>
</style>
<style name="MikaelPreferenceCategoryStyle" parent="@style/Preference.Category.Material">
    <item name="android:layout">@layout/mikael_preference_category</item>
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
        view.setClipToPadding(false);''')
p.write_text(s)
PY
grep -q '<string name="app_name"' "$RES/values/strings.xml" && sed -i 's#<string name="app_name"[^<]*>[^<]*</string>#<string name="app_name" translatable="false">Mikael Launcher V3</string>#' "$RES/values/strings.xml"

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
  ImageButton profile=v.findViewById(R.id.edit_profile_button); mVersionSpinner=v.findViewById(R.id.mc_version_spinner);\n  v.findViewById(R.id.forge_optifine_button).setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));
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

p=Path("app_pojavlauncher/src/main/res/values/arrays.xml")
s=p.read_text() if p.exists() else '<resources/>'
if "mikael_color_names" not in s:
    s=s.replace('</resources>', '''    <string-array name="mikael_color_names">
        <item>Verde Mikael</item><item>Azul</item><item>Roxo</item><item>Vermelho</item><item>Laranja</item><item>Ciano</item><item>Rosa</item><item>Amarelo</item>
    </string-array>
    <string-array name="mikael_color_values">
        <item>#4ADE80</item><item>#60A5FA</item><item>#A78BFA</item><item>#F87171</item><item>#FB923C</item><item>#22D3EE</item><item>#F472B6</item><item>#FACC15</item>
    </string-array>
</resources>''')
    p.write_text(s)
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
                """setupNotificationRequestPreference();
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
        }""",1)
    marker="    @Override\n    public void onResume()"
    insert="""    @Override
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

"""
    s=s.replace(marker,insert+marker)
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
        if(table!=null && table.versions!=null) for(JMinecraftVersionList.Version x:table.versions) if(x.id!=null && !games.contains(x.id)) games.add(x.id);
        fill(game,games);
        game.setOnItemSelectedListener(new android.widget.AdapterView.OnItemSelectedListener(){
            public void onNothingSelected(android.widget.AdapterView<?> p){}
            public void onItemSelected(android.widget.AdapterView<?> p,View x,int pos,long id){ refreshLoaders(games.get(pos)); }
        });
        new Thread(()->{
            try{
                List<String> f=ForgeUtils.downloadForgeVersions();
                requireActivity().runOnUiThread(()->{forgeAll.clear(); if(f!=null) forgeAll.addAll(f); if(!games.isEmpty()) refreshLoaders(games.get(0));});
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
                            requireActivity().runOnUiThread(()->{
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
    s=s.replace("import android.content.Intent;", "import android.content.Intent;\nimport android.graphics.Color;\nimport android.content.res.ColorStateList;\nimport android.net.Uri;\nimport android.widget.VideoView;")
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
  int[] ids={R.id.custom_control_button,R.id.settings_button,R.id.open_files_button,R.id.share_logs_button,R.id.news_button,R.id.discord_button,R.id.install_jar_button,R.id.forge_optifine_button};
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
EOF

cat > "$RES/layout/fragment_mikael_mod_library.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:orientation="vertical" android:padding="16dp" android:background="#0C0E12">
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:text="BIBLIOTECA DE MODS" android:textColor="#FFFFFF" android:textSize="24sp" android:textStyle="bold"/>
<TextView android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="4dp" android:text="Mods do CurseForge para baixar direto no launcher" android:textColor="#9AA4B2"/>
<LinearLayout android:layout_width="match_parent" android:layout_height="52dp" android:layout_marginTop="14dp" android:orientation="horizontal">
<EditText android:id="@+id/mod_search" android:layout_width="0dp" android:layout_height="match_parent" android:layout_weight="1" android:hint="Pesquisar mod..." android:textColor="#FFFFFF" android:hintTextColor="#7B8491" android:singleLine="true"/>
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
    s=s.replace('Button mInstallJarButton = view.findViewById(R.id.install_jar_button);','Button mInstallJarButton = view.findViewById(R.id.install_jar_button);\n        Button mModLibraryButton = view.findViewById(R.id.mod_library_button);')
    s=s.replace('mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class));','mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class)));\n        mModLibraryButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MikaelModLibraryFragment.class, MikaelModLibraryFragment.TAG, null));')
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
 s=s.replace('Button mInstallJarButton = view.findViewById(R.id.install_jar_button);','Button mInstallJarButton = view.findViewById(R.id.install_jar_button);\n        Button mContentLibraryButton = view.findViewById(R.id.content_library_button);')
 s=s.replace('mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class));','mCustomControlButton.setOnClickListener(v -> startActivity(new Intent(requireContext(), CustomControlsActivity.class)));\n        mContentLibraryButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), MikaelContentLibraryFragment.class, MikaelContentLibraryFragment.TAG, null));')
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
    try{ Field f=p.getClass().getDeclaredField(n); f.setAccessible(true); Object v=f.get(p); if(v!=null&&v.toString().matches("\\d+\\.\\d+(\\.\\d+)?([.-].*)?")) return v.toString(); }catch(Exception ignored){}
    try{ String m="get"+Character.toUpperCase(n.charAt(0))+n.substring(1); Method mm=p.getClass().getMethod(m); Object v=mm.invoke(p); if(v!=null&&v.toString().matches("\\d+\\.\\d+(\\.\\d+)?([.-].*)?")) return v.toString(); }catch(Exception ignored){}
   }
  }catch(Exception ignored){}
  return null;
 }
'''
    s=s.replace(marker,method+marker)
p.write_text(s)
PY

