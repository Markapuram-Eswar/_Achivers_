plugins {
    id 'com.android.application' // Android application module
    id 'kotlin-android' // Kotlin support
    id 'com.google.gms.google-services' // Google Services (e.g., Firebase)
    id 'dagger.hilt.android.plugin' // Hilt for dependency injection (optional)
}

android {
    compileSdk 35 // Target the latest Android SDK (Android 15 as of 2025)

    defaultConfig {
        applicationId "com.example.myapp"
        minSdk 24 // Minimum supported Android version (e.g., Android 7.0)
        targetSdk 35 // Target Android version
        versionCode 1
        versionName "1.0.0"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled true // Enable code shrinking
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release // Optional: Define signing config
        }
        debug {
            minifyEnabled false
            debuggable true
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17' // Ensure Kotlin targets Java 17
    }

    buildFeatures {
        viewBinding true // Enable view binding (optional)
        dataBinding false // Enable data binding if needed
        compose false // Enable Jetpack Compose if used
    }

    namespace 'com.example.myapp' // Define namespace for Android 14+ compatibility
}

dependencies {
    // Core Android libraries
    implementation 'androidx.core:core-ktx:1.13.1'
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.12.0'

    // Kotlin coroutines for asynchronous programming
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1'

    // Lifecycle and ViewModel for modern Android architecture
    implementation 'androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.4'
    implementation 'androidx.lifecycle:lifecycle-livedata-ktx:2.8.4'

    // Firebase dependencies (example, adjust based on needs)
    implementation platform('com.google.firebase:firebase-bom:33.1.2')
    implementation 'com.google.firebase:firebase-analytics-ktx'
    implementation 'com.google.firebase:firebase-crashlytics-ktx'

    // Hilt for dependency injection (optional)
    implementation 'com.google.dagger:hilt-android:2.51.1'
    kapt 'com.google.dagger:hilt-compiler:2.51.1'

    // Testing dependencies
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.2.1'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.6.1'
}