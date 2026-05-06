import java.io.FileInputStream
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun keystoreProperty(name: String): String =
    keystoreProperties.getProperty(name)
        ?: error("Missing required signing property '$name' in ${keystorePropertiesFile.path}")


println("KEY FILE PATH: ${keystorePropertiesFile.absolutePath}")
println("KEY EXISTS: ${keystorePropertiesFile.exists()}")
println("KEY PROPS: $keystoreProperties")

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.IAM.IAM_Ecomm"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.IAM.IAM_Ecomm"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }



    signingConfigs {
        create("release") {
            keyAlias = keystoreProperty("keyAlias")
            keyPassword = keystoreProperty("keyPassword")
            storeFile = file(keystoreProperty("storeFile"))
            storePassword = keystoreProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true       // Optional: shrink code
            isShrinkResources = true     // Optional: remove unused resources
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro") // Optional
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}

println("KEYSTORE FILE EXISTS: ${keystorePropertiesFile.exists()}")
println("KEYSTORE CONTENT: $keystoreProperties")