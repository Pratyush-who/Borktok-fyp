plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.borktok" // ✅ Add this line
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true  // This must be true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.borktok"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    dependencies {
    // Add these exact dependencies:
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")  // Must be version 2.0.2+
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.20")
    
    // Keep your other dependencies
}

}


flutter {
    source = "../.."
}
