import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val pilotSigning = Properties()
val pilotSigningFile = rootProject.file("key.properties")
if (pilotSigningFile.exists()) pilotSigningFile.inputStream().use { pilotSigning.load(it) }
val pilotApplicationId = providers.gradleProperty("CENTERLY_APPLICATION_ID").orElse("com.example.centrally").get()
gradle.taskGraph.whenReady {
    if (allTasks.any { it.name.contains("Release") }) {
        check(pilotApplicationId != "com.example.centrally") { "Set CENTERLY_APPLICATION_ID before a release build" }
        check(pilotSigningFile.exists() && listOf("storeFile", "storePassword", "keyAlias", "keyPassword").all { !pilotSigning.getProperty(it).isNullOrBlank() }) {
            "Release signing requires the private android/key.properties file"
        }
    }
}

android {
    namespace = "com.example.centrally"
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
        applicationId = pilotApplicationId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (pilotSigningFile.exists()) {
            create("pilot") {
                storeFile = rootProject.file(pilotSigning.getProperty("storeFile"))
                storePassword = pilotSigning.getProperty("storePassword")
                keyAlias = pilotSigning.getProperty("keyAlias")
                keyPassword = pilotSigning.getProperty("keyPassword")
            }
        }
    }
    buildTypes {
        release {
            if (pilotSigningFile.exists()) signingConfig = signingConfigs.getByName("pilot")
        }
    }
}

flutter {
    source = "../.."
}
