import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val pilotSigning = Properties()
val pilotSigningFile = rootProject.file("key.properties")
if (pilotSigningFile.exists()) pilotSigningFile.inputStream().use { pilotSigning.load(it) }
val pilotApplicationId = providers.gradleProperty("CENTERLY_APPLICATION_ID").orElse("com.centerly.teacher").get()
gradle.taskGraph.whenReady {
    if (allTasks.any { it.project.path == ":app" && (it.name.contains("ProdRelease") || it.name.contains("DevRelease")) }) {
        check(pilotApplicationId == "com.centerly.teacher") { "Release application ID must match the owner-approved com.centerly.teacher" }
        check(allTasks.none { it.project.path == ":app" && it.name.contains("DevRelease") }) { "Use prod for distribution; dev is for debug/profile testing" }
        val defines = (project.findProperty("dart-defines") as? String).orEmpty().split(",")
            .filter { it.isNotBlank() }.map { String(Base64.getDecoder().decode(it)) }
            .associate { it.substringBefore("=") to it.substringAfter("=", "") }
        check(defines["APP_ENV"] == "production" && defines["CENTERLY_UI_PREVIEW"] == "false") {
            "Release requires explicit production configuration and preview=false"
        }
        check(defines["SUPABASE_URL"] == "https://ohhwccwwwxfmwpfypfyf.supabase.co") { "Release backend must be centerly-prod" }
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

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Centerly Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Centerly")
        }
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

dependencies {
    testImplementation("junit:junit:4.13.2")
}
