plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.mobile"
    compileSdk = flutter.compileSdkVersion

    // Pinned rather than taking flutter.ndkVersion (26.3.11579264), whose
    // install in the local SDK is an empty shell — the download failed and left
    // a folder with no source.properties, which Gradle reports as
    // "[CXX1101] NDK ... did not have a source.properties file".
    // 27.0.12077973 is present and complete. Reinstalling 26.3 through the SDK
    // Manager would also work, at which point this line can be reverted.
    ndkVersion = "27.0.12077973"

    compileOptions {
        // flutter_local_notifications schedules alarms using java.time, which
        // only exists from Android 8. Desugaring back-ports it so reminders
        // work on older phones; without it the build fails at
        // :app:checkDebugAarMetadata.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.qolguard.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Supplies the back-ported java.time classes that desugaring needs.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
