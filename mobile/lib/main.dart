import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(
    // ProviderScope hosts all Riverpod state for the application.
    const ProviderScope(child: QoLGuardApp()),
  );
}
