#!/usr/bin/env bash
set -euo pipefail

# Main menu crash protection: every optional button must be null-safe.
python3 - <<'PY'
from pathlib import Path
import re
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s=p.read_text()
s=re.sub(r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\.setOnClickListener\(', lambda m: f"{m.group(1)}if ({m.group(2)} != null) {m.group(2)}.setOnClickListener(", s, flags=re.M)
s=re.sub(r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)\.setOnLongClickListener\(', lambda m: f"{m.group(1)}if ({m.group(2)} != null) {m.group(2)}.setOnLongClickListener(", s, flags=re.M)
p.write_text(s)
PY

# Local/offline login must never require a Microsoft account.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/LocalLoginFragment.java")
s=p.read_text()
s=s.replace("import static net.kdt.pojavlaunch.Tools.hasOnlineProfile;\n\n","")
start='''        // This is overkill but meh
        if (!hasOnlineProfile()){
            Tools.swapFragment(requireActivity(), MainMenuFragment.class, MainMenuFragment.TAG, null);
        }
'''
s=s.replace(start,"")
p.write_text(s)
PY

# Ensure all three account methods are reachable without upstream gating.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/SelectAuthFragment.java")
s=p.read_text()
s=s.replace("import static net.kdt.pojavlaunch.Tools.hasNoOnlineProfileDialog;\n\n","")
if "button_ely_authentication" not in s:
    s=s.replace("Button mLocalButton = view.findViewById(R.id.button_local_authentication);",
                "Button mLocalButton = view.findViewById(R.id.button_local_authentication);\n        Button mElyButton = view.findViewById(R.id.button_ely_authentication);")
if "ElyLoginFragment.class" not in s:
    s=s.replace("mLocalButton.setOnClickListener(v ->",
                "mElyButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), ElyLoginFragment.class, ElyLoginFragment.TAG, null));\n        mLocalButton.setOnClickListener(v ->")
s=s.replace("mLocalButton.setOnClickListener(v -> hasNoOnlineProfileDialog(requireActivity(), () -> Tools.swapFragment(requireActivity(), LocalLoginFragment.class, LocalLoginFragment.TAG, null)));",
            "mLocalButton.setOnClickListener(v -> Tools.swapFragment(requireActivity(), LocalLoginFragment.class, LocalLoginFragment.TAG, null));")
p.write_text(s)
PY

# Refresh the account spinner after Ely.by creates an account.
python3 - <<'PY'
from pathlib import Path
p=Path("app_pojavlauncher/src/main/java/com/kdt/mcgui/mcAccountSpinner.java")
s=p.read_text()
marker="    public MinecraftAccount getSelectedAccount(){"
if "public void reloadAccountsFromFiles()" not in s:
    s=s.replace(marker, "    public void reloadAccountsFromFiles(){\n        reloadAccounts(true, 0);\n    }\n\n"+marker)
p.write_text(s)

p=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/LauncherActivity.java")
s=p.read_text()
marker="    @Override\n    protected void onResume()"
if "public void reloadAccountsFromFiles()" not in s:
    s=s.replace(marker, "    public void reloadAccountsFromFiles(){\n        if(mAccountSpinner != null) mAccountSpinner.reloadAccountsFromFiles();\n    }\n\n"+marker)
p.write_text(s)
PY

# Replace Ely.by login with a lifecycle-safe implementation that validates the
# response, saves the account, selects it and refreshes the account spinner.
cat > "app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/ElyLoginFragment.java" <<'EOF'
package net.kdt.pojavlaunch.fragments;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import net.kdt.pojavlaunch.LauncherActivity;
import net.kdt.pojavlaunch.PojavProfile;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.value.MinecraftAccount;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import org.json.JSONObject;

public class ElyLoginFragment extends Fragment {
    public static final String TAG = "ELY_LOGIN_FRAGMENT";

    public ElyLoginFragment() { super(R.layout.fragment_ely_login); }

    @Override public void onViewCreated(@NonNull View view, @Nullable Bundle state) {
        EditText user = view.findViewById(R.id.ely_username);
        EditText pass = view.findViewById(R.id.ely_password);
        Button login = view.findViewById(R.id.ely_login);
        TextView status = view.findViewById(R.id.ely_status);

        login.setOnClickListener(v -> {
            String username = user.getText().toString().trim();
            String password = pass.getText().toString();
            if (username.isEmpty() || password.isEmpty()) {
                status.setText("Preencha usuário e senha.");
                return;
            }

            login.setEnabled(false);
            status.setText("Autenticando na Ely.by...");

            new Thread(() -> {
                try {
                    String clientToken = UUID.randomUUID().toString();
                    JSONObject req = new JSONObject();
                    req.put("username", username);
                    req.put("password", password);
                    req.put("clientToken", clientToken);
                    req.put("requestUser", true);

                    HttpURLConnection c = (HttpURLConnection)
                            new URL("https://authserver.ely.by/auth/authenticate").openConnection();
                    c.setRequestMethod("POST");
                    c.setConnectTimeout(15000);
                    c.setReadTimeout(20000);
                    c.setDoOutput(true);
                    c.setRequestProperty("Accept", "application/json");
                    c.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

                    try (OutputStream out = c.getOutputStream()) {
                        out.write(req.toString().getBytes(StandardCharsets.UTF_8));
                    }

                    int code = c.getResponseCode();
                    InputStream in = code >= 400 ? c.getErrorStream() : c.getInputStream();
                    if (in == null) throw new Exception("Servidor Ely.by não retornou dados.");

                    ByteArrayOutputStream bos = new ByteArrayOutputStream();
                    byte[] buf = new byte[8192];
                    int len;
                    while ((len = in.read(buf)) != -1) bos.write(buf, 0, len);
                    String body = new String(bos.toByteArray(), StandardCharsets.UTF_8);

                    if (code < 200 || code >= 300) {
                        String msg = "Falha na autenticação Ely.by";
                        try { msg = new JSONObject(body).optString("errorMessage", msg); }
                        catch (Exception ignored) {}
                        throw new Exception(msg);
                    }

                    JSONObject json = new JSONObject(body);
                    JSONObject profile = json.optJSONObject("selectedProfile");
                    if (profile == null)
                        throw new Exception("Ely.by não devolveu um perfil selecionado.");

                    String token = json.optString("accessToken", "");
                    if (token.isEmpty())
                        throw new Exception("Ely.by não devolveu um token de acesso.");

                    String name = profile.optString("name", username);
                    String id = profile.optString("id", "");
                    if (id.isEmpty())
                        throw new Exception("Ely.by não devolveu o UUID do perfil.");

                    MinecraftAccount account = new MinecraftAccount();
                    account.username = name;
                    account.profileId = id;
                    account.accessToken = token;
                    account.clientToken = json.optString("clientToken", clientToken);
                    account.isMicrosoft = false;
                    account.msaRefreshToken = "0";
                    account.expiresAt = 0L;
                    account.save();
                    PojavProfile.setCurrentProfile(requireContext(), name);

                    android.app.Activity activity = getActivity();
                    if (activity == null) return;

                    activity.runOnUiThread(() -> {
                        if (!isAdded()) return;
                        if (activity instanceof LauncherActivity)
                            ((LauncherActivity) activity).reloadAccountsFromFiles();
                        status.setText("Login concluído: " + name);
                        Tools.swapFragment(activity, MainMenuFragment.class,
                                MainMenuFragment.TAG, null);
                    });
                } catch (Exception e) {
                    android.app.Activity activity = getActivity();
                    if (activity != null) activity.runOnUiThread(() -> {
                        if (!isAdded()) return;
                        login.setEnabled(true);
                        String msg = e.getMessage();
                        status.setText("Erro no login: " +
                                (msg == null ? e.getClass().getSimpleName() : msg));
                    });
                }
            }).start();
        });
    }
}
EOF
