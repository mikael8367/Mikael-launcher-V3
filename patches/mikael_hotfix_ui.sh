#!/usr/bin/env bash
set -euo pipefail

JAVA="app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java"

# Never ship the upstream Amethyst picture in the Mikael APK.
rm -f "app_pojavlauncher/src/main/assets/amethyst.png"

python3 - <<'PY'
from pathlib import Path

p = Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java")
s = p.read_text()

# The custom Mikael XML can intentionally omit optional buttons.
# The old code called setOnClickListener() directly and crashed with NPE
# when one of those views was absent.
old_decl = '  Button controls=v.findViewById(R.id.custom_control_button),settings=v.findViewById(R.id.settings_button),files=v.findViewById(R.id.open_files_button),logs=v.findViewById(R.id.share_logs_button),news=v.findViewById(R.id.news_button),discord=v.findViewById(R.id.discord_button),install=v.findViewById(R.id.install_jar_button),play=v.findViewById(R.id.play_button);'
new_decl = '  Button controls=v.findViewById(R.id.custom_control_button),settings=v.findViewById(R.id.settings_button),files=v.findViewById(R.id.open_files_button),logs=v.findViewById(R.id.share_logs_button),install=v.findViewById(R.id.install_jar_button),play=v.findViewById(R.id.play_button);'
s = s.replace(old_decl, new_decl)

repls = {
'  controls.setOnClickListener(x->startActivity(new Intent(requireContext(),CustomControlsActivity.class)));':
'  if(controls!=null) controls.setOnClickListener(x->startActivity(new Intent(requireContext(),CustomControlsActivity.class)));',
'  settings.setOnClickListener(x->swapFragment(requireActivity(),LauncherPreferenceFragment.class,LauncherActivity.SETTING_FRAGMENT_TAG,null));':
'  if(settings!=null) settings.setOnClickListener(x->swapFragment(requireActivity(),LauncherPreferenceFragment.class,LauncherActivity.SETTING_FRAGMENT_TAG,null));',
'  logs.setOnClickListener(x->shareLog(requireContext()));':
'  if(logs!=null) logs.setOnClickListener(x->shareLog(requireContext()));',
'  files.setOnClickListener(x->{if(!hasOnlineProfile()){hasNoOnlineProfileDialog(requireActivity());return;}openPath(requireContext(),getCurrentProfileDirectory(),false);});':
'  if(files!=null) files.setOnClickListener(x->openPath(requireContext(),getCurrentProfileDirectory(),false));',
'  install.setOnClickListener(x->runInstaller(false));':
'  if(install!=null) install.setOnClickListener(x->runInstaller(false));',
'  install.setOnLongClickListener(x->{runInstaller(true);return true;});':
'  if(install!=null) install.setOnLongClickListener(x->{runInstaller(true);return true;});',
'  profile.setOnClickListener(x->mVersionSpinner.openProfileEditor(requireActivity()));':
'  if(profile!=null && mVersionSpinner!=null) profile.setOnClickListener(x->mVersionSpinner.openProfileEditor(requireActivity()));',
'  play.setOnClickListener(x->{if(hasMods("sodium")&&!LauncherPreferences.DEFAULT_PREF.getBoolean("sodium_override",false)){new AlertDialog.Builder(requireContext()).setTitle(R.string.sodium_warning_title).setMessage(R.string.sodium_warning_message).setNeutralButton(R.string.delete_sodium,(d,w)->{deleteSodiumMods();ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);}).show();}else ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);});':
'  if(play!=null) play.setOnClickListener(x->{if(hasMods("sodium")&&!LauncherPreferences.DEFAULT_PREF.getBoolean("sodium_override",false)){new AlertDialog.Builder(requireContext()).setTitle(R.string.sodium_warning_title).setMessage(R.string.sodium_warning_message).setNeutralButton(R.string.delete_sodium,(d,w)->{deleteSodiumMods();ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);}).show();}else ExtraCore.setValue(ExtraConstants.LAUNCH_GAME,true);});',
'  news.setOnClickListener(x->openURL(requireActivity(),URL_HOME));':
'',
'  discord.setOnClickListener(x->openURL(requireActivity(),getString(R.string.discord_invite)));':
''
}
for old,new in repls.items():
    s = s.replace(old,new)

# Also remove any remaining standalone references to the deleted News/Community buttons.
s = s.replace(',news=v.findViewById(R.id.news_button)', '')
s = s.replace(',discord=v.findViewById(R.id.discord_button)', '')

p.write_text(s)
PY
