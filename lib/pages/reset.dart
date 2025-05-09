import 'package:flutter/material.dart';
import '../controller/sms_controller.dart';

class ResetPage extends StatefulWidget {
  final String phoneNumber;

  const ResetPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final SMSController _smsController = SMSController();

  @override
  void initState() {
    super.initState();
    _smsController.requestPermissions(context);
    _smsController.startListeningForSMS(context);
  }

  void _sendSMS(String message) {
    _smsController.sendSMS(context, widget.phoneNumber, message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Command sent: $message')),
    );
  }

  Widget _buildResetCard(String title, IconData icon, String message, String buttonLabel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _sendSMS(message),
              icon: const Icon(Icons.send),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        title: const Text('Reset Options'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildResetCard("Factory Restore", Icons.settings_backup_restore, "SFRT", "Factory Restore"),
            _buildResetCard("Master Reset", Icons.build, "MRST", "Master Reset"),
            _buildResetCard("Device Reboot", Icons.restart_alt, "SRST", "Reboot Device"),
          ],
        ),
      ),
    );
  }
}
