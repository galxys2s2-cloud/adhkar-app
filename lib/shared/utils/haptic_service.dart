import 'package:flutter/material.dart';

class HapticService {
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }

  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }

  static void successFeedback() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
}
