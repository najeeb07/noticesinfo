plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}

android {
    ndkVersion = "29.0.14206865"
    namespace = "com.noticesinfo.app"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.noticesinfo.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("../notices.jks")
            storePassword = "N@123456789"
            keyAlias = "key"
            keyPassword = "N@123456789"
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
    dependencies {
        implementation(platform("com.google.firebase:firebase-bom:32.7.4")) // Check for the latest version
        implementation("com.google.firebase:firebase-analytics")
        implementation("com.google.firebase:firebase-auth")
        implementation("com.google.android.gms:play-services-auth:20.7.0") // For Google Sign-In
    }
}

flutter {
    source = "../.."
}
