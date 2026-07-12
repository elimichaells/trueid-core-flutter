plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.trueid.core.flutter"
version = "1.0.0"

android {
    namespace = "com.trueid.core.flutter"
    compileSdk = 35

    defaultConfig {
        minSdk = 24
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = "17" }
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://app.trueid.info/sdk/android") }
}

dependencies {
    val localCore = findProject(":trueid-core")
    if (localCore != null) {
        add("api", localCore)
    } else {
        add("api", "com.trueid.sdk:trueid-core:1.0.0")
    }
}
