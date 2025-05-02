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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ADMIN message sent successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        title: const Text('Admin Control Panel'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings, size: 60, color: Colors.blueAccent),
                const SizedBox(height: 16),
                const Text(
                  'Click here to set admin if you want to.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _sendSMS,
                  icon: const Icon(Icons.send),
                  label: const Text('Set Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
