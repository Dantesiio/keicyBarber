import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Leer variables desde .env
val keystoreProperties = Properties()
val envFile = File(project.rootDir.parentFile, ".env")
if (envFile.exists()) {
    envFile.readLines().forEach { line: String ->
        if (line.contains("=") && !line.startsWith("#")) {
            val (key, value) = line.split("=", limit = 2)
            keystoreProperties[key.trim()] = value.trim().removeSurrounding("\"", "\"")
        }
    }
}

android {
    namespace = "com.keicybarber.keicybarber"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.keicybarber.keicybarber"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Google Maps API Key desde .env
        val googleMapsApiKey = keystoreProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: "YOUR_GOOGLE_MAPS_API_KEY"
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey
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
