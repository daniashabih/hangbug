# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods and line numbers for crash reports
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# flutter_secure_storage / AndroidX Security Crypto
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# SharedPreferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Don't warn about missing references from libraries
-dontwarn io.flutter.**
-dontwarn androidx.**
