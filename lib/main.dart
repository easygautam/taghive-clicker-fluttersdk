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

  @override
  void initState() {
    super.initState();
    // _listenToClickerScan();
  }

  void _listenToClickerScan() {
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

    FlutterClickerSdk.setClickerScanMode(mode: ClickerScanMode.bluetooth);
    var isScannerAvailable =
        await FlutterClickerSdk.isClickerScanningAvailable();
    print("Scanner available $isScannerAvailable");
    if (isScannerAvailable) {
      FlutterClickerSdk.startClickerScanning();

      var currentRegistrationKey = 1;
      FlutterClickerSdk.startClickerRegistration(
          registrationKey: currentRegistrationKey);

      // Press 1 on clicker to register
    }
    print("Widget flutter binding init");
    _listenToClickerScan();
    setState(() {
      _isClickerInit = true;
    });
    print("Started listning");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanner Started now you can scan')),
    );
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
            ElevatedButton(
              onPressed: initClickerSdk,
              child: Text(_isClickerInit ? 'Started' : 'Start'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scanned Device:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            ElevatedButton(
              onPressed: _copyToClipboard,
              child: const Text('Copy Device ID'),
            ),
          ],
        ),
      ),
    );
  }
}
