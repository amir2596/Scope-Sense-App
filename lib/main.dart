import 'package:flutter/material.dart';

import 'screens/input_screen.dart';

void main() {
  runApp(const ScopeSenseApp());
}

class ScopeSenseApp extends StatelessWidget {
  const ScopeSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScopeSense',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const InputScreen(),
    );
  }
}
