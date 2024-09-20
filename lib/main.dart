import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clicker_sdk/flutter_clicker_sdk.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';
import 'dart:math';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PW Clicker Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const App(title: 'PW Clicker Scanner'),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key, required this.title});

  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String _deviceId = '';
  String _button = '';
  bool _isClickerInit = false;
  bool _isRegisterMode = false;
  ClickerScanMode _scanMode = ClickerScanMode.bluetooth;
  String _dongleStatusMessage = '';
  var _registrationKey = 0;
  final Random _random = Random();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  void initiateRegistration() {
    var random = 1;// _random.nextInt(5) + 1;
    FlutterClickerSdk.startClickerRegistration(registrationKey: random);
    print("Started registration with key $random");
    setState(() {
      _registrationKey = random;
    });
  }

  void _listenToClickerScan() async {
    FlutterClickerSdk.clickerScanStream
        .debounceTime(const Duration(milliseconds: 100))
        .listen((event) {
      var clickerData = event;
      _copyStringToClipboard(clickerData.deviceId);
      setState(() {
        _deviceId = clickerData.deviceId;
        _button = clickerData.clickerButtonValue.name;
      });

      // if (_deviceId != '') {
      //
      // } else {
      //   setState(() {
      //     _deviceId = clickerData.deviceId;
      //     _button = clickerData.clickerButtonValue.name;
      //   });
      // }

      print(
          "DeviceID - $_deviceId, clickerButtonValue - ${clickerData.clickerButtonValue.name}");

      if (_isRegisterMode) {
        initiateRegistration();
      } else {
        FlutterClickerSdk.stopClickerRegistration();
        setState(() {
          // stop printing the key value, registration stopped
          _registrationKey = 0;
        });
      }
    }) as Stream<ClickerData>;
  }

  void _copyToClipboard() {
    _copyStringToClipboard(_deviceId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device ID copied to clipboard')),
    );
  }

  void _copyStringToClipboard(value) {
    Clipboard.setData(ClipboardData(text: value));
  }

  void initClickerSdk() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Stop the SDK
    if (_isClickerInit) {
      // Stop scanning
      FlutterClickerSdk.stopClickerScanning();
      // Stop registration if it is in registration mode
      if (_isRegisterMode) {
        FlutterClickerSdk.stopClickerRegistration();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stopped')),
      );
      setState(() {
        _isClickerInit = false;
        _isRegisterMode = false;
        _deviceId = '';
      });
      print("Stopped");
      return;
    }

    print("Widget flutter binding init");

    FlutterClickerSdk.setClickerScanMode(mode: _scanMode);
    var isScannerAvailable =
        await FlutterClickerSdk.isClickerScanningAvailable();
    print("Scanner available $isScannerAvailable");
    if (isScannerAvailable) {
      _dongleStatusMessage = '';
      FlutterClickerSdk.startClickerScanning();

      if(_isRegisterMode) {
        initiateRegistration();
      }

      print("Widget flutter binding init");
      setState(() {
        _isClickerInit = true;
      });

      // Start listen scanning
      _listenToClickerScan();

      print("Started listening");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isRegisterMode
                ? 'Started for registration'
                : 'Scanner Started now you can scan')),
      );
    } else {
      setState(() {
        _dongleStatusMessage = _scanMode == ClickerScanMode.bluetooth
            ? 'Bluetooth is not on or not available'
            : 'Dongle is not connected';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Select Scan Mode:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<ClickerScanMode>(
                  value: ClickerScanMode.bluetooth,
                  groupValue: _scanMode,
                  onChanged: _isClickerInit
                      ? null
                      : (ClickerScanMode? value) {
                          setState(() {
                            _scanMode = value!;
                          });
                        },
                ),
                const Text('Bluetooth'),
                Radio<ClickerScanMode>(
                  value: ClickerScanMode.dongle,
                  groupValue: _scanMode,
                  onChanged: _isClickerInit
                      ? null
                      : (ClickerScanMode? value) {
                          setState(() {
                            _scanMode = value!;
                          });
                        },
                ),
                const Text('Dongle'),
              ],
            ),
            const SizedBox(height: 20),
            if (_scanMode == ClickerScanMode.dongle)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isRegisterMode,
                    onChanged: _isClickerInit
                        ? null
                        : (bool? value) {
                            print("Register mode changed $value");
                            setState(() {
                              _isRegisterMode = value!;
                              print(
                                  "Register mode after changed $_isRegisterMode");
                            });
                          },
                  ),
                  const Text('Register Mode'),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: initClickerSdk,
              child: Text(_isClickerInit ? 'Stop' : 'Start'),
            ),
            Text(_dongleStatusMessage,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Color.fromRGBO(255, 0, 0, 100))),
            const SizedBox(height: 10),
            if (_scanMode == ClickerScanMode.dongle &&
                _registrationKey != 0 &&
                _isClickerInit)
              Text(
                'Press $_registrationKey',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (_isClickerInit)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Text(
                    _isRegisterMode ? 'Registered Device:' : 'Scanned Device:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: _copyToClipboard,
                    child: Text(
                      _deviceId.isEmpty
                          ? 'Waiting for device...'
                          : ("Mac - $_deviceId, Btn pressed - $_button"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: _copyToClipboard,
                    child: const Text('Copy Mac'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
