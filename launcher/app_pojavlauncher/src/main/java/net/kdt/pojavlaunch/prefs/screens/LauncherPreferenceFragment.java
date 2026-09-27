package net.kdt.pojavlaunch.prefs.screens;


import android.app.Activity;
import android.content.SharedPreferences;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.preference.Preference;
import androidx.preference.PreferenceFragmentCompat;

import net.kdt.pojavlaunch.LauncherActivity;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;

/**
 * Preference for the main screen, any sub-screen should inherit this class for consistent behavior,
 * overriding only onCreatePreferences
 */
public class LauncherPreferenceFragment extends PreferenceFragmentCompat implements SharedPreferences.OnSharedPreferenceChangeListener {
    private static final int MIKAEL_VIDEO_PICKER = 9401;

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
        Preference mikaelAccent = findPreference("mikael_accent_color");
        if (mikaelAccent != null) {
            mikaelAccent.setSummary("Cor atual: " + LauncherPreferences.DEFAULT_PREF.getString("mikael_accent_color", "#4ADE80"));
            mikaelAccent.setOnPreferenceClickListener(preference -> {
                showMikaelAccentDialog();
                return true;
            });
        }
        wireMikaelAdvancedPreferences();
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
        }
    }

    private void showMikaelAccentDialog() {
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
        base = base.replaceAll("\s*•\s*(ATIVADO|DESATIVADO)$", "");
        pref.setSummary(base + (base.equals("null") ? "" : " • ") + (enabled ? "ATIVADO" : "DESATIVADO"));
    }

    private void setupNotificationRequestPreference() {
        Preference mRequestNotificationPermissionPreference = requirePreference("notification_permission_request");
        Preference mMicrophonePermissionPreference = requirePreference("microphone_permission_request");
        Activity activity = getActivity();
        if(activity instanceof LauncherActivity) {
            LauncherActivity launcherActivity = (LauncherActivity)activity;
            mRequestNotificationPermissionPreference.setVisible(!launcherActivity.checkForNotificationPermission());
            mRequestNotificationPermissionPreference.setOnPreferenceClickListener(preference -> {
                launcherActivity.askForNotificationPermission(()->mRequestNotificationPermissionPreference.setVisible(false));
                return true;
            });
            mMicrophonePermissionPreference.setVisible(!launcherActivity.checkForMicrophonePermission());
            mMicrophonePermissionPreference.setOnPreferenceClickListener(preference -> {
                launcherActivity.askForMicrophonePermission(()->mMicrophonePermissionPreference.setVisible(false));
                return true;
            });
        }else{
            mRequestNotificationPermissionPreference.setVisible(false);
        }
    }

    @Override
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

    @Override
    public void onResume() {
        super.onResume();
        SharedPreferences sharedPreferences = getPreferenceManager().getSharedPreferences();
        if(sharedPreferences != null) sharedPreferences.registerOnSharedPreferenceChangeListener(this);
    }

    @Override
    public void onPause() {
        SharedPreferences sharedPreferences = getPreferenceManager().getSharedPreferences();
        if(sharedPreferences != null) sharedPreferences.unregisterOnSharedPreferenceChangeListener(this);
        super.onPause();
    }

    @Override
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
    }

    protected Preference requirePreference(CharSequence key) {
        Preference preference = findPreference(key);
        if(preference != null) return preference;
        throw new IllegalStateException("Preference "+key+" is null");
    }
    @SuppressWarnings("unchecked")
    protected <T extends Preference> T requirePreference(CharSequence key, Class<T> preferenceClass) {
        Preference preference = requirePreference(key);
        if(preferenceClass.isInstance(preference)) return (T)preference;
        throw new IllegalStateException("Preference "+key+" is not an instance of "+preferenceClass.getSimpleName());
    }
}
