import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecordPage extends StatefulWidget {
  final String phoneNumber;

  const VoiceRecordPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _VoiceRecordPageState createState() => _VoiceRecordPageState();
}

class _VoiceRecordPageState extends State<VoiceRecordPage> {
  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    requestPermissions(context);
  }

  Future<void> requestPermissions(BuildContext context) async {
    final statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    if (!(statuses[Permission.sms]?.isGranted ?? false) ||
        !(statuses[Permission.phone]?.isGranted ?? false)) {
      _showPopupStatusDialog(context, "Permission Error", "SMS & Phone permissions are required.");
    }
  }

  void sendSMS(BuildContext context, String phoneNumber, String message) async {
    if (phoneNumber.isEmpty || message.isEmpty) {
      _showPopupStatusDialog(context, 'Validation Error', 'Enter both phone number and message');
      return;
    }

    final permission = await Permission.sms.status;
    if (!permission.isGranted) {
      final result = await Permission.sms.request();
      if (!result.isGranted) {
        _showPopupStatusDialog(context, 'Permission Denied', 'SMS permission not granted');
        return;
      }
    }

    try {
      await telephony.sendSms(to: phoneNumber, message: message);
      _showPopupStatusDialog(context, 'Wait for Call', 'SMS sent. Please wait for the call.');
    } catch (e) {
      _showPopupStatusDialog(context, "Error", "Failed to send SMS.");
    }
  }

  void _showPopupStatusDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVoiceCard(String title, String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => sendSMS(context, widget.phoneNumber, message),
          icon: const Icon(Icons.call),
          label: const Text("Send"),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        title: const Text('Voice Record'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVoiceCard("Set Voice Message 1", "VREC 1", Icons.mic, Colors.teal),
            _buildVoiceCard("Set Voice Message 2", "VREC 2", Icons.mic_none, Colors.teal),
          ],
        ),
      ),
    );
  }
}
