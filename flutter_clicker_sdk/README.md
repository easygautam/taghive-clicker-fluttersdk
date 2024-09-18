# Flutter Clicker SDK Documentation

The FlutterClickerSdk provides a comprehensive toolkit for integrating clicker functionalities into your Flutter applications. It allows for scanning, registering, and managing clicker devices with ease.

## Getting Started
To use the Flutter Clicker SDK in your Flutter project, follow these steps:
1. Extract the flutter_clicker_sdk.zip into a known location in your project.
2. In the pubspec.yaml file of the project where you want to use the library, add a path dependency:
   ```sh
   dependencies:
      flutter_clicker_sdk:
         path: ../path/to/your/library
   ```
4. Import the SDK in your  code:
      ```sh
      import 'package:flutter_clicker_sdk/flutter_clicker_sdk.';
      ```

## Permissions

For ANDROID (add in android/app/src/main/AndroidManifest.xml):
```sh
  <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation" />
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

  <!-- legacy for Android 11 or lower -->
  <uses-permission android:name="android.permission.BLUETOOTH"
      android:maxSdkVersion="30" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"
      android:maxSdkVersion="30" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
      android:maxSdkVersion="30" />
  <!-- legacy for Android 9 or lower -->
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"
      android:maxSdkVersion="28" />
```

For IOS (add in ios/Runner/Info.plist):
```sh
    <key>NSBluetoothAlwaysUsageDescription</key>
	<string>We are using BLE device for quiz </string>
	<key>NSBluetoothPeripheralUsageDescription</key>
	<string>We are using BLE device for quiz </string>
```

For MACOS (add in macos\Runner\DebugProfile.entitlements and macos\Runner\Release.entitlements):
```sh
	<key>com.apple.security.device.bluetooth</key>
    <true/>
    <key>com.apple.security.device.serial</key>
    <true/>
    <key>com.apple.security.device.usb</key>
    <true/>
```
## Function References

- `FlutterClickerSdk.setClickerScanMode(mode)` - to set scan mode. There are 2 scan modes dongle and bluetooth. By default clicker scan mode is bluetooth.
- `FlutterClickerSdk.isClickerScanningAvailable()` - returns a boolean and check if clicker scanning is available for the current scanning mode.
- `FlutterClickerSdk.startClickerScanning()` - to start scanning for clickers
- `FlutterClickerSdk.clickerScanStream` - returns a stream that emits scanned clicker data continuously.
- `FlutterClickerSdk.stopClickerScanning()` - to stop scanning for clickers
- `FlutterClickerSdk.startClickerRegistration(registrationKey)` - In case of dongle scan mode, you can register your clicker with a particular clicker button key.
- `FlutterClickerSdk.stopClickerRegistration()` - In case of dongle scan mode, you can stop clicker registration.
- `FlutterClickerSdk.getClickerScanMode()` - returns the current scan mode.

## Usage

To use the Flutter Clicker SDK in your application, follow these steps:

1. Call the `FlutterClickerSdk.setClickerScanMode(mode)` function to set the scanning mode before you start listening the clicker events. Dongle scan mode is available for desktop platforms only.
2. Call the `FlutterClickerSdk.isClickerScanningAvailable()` function to check if scanning is available for scan mode.
3. Call the `FlutterClickerSdk.startClickerScanning()` function to start scanning for clicker events if scanning is available
4. Use the `FlutterClickerSdk.clickerScanStream` function to start listening to stream of clicker events.
5. Call the `FlutterClickerSdk.stopClickerScanning()` function to stop listening to clicker events.
6. If the clickers are not working or the signal is not being received, call the `FlutterClickerSdk.startClickerRegistration(registrationKey)` function, and after registering clickers you can call the `FlutterClickerSdk.stopClickerRegistration()` function.

## Sample Code

# For Listening Clickers
```sh
import 'package:flutter/material.dart';
import 'package:flutter_clicker_sdk/flutter_clicker_sdk.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  FlutterClickerSdk.setClickerScanMode(mode: ClickerScanMode.bluetooth);

  if(await FlutterClickerSdk.isClickerScanningAvailable()) {
    FlutterClickerSdk.startClickerScanning();

    FlutterClickerSdk.clickerScanStream.listen((event) {
      var clickerData = event;
      var deviceId = clickerData.deviceId;
      var clickerButtonValue = clickerData.clickerButtonValue;
      var clickerBatteryLevel = clickerData.clickerBatteryLevel;
      
    });
  }

  runApp(const MyApp());
}

```
# For Registering Clickers (In Case Signal not showing)

```sh
import 'package:flutter/material.dart';
import 'package:flutter_clicker_sdk/flutter_clicker_sdk.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  FlutterClickerSdk.setClickerScanMode(mode: ClickerScanMode.dongle);

  if(await FlutterClickerSdk.isClickerScanningAvailable()) {
    FlutterClickerSdk.startClickerScanning();

    var currentRegistrationKey = 1;
    FlutterClickerSdk.startClickerRegistration(registrationKey: currentRegistrationKey);
    
    // Press 1 on clicker to register
    
    FlutterClickerSdk.clickerScanStream.listen((event) {
      // Event will emitted when clicker is successfully registered by pressing button 1
      var clickerData = event;
      var deviceId = clickerData.deviceId;
      var clickerButtonValue = clickerData.clickerButtonValue;
      var clickerBatteryLevel = clickerData.clickerBatteryLevel;
      
      //Stop Clicker Registration once regsitered
      FlutterClickerSdk.stopClickerRegistration();
    });
  }

  runApp(const MyApp());
}
```

## License

This project is licensed under the [MIT License](LICENSE).
