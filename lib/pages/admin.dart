import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../controller/sms_controller.dart';

class AdminPage extends StatefulWidget {
  final String phoneNumber;

  const AdminPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final SMSController _smsController = SMSController();
  final String predefinedMessage = 'ADMIN';

  @override
  void initState() {
    super.initState();
    _smsController.requestPermissions(context);
    _smsController.startListeningForSMS(context);
  }

  void _sendSMS() {
    _smsController.sendSMS(context, widget.phoneNumber, predefinedMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light gray background
      appBar: AppBar(
        title: const Text('Set Admin'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon for Admin Settings
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),

              // Instructional Text
              const Text(
                'Tap below to set admin for your account.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Set Admin Button
              ElevatedButton(
                onPressed: _sendSMS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Corrected the parameter name
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Set Admin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
