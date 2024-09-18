library flutter_clicker_sdk;

import 'package:flutter_clicker_sdk/src/clicker_data.dart';
import 'package:flutter_clicker_sdk/src/clicker_service.dart';

class FlutterClickerSdk{
  static final _clickerService = ClickerService();

  static Stream<ClickerData> get clickerScanStream{
    return _clickerService.clickerScanResultStream;
  }

  static Future<bool> isClickerScanningAvailable(){
    return _clickerService.isClickerScanningAvailable();
  }

  static ClickerScanMode getClickerScanMode(){
    return _clickerService.scanMode;
  }

  static void setClickerScanMode({required ClickerScanMode mode}){
    _clickerService.setScanMode(mode: mode);
  }

  static void startClickerScanning(){
    _clickerService.startScanning();
  }

  static void startClickerRegistration({required int registrationKey}){
    _clickerService.startRegistration(registrationKey: registrationKey);
  }

  static void stopClickerRegistration(){
    _clickerService.stopRegistration();
  }


  static void stopClickerScanning(){
    _clickerService.stopScanning();
  }
}

