import 'package:battery_plus/battery_plus.dart';

final Battery _battery = Battery();

Future<bool> isCharging() async {
  BatteryState state = await _battery.batteryState;
  return state != BatteryState.discharging;
}

Stream<BatteryState> onStateChange = _battery.onBatteryStateChanged;
