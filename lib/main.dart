import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const VeilmiApp());
}

class VeilmiApp extends StatelessWidget {
  const VeilmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veilmi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}