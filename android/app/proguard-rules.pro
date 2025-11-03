## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## TensorFlow Lite - Keep all TFLite classes
-keep class org.tensorflow.** { *; }
-keep interface org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# TFLite Flutter Plugin
-keep class tflite_flutter.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keepclassmembers class * {
    @org.tensorflow.lite.* <methods>;
}

# Prevent stripping of native TFLite libraries
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class org.tensorflow.lite.DataType { *; }
-keep class org.tensorflow.lite.Interpreter { *; }
-keep class org.tensorflow.lite.InterpreterApi { *; }
-keep class org.tensorflow.lite.InterpreterApi$Options { *; }

## Google Play Core
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

## Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep generic signature of classes (for reflection)
-keepattributes Signature
-keepattributes *Annotation*

