import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clicker_sdk/flutter_clicker_sdk.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';

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
  ClickerScanMode _scanMode = ClickerScanMode.bluetooth;
  String _dongleStatusMessage = '';

  @override
  void initState() {
    super.initState();
  }

  void _listenToClickerScan() async {
    FlutterClickerSdk.clickerScanStream.listen((event) {
      var clickerData = event;
      _copyStringToClipboard(clickerData.deviceId);
      setState(() {
        _deviceId = clickerData.deviceId;
        _button = clickerData.clickerButtonValue.name;
      });
      print(
          "DeviceID - $_deviceId, clickerButtonValue - ${clickerData.clickerButtonValue.name}");

      FlutterClickerSdk.stopClickerRegistration();
    });
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
    if (_isClickerInit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already started, start scanning')),
      );
      return;
    }
    WidgetsFlutterBinding.ensureInitialized();
    print("Widget flutter binding init");

    FlutterClickerSdk.setClickerScanMode(mode: _scanMode);
    var isScannerAvailable =
        await FlutterClickerSdk.isClickerScanningAvailable();
    print("Scanner available $isScannerAvailable");
    if (isScannerAvailable) {
      _dongleStatusMessage = '';
      FlutterClickerSdk.startClickerScanning();
      var currentRegistrationKey = 1;
      FlutterClickerSdk.startClickerRegistration(
          registrationKey: currentRegistrationKey);

      print("Widget flutter binding init");
      setState(() {
        _isClickerInit = true;
      });
      _listenToClickerScan();
      print("Started listening");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scanner Started now you can scan')),
      );

    } else {
      _dongleStatusMessage = _scanMode == ClickerScanMode.bluetooth
          ? 'Bluetooth is not on or not available'
          : 'Dongle is not connected';
    }
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
            ElevatedButton(
              onPressed: _isClickerInit ? null : initClickerSdk,
              child: Text(_isClickerInit ? 'Started' : 'Start'),
            ),
            Text(_dongleStatusMessage,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 0, 0, 100))),
            const SizedBox(height: 20),
            const Text(
              'Scanned Device:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
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
        ),
      ),
    );
  }
}
