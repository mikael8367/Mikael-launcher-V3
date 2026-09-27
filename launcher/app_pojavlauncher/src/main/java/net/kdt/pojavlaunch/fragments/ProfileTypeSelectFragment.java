package net.kdt.pojavlaunch.fragments;


import android.os.Bundle;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import net.kdt.pojavlaunch.PojavProfile;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;

public class ProfileTypeSelectFragment extends Fragment {
    public static final String TAG = "ProfileTypeSelectFragment";
    public ProfileTypeSelectFragment() {
        super(R.layout.fragment_profile_type);
    }
    public ProfileTypeSelectFragment(int layout) {
        super(layout);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        styleMikaelProfileButtons(view);
        view.findViewById(R.id.vanilla_profile).setOnClickListener(v -> Tools.swapFragment(requireActivity(), ProfileEditorFragment.class,
                ProfileEditorFragment.TAG, new Bundle(1)));

        // NOTE: Special care needed! If you wll decide to add these to the back stack, please read
        // the comment in FabricInstallFragment.onDownloadFinished() and amend the code
        // in FabricInstallFragment.onDownloadFinished() and ModVersionListFragment.onDownloadFinished()
        view.findViewById(R.id.optifine_profile).setOnClickListener(v ->
                tryInstall(OptiFineInstallFragment.class, OptiFineInstallFragment.TAG));
        view.findViewById(R.id.modded_profile_fabric).setOnClickListener((v)->
                tryInstall(FabricInstallFragment.class, FabricInstallFragment.TAG));
        view.findViewById(R.id.modded_profile_forge).setOnClickListener((v)->
                tryInstall(ForgeInstallFragment.class, ForgeInstallFragment.TAG));
        view.findViewById(R.id.modded_profile_forge_optifine).setOnClickListener(v ->
                Tools.swapFragment(requireActivity(), MikaelForgeOptiFineFragment.class,
                        MikaelForgeOptiFineFragment.TAG, null));
        view.findViewById(R.id.modded_profile_neoforge).setOnClickListener((v)->
                tryInstall(NeoForgeInstallFragment.class, NeoForgeInstallFragment.TAG));
        view.findViewById(R.id.modded_profile_modpack).setOnClickListener((v)->
                tryInstall(ModpackCreateFragment.class, ModpackCreateFragment.TAG));
        view.findViewById(R.id.modded_profile_lwjgl3ify).setOnClickListener((v)->
                tryInstall(LWJGL3ifyInstallFragment.class, LWJGL3ifyInstallFragment.TAG));
        view.findViewById(R.id.modded_profile_quilt).setOnClickListener((v)->
                tryInstall(QuiltInstallFragment.class, QuiltInstallFragment.TAG));
        view.findViewById(R.id.modded_profile_bta).setOnClickListener((v)->
                tryInstall(BTAInstallFragment.class, BTAInstallFragment.TAG));
    }

    private void styleMikaelProfileButtons(View view) {
        int[] ids = {
                R.id.vanilla_profile, R.id.optifine_profile,
                R.id.modded_profile_fabric, R.id.modded_profile_quilt,
                R.id.modded_profile_forge, R.id.modded_profile_forge_optifine,
                R.id.modded_profile_neoforge,
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

    private void tryInstall(Class<? extends Fragment> fragmentClass, String tag){
        // Installing/creating a local game profile does not require a Microsoft account.
        Tools.swapFragment(requireActivity(), fragmentClass, tag, null);
    }
}
