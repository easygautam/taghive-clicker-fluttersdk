
import 'dart:async';
import 'dart:io';

import 'package:flutter_clicker_sdk/src/bluetooth/bluetooth_scan_result.dart';
import 'package:flutter_clicker_sdk/src/bluetooth/quick_blue.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';

class BluetoothUtil{

  late StreamController<ClickerData> bleObserver = StreamController.broadcast();
  StreamSubscription<BlueScanResult>? bleScanResult;

  Future<bool> isAvailable() async{
    return await QuickBlue.isBluetoothAvailable();
  }

  void startScanning() {
    QuickBlue.startScan();

    bleScanResult = QuickBlue.scanResultStream.listen((event) {
      if (checkBleFilter(event)) {
        List<int> manufactData = event.manufacturerData.toList();
        BatteryLevel batteryLevel = getBatteryLevel(manufactData);
        String tempId =
        manufactData
            .toList()
            .reversed
            .toList()
            .getRange(1, 7)
            .join(":");
        List tempDeviceId = [];
        tempId.split(":").forEach((element) {
          String hex = int.parse(element).toRadixString(16).toUpperCase();
          tempDeviceId.add(hex);
        });
        String deviceId = tempDeviceId.join(":");

        var clickerButtonValue = getClickerButton(manufactData[13]);

        bleObserver.add(
            ClickerData(
                deviceId: deviceId,
                clickerButtonValue: clickerButtonValue,
                clickerBatteryLevel: batteryLevel
            )
        );
      }
    });

  }

  void stopScanning() {
    if(bleScanResult!=null){
      bleScanResult?.cancel();
      bleScanResult = null;
    }
    QuickBlue.stopScan();
  }

  bool checkBleFilter(BlueScanResult result) {
    const String bleFilter = "TAGHIVE_WCS_T";

    if (Platform.isMacOS || Platform.isAndroid || Platform.isIOS) {
      return result.name.contains(bleFilter);
    } else {
      try {
        final List<int> baseSignatureHex = [54, 48, 2, 15];

        List<String> bleFilterValArr = result.manufacturerDataHead
            .getRange(0, 4)
            .map((e) => e.toRadixString(16))
            .toList();
        String scannedBleFilterVal = bleFilterValArr.join("");

        List<int> manufactData = result.manufacturerData.toList();

        String tempId =
        manufactData
            .toList()
            .reversed
            .toList()
            .getRange(1, 7)
            .join(":");
        List tempDeviceId = [];
        tempId.split(":").forEach((element) {
          String hex = int.parse(element).toRadixString(16).toUpperCase();
          tempDeviceId.add(hex);
        });
        String deviceId = tempDeviceId.join(":");

        var nameDeviceId = result.name.substring(
            result.name.contains(" ") ? result.name.indexOf(" ") + 1 : 0,
            result.name.length);

        //print("Clicker ${deviceId.toLowerCase()} $nameDeviceId");

        return nameDeviceId == deviceId.toLowerCase() ||
            scannedBleFilterVal == baseSignatureHex.join("");
      } catch (e) {
        return false;
      }
    }
  }

  BatteryLevel getBatteryLevel(List<int> data) {
    List<int> newBatteryDataList =
    data
        .getRange(15, 17)
        .toList()
        .reversed
        .toList();
    List tempBatteryData = [];
    newBatteryDataList.forEach((element) {
      var data = int.parse(element.toString()).toRadixString(16).toString();
      tempBatteryData.add(data);
    });
    var joinData = tempBatteryData.join("").toUpperCase();
    var data_1 = int.parse(joinData, radix: 16);

    double highPoint = 2.9;
    double lowPoint = 2.7;

    double currentBatteryVoltage = data_1 / 1000;

    if (currentBatteryVoltage >= highPoint) {
      return BatteryLevel.batteryHigh;
    } else if (currentBatteryVoltage >= lowPoint) {
      return BatteryLevel.batteryMedium;
    } else {
      return BatteryLevel.batteryLow;
    }
  }

  ClickerButtonValue getClickerButton(int value) {
    switch (value) {
      case 1 :
        return ClickerButtonValue.button1;
      case 2 :
        return ClickerButtonValue.button2;
      case 3 :
        return ClickerButtonValue.button3;
      case 4 :
        return ClickerButtonValue.button4;
      case 5 :
        return ClickerButtonValue.button5;
      case 6 :
        return ClickerButtonValue.button6;
      case 7 :
        return ClickerButtonValue.button7;
      case 8 :
        return ClickerButtonValue.button8;
      default :
        return ClickerButtonValue.button1;
    }
  }



}