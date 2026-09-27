package net.kdt.pojavlaunch.fragments;

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
