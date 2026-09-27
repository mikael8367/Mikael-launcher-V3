#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path

layout = Path("app_pojavlauncher/src/main/res/layout/fragment_launcher.xml")
s = layout.read_text()
needle = '''<androidx.constraintlayout.widget.ConstraintLayout
\t\t\tandroid:layout_width="match_parent"
\t\t\tandroid:layout_height="wrap_content">'''
insert = '''<androidx.constraintlayout.widget.ConstraintLayout
\t\t\tandroid:layout_width="match_parent"
\t\t\tandroid:layout_height="wrap_content">

            <TextView
                android:id="@+id/mikael_brand_title"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginHorizontal="@dimen/_18sdp"
                android:layout_marginTop="@dimen/_18sdp"
                android:text="MIKAEL LAUNCHER"
                android:textSize="@dimen/_24ssp"
                android:textStyle="bold"
                android:gravity="center"
                android:textColor="@android:color/white"
                app:layout_constraintTop_toTopOf="parent"/>

            <TextView
                android:id="@+id/mikael_brand_subtitle"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginHorizontal="@dimen/_18sdp"
                android:layout_marginTop="@dimen/_2sdp"
                android:text="Minecraft Java Edition • Android"
                android:textSize="@dimen/_11ssp"
                android:gravity="center"
                android:alpha="0.78"
                app:layout_constraintTop_toBottomOf="@id/mikael_brand_title"/>

            <TextView
                android:id="@+id/mikael_status"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginHorizontal="@dimen/_18sdp"
                android:layout_marginTop="@dimen/_12sdp"
                android:padding="@dimen/padding_medium"
                android:text="Selecione uma versão e toque em JOGAR"
                android:textSize="@dimen/_11ssp"
                android:gravity="center"
                android:background="@drawable/background_card"
                app:layout_constraintTop_toBottomOf="@id/mikael_brand_subtitle"/>

            <Space
                android:id="@+id/mikael_header_space"
                android:layout_width="match_parent"
                android:layout_height="@dimen/_12sdp"
                app:layout_constraintTop_toBottomOf="@id/mikael_status"/>'''
if needle not in s:
    raise SystemExit("launcher layout anchor not found")
s=s.replace(needle, insert, 1)
s=s.replace('app:layout_constraintTop_toBottomOf="@id/news_button"', 'app:layout_constraintTop_toBottomOf="@id/mikael_header_space"', 1)
layout.write_text(s)

auth = Path("app_pojavlauncher/src/main/res/layout/fragment_select_auth_method.xml")
s=auth.read_text()
s=s.replace('android:layout_height="@dimen/_200sdp"', 'android:layout_height="@dimen/_250sdp"', 1)
s=s.replace('android:text="Microsoft Account"', 'android:text="Entrar com Microsoft"', 1)
s=s.replace('android:text="Local account"', 'android:text="Modo Offline"', 1)
needle='''    </com.kdt.mcgui.MineButton>

</androidx.constraintlayout.widget.ConstraintLayout>'''
insert='''    </com.kdt.mcgui.MineButton>

    <com.kdt.mcgui.MineButton
        android:id="@+id/button_elyby_authentication"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Entrar com Ely.by"
        android:textSize="@dimen/_12ssp"
        android:layout_marginHorizontal="@dimen/_25sdp"
        android:layout_marginTop="@dimen/_20sdp"
        app:layout_constraintTop_toBottomOf="@id/button_local_authentication"
        app:layout_constraintStart_toStartOf="@id/login_menu"
        app:layout_constraintEnd_toEndOf="@id/login_menu"/>

</androidx.constraintlayout.widget.ConstraintLayout>'''
if needle not in s:
    raise SystemExit("auth layout anchor not found")
s=s.replace(needle, insert, 1)
auth.write_text(s)

java=Path("app_pojavlauncher/src/main/java/net/kdt/pojavlaunch/fragments/SelectAuthFragment.java")
s=java.read_text()
s=s.replace('import android.widget.Button;', 'import android.widget.Button;\nimport android.content.Intent;\nimport android.net.Uri;')
s=s.replace('''        Button mLocalButton = view.findViewById(R.id.button_local_authentication);''','''        Button mLocalButton = view.findViewById(R.id.button_local_authentication);
        Button mElyButton = view.findViewById(R.id.button_elyby_authentication);''')
s=s.replace('''        mLocalButton.setOnClickListener(v -> hasNoOnlineProfileDialog(requireActivity(), () -> Tools.swapFragment(requireActivity(), LocalLoginFragment.class, LocalLoginFragment.TAG, null)));''','''        mLocalButton.setOnClickListener(v -> hasNoOnlineProfileDialog(requireActivity(), () -> Tools.swapFragment(requireActivity(), LocalLoginFragment.class, LocalLoginFragment.TAG, null)));
        mElyButton.setOnClickListener(v -> {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://account.ely.by/"));
            startActivity(intent);
        });''')
java.write_text(s)
PY
