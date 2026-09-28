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
