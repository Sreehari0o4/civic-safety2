plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_app"
    compileSdk = 35 // Replace flutter.compileSdkVersion with a fixed value

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.my_app"
        minSdk = 21 // Replace flutter.minSdkVersion
        targetSdk = 34 // Replace flutter.targetSdkVersion
        versionCode = 1 // Replace flutter.versionCode
        versionName = "1.0.0" // Replace flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
