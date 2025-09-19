plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Google Services plugin
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.citas_medicas_app"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID debe coincidir con el registrado en Firebase
        applicationId = "com.example.citas_medicas_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing con debug keys para que funcione `flutter run --release`
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // BOM de Firebase para mantener versiones consistentes
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // Opcional: Analytics (puedes quitarlo si no lo necesitas)
    implementation("com.google.firebase:firebase-analytics")
}
