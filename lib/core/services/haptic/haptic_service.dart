import 'package:vibration/vibration.dart';

class HapticService {
  Future<void> lightImpact() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 15, amplitude: 60);
    }
  }

  Future<void> mediumImpact() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 30, amplitude: 128);
    }
  }

  Future<void> heavyImpact() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50, amplitude: 255);
    }
  }

  Future<void> explosionPattern() async {
    if (await Vibration.hasVibrator() == true) {
      // Pattern: wait, vibrate, wait, vibrate...
      Vibration.vibrate(pattern: [0, 20, 30, 40]);
    }
  }
}
