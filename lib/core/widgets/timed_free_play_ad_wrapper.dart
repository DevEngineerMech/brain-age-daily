
import 'package:flutter/material.dart';

/// Keeps existing Free Play navigation compatible.
///
/// Interstitial adverts are now controlled entirely by
/// FreePlayPage after a completed game.
///
/// No timers, random intervals or interruptions during
/// gameplay are permitted.
class TimedFreePlayAdWrapper extends StatelessWidget {
  final Widget child;

  const TimedFreePlayAdWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
