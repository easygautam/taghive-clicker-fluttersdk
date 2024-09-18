
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_clicker_sdk/src/clicker_data.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class DongleUtil {

  SerialPort? blePort;
  String? blePortName;
  SerialPortReader? blePortReader;

  late StreamController<ClickerData> portObserver = StreamController.broadcast();
  int? lastRegistrationKey;

  var repeatDeviceIds = HashSet();

  bool isPortAvailable() {
    try {
      var portsList = SerialPort.availablePorts;


      if (portsList.isNotEmpty) {
        if (Platform.isWindows) {
          var portName = portsList.first;

          for (var name in portsList) {
            var port = SerialPort(name);
            if (port.description
                ?.contains("USB Serial Device (${port.name})") ==
                true) {
              portName = name;
            }
          }

          if (blePort == null) {
            blePortName = portName;
            blePort = SerialPort(blePortName!);
          } else if (blePortName != portName) {
            resetPort();

            blePortName = portName;
            blePort = SerialPort(blePortName!);
          }
        } else if (Platform.isMacOS) {
          for (var portName in portsList) {
            try {
              var port = SerialPort(portName);
              if (port.vendorId == 6421 &&
                  (port.productId == 49162 || port.productId == 21018)) {
                if (blePort != null && blePortName != portName) {
                  //resetPort();
                }
                blePortName = portName;
                blePort = port;
                return true;
              }
            } catch (e) {
              print(e);
            }
          }
          return false;
        }
      }
      return portsList.isNotEmpty;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void startPortScanning({bool isRegister = false, int? registrationKey}) {
    try {
      if (blePortReader == null || blePort?.isOpen == false) {
        var serialPortConfig = SerialPortConfig()
          ..baudRate = 115200
          ..bits = 8
          ..parity = SerialPortParity.none
          ..rts = SerialPortRts.flowControl
          ..cts = SerialPortCts.flowControl
          ..dsr = SerialPortDsr.flowControl
          ..dtr = SerialPortDtr.flowControl
          ..setFlowControl(SerialPortFlowControl.rtsCts);

        if (blePort?.isOpen == false) blePort?.openReadWrite();

        blePort?.config = serialPortConfig;

        if (blePort!.isOpen) {
          if (isRegister) {
            startRegistrationPort(registrationKey: registrationKey);
          }
          readPort();
        } else {
        }
      } else {
        if (blePort!.isOpen) {
          if (isRegister) {
            startRegistrationPort(registrationKey: registrationKey);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void startScanning({bool isRegister = false, int? registrationKey}){
    if(isPortAvailable()){
      startPortScanning(isRegister: isRegister,registrationKey: registrationKey);
    }
  }

  void startRegistrationPort({int? registrationKey}) {
    try {
      if (registrationKey != null && blePort?.isOpen == true) {
        var startRegisterBytes = [
          2,
          7,
          1,
          registrationKey,
          16,
          1,
          registrationKey,
          30,
          3,
          13
        ];
        lastRegistrationKey = registrationKey;
        var bytes = blePort?.write(Uint8List.fromList(startRegisterBytes));
      }
    } catch (e) {
      print(e);
    }
  }

  void readPort() {
    try {
      blePortReader = SerialPortReader(blePort!, timeout: 3000);
      blePortReader?.stream.listen((data) {
        //print("$data ${data.length}");

        /*if(data.length != 15){
          return;
        }*/
        var addressTokens = [];
        for (int index = 7; index < 13; index++) {
          var token = data[index].toRadixString(16);
          addressTokens.add(token.length == 2
              ? token.toUpperCase()
              : '0$token'.toUpperCase());
        }

        var deviceId = addressTokens.reversed.join(':');
        var clickerButtonValue = getClickerButton(data[5]);

        if(clickerButtonValue!=null){
          var clickerVoltage = data[6];
          var batteryLevel = BatteryLevel.batteryHigh;
          if (clickerVoltage > 26 || clickerVoltage == 0) {
            batteryLevel = BatteryLevel.batteryHigh;
          } else if (clickerVoltage > 24) {
            batteryLevel = BatteryLevel.batteryMedium;
          } else {
            batteryLevel = BatteryLevel.batteryLow;
          }

          if(lastRegistrationKey == null || !repeatDeviceIds.contains(deviceId)){
            portObserver.add(ClickerData(
                deviceId: deviceId,
                clickerButtonValue: clickerButtonValue,
                clickerBatteryLevel: batteryLevel));
          }
          if(lastRegistrationKey != null) addRepeatDeviceIds(deviceId);

        }

      });
    } catch (e) {
      print(e);
    }
  }

  void finishRegistrationPort() {
    try {
      if (blePort?.isOpen == true) {
        var finishRegisterBytes = [
          2,
          7,
          0,
          0,
          16,
          16,
          0,
          25,
          3,
          13
        ];
        lastRegistrationKey = null;
        var bytes = blePort?.write(Uint8List.fromList(finishRegisterBytes));
      }
    } catch (e) {
      print(e);
    }
  }

  void addRepeatDeviceIds(String deviceId) async{

    try{
      repeatDeviceIds.add(deviceId);
      await Future.delayed(const Duration(seconds: 1));
      repeatDeviceIds.remove(deviceId);
    }catch(e){
      print(e);
    }
  }

  ClickerButtonValue? getClickerButton(int value) {
    switch (value) {
      case 1:
        return ClickerButtonValue.button1;
      case 2:
        return ClickerButtonValue.button2;
      case 3:
        return ClickerButtonValue.button3;
      case 4:
        return ClickerButtonValue.button4;
      case 5:
        return ClickerButtonValue.button5;
      case 6:
        return ClickerButtonValue.button6;
      case 7:
        return ClickerButtonValue.button7;
      case 8:
        return ClickerButtonValue.button8;
      default:
        return null;
    }
  }

  void resetPort() {
    blePortReader?.close();
    blePort?.dispose();
    blePort?.close();

    blePort = null;
    blePortReader = null;
  }

}