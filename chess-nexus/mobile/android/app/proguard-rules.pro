# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# SQLite & Drift
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# Audio & Speech
-keep class com.ryanheise.audioservice.** { *; }
-keep class cs.min2df.speech_to_text.** { *; }

# Keep model classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

