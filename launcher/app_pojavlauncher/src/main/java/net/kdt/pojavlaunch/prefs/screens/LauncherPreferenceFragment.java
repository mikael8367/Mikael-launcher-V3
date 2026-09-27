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
