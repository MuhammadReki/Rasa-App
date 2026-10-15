# ===================
# Flutter
# ===================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# ===================
# Flutter Play Store Deferred Components (FIX R8 ERROR)
# ===================
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# ===================
# Firebase
# ===================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ===================
# Supabase
# ===================
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# ===================
# Gson (Firebase pake ini)
# ===================
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ===================
# Kotlin
# ===================
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# ===================
# Flutter Local Notifications
# ===================
-keep class com.dexterous.** { *; }

# ===================
# General
# ===================
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ===================
# Suppress warning (biar build gak gagal)
# ===================
-dontwarn **
-ignorewarnings