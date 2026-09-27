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
  Button modLibrary=v.findViewById(R.id.mod_library_button),contentLibrary=v.findViewById(R.id.content_library_button),forgeOptiFine=v.findViewById(R.id.forge_optifine_button);
  controls.setOnClickListener(x->startActivity(new Intent(requireContext(),CustomControlsActivity.class)));
  settings.setOnClickListener(x->swapFragment(requireActivity(),LauncherPreferenceFragment.class,LauncherActivity.SETTING_FRAGMENT_TAG,null));
  news.setOnClickListener(x->openURL(requireActivity(),URL_HOME));
  discord.setOnClickListener(x->openURL(requireActivity(),getString(R.string.discord_invite)));
  logs.setOnClickListener(x->shareLog(requireContext()));
  files.setOnClickListener(x->{if(!hasOnlineProfile()){hasNoOnlineProfileDialog(requireActivity());return;}openPath(requireContext(),getCurrentProfileDirectory(),false);});
  install.setOnClickListener(x->runInstaller(false));
  install.setOnLongClickListener(x->{runInstaller(true);return true;});
  if(modLibrary!=null) modLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelModLibraryFragment.class,MikaelModLibraryFragment.TAG,null));
  if(contentLibrary!=null) contentLibrary.setOnClickListener(x->swapFragment(requireActivity(),MikaelContentLibraryFragment.class,MikaelContentLibraryFragment.TAG,null));
  if(forgeOptiFine!=null) forgeOptiFine.setOnClickListener(x->swapFragment(requireActivity(),MikaelForgeOptiFineFragment.class,MikaelForgeOptiFineFragment.TAG,null));
  profile.setOnClickListener(x->mVersionSpinner.openProfileEditor(requireActivity()));
  play.setOnClickListener(x->{if(hasMods("sodium")&&!LauncherPreferences.DEFAULT_PREF.getBoolean("sodium_override",false)){new AlertDialog.Builder(requireContext()).setTitle(R.string.sodium_warning_title).setMessage(R.string.sodium_warning_message).setNeutralButton(R.string.delete_sodium,(d,w)->{deleteSodiumMods();ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);}).show();}else ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);});
 }
 private File getCurrentProfileDirectory(){String p=LauncherPreferences.DEFAULT_PREF.getString(LauncherPreferences.PREF_KEY_CURRENT_PROFILE,null);if(!isValidString(p))return new File(DIR_GAME_NEW);LauncherProfiles.load();MinecraftProfile m=LauncherProfiles.mainProfileJson.profiles.get(p);return m==null?new File(DIR_GAME_NEW):getGameDirPath(m);}
 private void runInstaller(boolean custom){if(ProgressKeeper.getTaskCount()==0)installMod(requireActivity(),custom);else Toast.makeText(requireContext(),R.string.tasks_ongoing,Toast.LENGTH_LONG).show();}
 @Override public void onResume(){super.onResume();if(mVersionSpinner!=null)mVersionSpinner.reloadProfiles();}