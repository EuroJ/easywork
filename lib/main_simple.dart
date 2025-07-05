import 'package:flutter/material.dart';
import 'screens/test_screen.dart';

void main() {
  print('🚀 Starting Simple Test App...');
  runApp(const SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 Building SimpleTestApp...');
    
    return MaterialApp(
      title: 'Easy Work Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}