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
