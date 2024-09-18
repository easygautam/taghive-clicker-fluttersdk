
class ClickerData {
  String deviceId;
  ClickerButtonValue clickerButtonValue;
  BatteryLevel clickerBatteryLevel;

  ClickerData({
    required this.deviceId,
    required this.clickerButtonValue,
    required this.clickerBatteryLevel,
  });
}

enum ClickerButtonValue {
  button1,
  button2,
  button3,
  button4,
  button5,
  button6,
  button7,
  button8,
}

enum BatteryLevel { batteryHigh, batteryLow, batteryMedium }

enum ClickerScanMode {
  bluetooth, dongle
}