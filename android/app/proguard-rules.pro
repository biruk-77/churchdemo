# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# OkHttp (used by Dio)
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }

# Keep model classes
-keep class com.example.church.** { *; }

# Prevent stripping of annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Flutter Play Core (deferred components) — suppress R8 missing class errors
# These are referenced by Flutter internals but not used unless you enable deferred components
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Suppress R8 notes about deprecated APIs in third-party libs
-dontnote com.google.android.play.core.**
-dontnote io.flutter.**
