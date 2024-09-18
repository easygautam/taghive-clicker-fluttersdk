
import 'dart:async';

import 'package:flutter_clicker_sdk/src/bluetooth/bluetooth_util.dart';
import 'package:flutter_clicker_sdk/src/clicker_data.dart';
import 'package:flutter_clicker_sdk/src/dongle/dongle_util.dart';



class ClickerService{

  ClickerScanMode scanMode = ClickerScanMode.bluetooth;

  var bluetoothUtil = BluetoothUtil();

  var dongleUtil = DongleUtil();

  void setScanMode({required ClickerScanMode mode}){
    scanMode = mode;
  }

  Future<bool> isClickerScanningAvailable() async{

    if(scanMode == ClickerScanMode.dongle){
      return dongleUtil.isPortAvailable();
    }else if(scanMode == ClickerScanMode.bluetooth){

     return bluetoothUtil.isAvailable();
    }

    return false;
  }

  void startScanning(){

    if(scanMode == ClickerScanMode.dongle){

      dongleUtil.startScanning();

    }else if(scanMode == ClickerScanMode.bluetooth){

      bluetoothUtil.startScanning();

    }

  }

  void stopScanning(){
    if(scanMode == ClickerScanMode.dongle){

      dongleUtil.finishRegistrationPort();

    }else if(scanMode == ClickerScanMode.bluetooth){

      bluetoothUtil.stopScanning();

    }
  }

  Stream<ClickerData> get clickerScanResultStream{
    if(scanMode == ClickerScanMode.dongle){
      return dongleUtil.portObserver.stream;
    }else{
      return bluetoothUtil.bleObserver.stream;
    }
  }

  void startRegistration({int? registrationKey}){

    try{

      if(scanMode == ClickerScanMode.dongle){
        dongleUtil.startRegistrationPort(registrationKey: registrationKey);
      }

    }catch(e){
    }

  }

  void stopRegistration(){
    if(scanMode == ClickerScanMode.dongle){
      dongleUtil.finishRegistrationPort();
    }
  }


}