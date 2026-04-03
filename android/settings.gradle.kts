// settings.gradle.kts — Android root
// DK Parking Engine — Android Version 1

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "DKParkingAndroid"
include(":DKParkingSDK")
include(":DKParkingVerticalSlice")
