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
