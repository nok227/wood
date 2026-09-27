# ✅ OneSignal
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# ✅ flutter_foreground_task
-keep class com.pravera.flutter_foreground_task.** { *; }
-keep class * extends com.pravera.flutter_foreground_task.service.ForegroundService { *; }

# ✅ Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ✅ Flutter
-keep class io.flutter.** { *; }

-dontwarn com.google.android.play.core.**