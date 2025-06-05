// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google() // Google's Maven repository for Android-specific plugins
        mavenCentral() // Central Maven repository for general dependencies
    }
    dependencies {
        // Android Gradle plugin
        classpath("com.android.tools.build:gradle:8.5.2")
        // Google Services plugin for Firebase, Google Sign-In, etc.
        classpath("com.google.gms:google-services:4.4.2")
        // Kotlin Gradle plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.20")
        // Hilt for dependency injection
        classpath("com.google.dagger:hilt-android-gradle-plugin:2.51.1")
    }
}

// Define repositories for all projects (root and submodules)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define a clean task to remove build artifacts
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

// Configure Gradle Wrapper for consistent builds
tasks.named<Wrapper>("wrapper") {
    gradleVersion = "8.7"
    distributionType = Wrapper.DistributionType.BIN
    distributionUrl = "https://services.gradle.org/distributions/gradle-8.7-bin.zip"
}