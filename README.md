# cargo_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Solving Location kotlin not compatible problem

1. Change the Kotlin version to the latest version, in android/settings.gradle file
In my case, it was 1.9.0 :

### android/settings.gradle
id "org.jetbrains.kotlin.android" version "1.9.0" apply false

3. Run --> flutter clean

4. get into the Android folder and run --> ./gradlew cleanBuildCache
5. delete .gradle android dir and the run app
