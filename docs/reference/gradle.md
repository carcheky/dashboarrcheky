# Gradle Config

## Files

- `lunasea/android/build.gradle` — top-level (plugin versions)
- `lunasea/android/settings.gradle` — includes the Flutter module + Fastlane
- `lunasea/android/app/build.gradle` — app module config
- `lunasea/android/gradle.properties` — JVM args, AndroidX flags
- `lunasea/android/gradle/wrapper/gradle-wrapper.properties` — Gradle 8.0

## Important values

From `app/build.gradle`:

```groovy
android {
    namespace = "app.lunasea.lunasea"
    compileSdkVersion 35
    defaultConfig {
        applicationId "app.lunasea.lunasea"
        minSdkVersion 24
        targetSdkVersion 35
    }
    buildTypes {
        debug   { applicationIdSuffix ".debug"; versionNameSuffix "-dev" }
        release { signingConfig signingConfigs.release }
    }
}
```

## Signing release builds

1. Generate a keystore (only once, store it somewhere safe):
   ```bash
   keytool -genkey -v -keystore ~/lunasea-release.keystore \
           -alias lunasea -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Copy `lunasea/android/key.properties.sample` to `key.properties` and fill
   in the values. **Do not commit `key.properties`.**
3. Release builds will then be signed and installable.

## Speeding up Gradle

Edit `lunasea/android/gradle.properties`:

```properties
org.gradle.jvmargs=-Xmx3g           # increase if you have RAM
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configureondemand=true
```

These also apply inside the Docker build (the file is bind-mounted into the
container).
