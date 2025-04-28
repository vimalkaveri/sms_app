// main.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'menu/homepage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Function to request SMS permissions
  Future<void> requestPermissions() async {
    final PermissionStatus status = await Permission.sms.request();
    if (status.isGranted) {
      print('SMS permission granted');
    } else {
      print('SMS permission denied');
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMS Sender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}
