# Build and Deployment Instructions

## Building the Viam Pixel 4a Sensors App

### Prerequisites

1. **Flutter SDK** (version 3.10.0 or higher)
   ```bash
   # Install Flutter if not already installed
   # Follow instructions at https://flutter.dev/docs/get-started/install
   flutter --version
   ```

2. **Android SDK** (API level 34 recommended)
   ```bash
   # Verify Android setup
   flutter doctor --android-licenses
   ```

3. **Development Environment**
   - Android Studio or VS Code with Flutter extensions
   - Java Development Kit (JDK) 8 or higher
   - Physical Google Pixel 4a device or emulator

### Build Process

#### 1. Clone and Setup

```bash
# Clone the repository (replace with actual URL)
git clone <repository-url>
cd viam_pixel4a_sensors

# Get Flutter dependencies
flutter pub get

# Verify all dependencies are resolved
flutter doctor
```

#### 2. Development Build

For testing and development:

```bash
# Run on connected device
flutter run

# Or build APK for manual installation
flutter build apk --debug
```

#### 3. Production Build

For release deployment:

```bash
# Build release APK
flutter build apk --release

# Build app bundle (recommended for Play Store)
flutter build appbundle --release
```

#### 4. Signing Configuration

For production, you'll need to sign the APK:

1. **Generate a signing key** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure signing in `android/key.properties`**:
   ```properties
   storePassword=<password from previous step>
   keyPassword=<password from previous step>
   keyAlias=upload
   storeFile=<location of the key store file, e.g. /Users/<user>/upload-keystore.jks>
   ```

3. **Update `android/app/build.gradle`** to include signing configuration (already included in the template).

### Testing

#### Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Generate test coverage report
flutter test --coverage
```

#### Integration Tests

```bash
# Run integration tests (requires device/emulator)
flutter test integration_test/
```

#### Manual Testing Checklist

1. **Permission Testing**
   - [ ] All permissions requested on first launch
   - [ ] Permissions can be granted/denied
   - [ ] App handles permission denial gracefully

2. **Sensor Testing**
   - [ ] Accelerometer data displays correctly
   - [ ] Gyroscope data displays correctly
   - [ ] Magnetometer data displays correctly
   - [ ] Barometer data displays correctly
   - [ ] Location data displays correctly
   - [ ] Battery status displays correctly

3. **Audio Testing**
   - [ ] Microphone recording starts/stops correctly
   - [ ] Recording duration updates properly
   - [ ] Audio playback works
   - [ ] Speaker test produces sound
   - [ ] Volume control functions

4. **Camera Testing**
   - [ ] Camera preview displays
   - [ ] Photo capture works
   - [ ] Video recording works
   - [ ] Camera switching works
   - [ ] Flash control works
   - [ ] Focus and exposure adjustment works

5. **Viam Integration Testing**
   - [ ] Connection dialog opens and closes properly
   - [ ] Valid credentials connect successfully
   - [ ] Invalid credentials show appropriate error
   - [ ] Auto-reconnect functionality works
   - [ ] Data streaming when connected
   - [ ] Command execution works

### Deployment

#### Google Play Store

1. **Prepare Release Build**:
   ```bash
   flutter build appbundle --release
   ```

2. **Upload to Play Console**:
   - Upload the `build/app/outputs/bundle/release/app-release.aab` file
   - Complete store listing and screenshots
   - Set up content rating and pricing
   - Submit for review

#### Direct APK Distribution

1. **Build Signed APK**:
   ```bash
   flutter build apk --release
   ```

2. **Distribute**:
   - Share `build/app/outputs/flutter-apk/app-release.apk`
   - Enable "Unknown Sources" on target devices
   - Install APK manually

### Troubleshooting

#### Common Build Issues

**"Flutter SDK not found"**
```bash
export FLUTTER_ROOT=/path/to/flutter
export PATH="$FLUTTER_ROOT/bin:$PATH"
```

**"Android license not accepted"**
```bash
flutter doctor --android-licenses
```

**"Gradle build failed"**
```bash
# Clean build cache
flutter clean
flutter pub get

# Try building with verbose output
flutter build apk --verbose --release
```

**"MultiDex errors"**
- Ensure `multiDexEnabled true` is in `android/app/build.gradle`
- Check that minSdkVersion is 23 or higher

#### Runtime Issues

**Permission Denials**
- Check AndroidManifest.xml for all required permissions
- Verify runtime permission requests in PermissionService

**Camera Not Working**
- Ensure camera permissions are granted
- Check if another app is using the camera
- Try restarting the app

**Viam Connection Issues**
- Verify network connectivity
- Check API credentials in Viam dashboard
- Ensure robot address is reachable

### Version Management

#### Semantic Versioning

Use semantic versioning for releases:
- **Major**: Breaking changes
- **Minor**: New features
- **Patch**: Bug fixes

#### Release Process

1. Update version in `pubspec.yaml`
2. Update build number in `android/app/build.gradle`
3. Run full test suite
4. Build release APK/AAB
5. Create git tag
6. Deploy to distribution channel

#### Changelog Maintenance

Keep `CHANGELOG.md` updated with:
- Added features
- Fixed issues
- Breaking changes
- Known limitations

### Performance Optimization

#### Build Optimization

```bash
# Enable tree shaking
flutter build apk --release --tree-shake-icons

# Optimize for size
flutter build apk --release --shrink
```

#### Runtime Optimization

- Use `const` constructors where possible
- Implement proper dispose patterns
- Optimize image sizes and formats
- Use lazy loading for expensive operations

### Security Considerations

#### API Keys

- Never commit API keys to version control
- Use environment variables or secure storage
- Rotate keys regularly

#### Data Protection

- Encrypt sensitive data at rest
- Use HTTPS for all network communications
- Implement proper authentication for Viam connection

#### App Signing

- Secure your signing keys
- Use different keys for debug and release
- Consider using Google Play App Signing

### Continuous Integration

#### GitHub Actions Example

```yaml
name: Build and Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter build apk --release
```

This ensures consistent builds and automated testing.