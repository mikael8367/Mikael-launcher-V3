#!/usr/bin/env bash
set -euo pipefail

ROOT="app_pojavlauncher/src/main"
RES="$ROOT/res"
JAVA="$ROOT/java/net/kdt/pojavlaunch/fragments/MainMenuFragment.java"

mkdir -p "$RES/drawable"

cat > "$RES/drawable/mikael_logo.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="112dp"
    android:height="112dp"
    android:viewportWidth="112"
    android:viewportHeight="112">
    <path android:fillColor="#18221A" android:pathData="M8,8 L104,8 L104,104 L8,104 Z"/>
    <path android:fillColor="#5BC45B" android:pathData="M18,18 L94,18 L94,94 L18,94 Z"/>
    <path android:fillColor="#172017" android:pathData="M30,30 L42,30 L42,43 L50,43 L50,30 L62,30 L62,43 L70,43 L70,30 L82,30 L82,82 L70,82 L70,58 L62,58 L62,82 L50,82 L50,58 L42,58 L42,82 L30,82 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M35,88 L77,88 L77,92 L35,92 Z"/>
</vector>
EOF

cat > "$RES/layout/fragment_launcher.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/fragment_menu_main"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/background_app">

    <ScrollView
        android:id="@+id/mikael_scroll"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:fillViewport="true"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toTopOf="@id/mikael_bottom">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:gravity="center_horizontal"
            android:paddingHorizontal="@dimen/_20sdp"
            android:paddingTop="@dimen/_22sdp"
            android:paddingBottom="@dimen/_12sdp">

            <ImageView
                android:id="@+id/mikael_logo"
                android:layout_width="@dimen/_100sdp"
                android:layout_height="@dimen/_100sdp"
                android:src="@drawable/mikael_logo"
                android:contentDescription="Mikael Launcher"/>

            <TextView
                android:id="@+id/mikael_title"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="@dimen/_10sdp"
                android:text="MIKAEL LAUNCHER V3"
                android:textSize="@dimen/_22ssp"
                android:textStyle="bold"
                android:textColor="@android:color/white"/>

            <TextView
                android:id="@+id/mikael_subtitle"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="@dimen/_3sdp"
                android:text="Minecraft Java Edition"
                android:textSize="@dimen/_12ssp"
                android:alpha="0.75"/>

            <TextView
                android:id="@+id/mikael_status"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="@dimen/_18sdp"
                android:padding="@dimen/padding_medium"
                android:gravity="center"
                android:text="Escolha uma versão e toque em JOGAR"
                android:textSize="@dimen/_11ssp"
                android:background="@drawable/background_card"/>

            <com.kdt.mcgui.LauncherMenuButton
                android:id="@+id/custom_control_button"
                style="@style/LauncherMenuButton.Universal"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="@dimen/_12sdp"
                android:text="CONTROLES"
                android:drawableStart="@drawable/ic_menu_custom_controls"/>

        </LinearLayout>
    </ScrollView>

    <LinearLayout
        android:id="@+id/mikael_bottom"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:paddingHorizontal="@dimen/_15sdp"
        android:paddingTop="@dimen/_8sdp"
        android:paddingBottom="@dimen/_12sdp"
        android:background="@color/background_bottom_bar"
        app:layout_constraintBottom_toBottomOf="parent">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal">

            <com.kdt.mcgui.mcVersionSpinner
                android:id="@+id/mc_version_spinner"
                android:layout_width="0dp"
                android:layout_height="@dimen/_52sdp"
                android:layout_weight="1"
                android:background="@android:color/transparent"
                android:drawableEnd="@drawable/spinner_arrow"
                app:drawableEndSize="@dimen/padding_heavy"
                app:drawableStartIntegerScaling="true"
                app:drawableStartSize="@dimen/_36sdp"
                app:drawableEndPadding="@dimen/_1sdp"/>

            <ImageButton
                android:id="@+id/edit_profile_button"
                android:layout_width="@dimen/_52sdp"
                android:layout_height="@dimen/_52sdp"
                android:background="?android:attr/selectableItemBackground"
                android:src="@drawable/ic_edit_profile"
                android:contentDescription="Conta"/>
        </LinearLayout>

        <com.kdt.mcgui.MineButton
            android:id="@+id/play_button"
            android:layout_width="match_parent"
            android:layout_height="@dimen/_58sdp"
            android:layout_marginTop="@dimen/_7sdp"
            android:text="JOGAR"
            android:textAllCaps="true"/>
    </LinearLayout>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$JAVA" <<'EOF'
package net.kdt.pojavlaunch.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.kdt.mcgui.mcVersionSpinner;

import net.kdt.pojavlaunch.CustomControlsActivity;
import net.kdt.pojavlaunch.R;
import net.kdt.pojavlaunch.Tools;
import net.kdt.pojavlaunch.extra.ExtraConstants;
import net.kdt.pojavlaunch.extra.ExtraCore;
import net.kdt.pojavlaunch.prefs.LauncherPreferences;

public class MainMenuFragment extends Fragment {
    public static final String TAG = "MainMenuFragment";

    private mcVersionSpinner mVersionSpinner;

    public MainMenuFragment() {
        super(R.layout.fragment_launcher);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        Button mControlsButton = view.findViewById(R.id.custom_control_button);
        ImageButton mEditProfileButton = view.findViewById(R.id.edit_profile_button);
        Button mPlayButton = view.findViewById(R.id.play_button);
        mVersionSpinner = view.findViewById(R.id.mc_version_spinner);

        mControlsButton.setOnClickListener(v ->
                startActivity(new Intent(requireContext(), CustomControlsActivity.class)));

        mEditProfileButton.setOnClickListener(v ->
                mVersionSpinner.openProfileEditor(requireActivity()));

        mPlayButton.setOnClickListener(v ->
                ExtraCore.setValue(ExtraConstants.LAUNCH_GAME, true));
    }

    @Override
    public void onResume() {
        super.onResume();
        if (mVersionSpinner != null) mVersionSpinner.reloadProfiles();
    }
}
EOF

echo "Mikael GUI applied."
