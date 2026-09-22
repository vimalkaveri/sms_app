import 'package:flutter/material.dart';
import '../controller/sms_controller.dart';

class VoiceRecordPage extends StatefulWidget {
  final String phoneNumber;

  const VoiceRecordPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _VoiceRecordPageState createState() => _VoiceRecordPageState();
}

class _VoiceRecordPageState extends State<VoiceRecordPage> {
  final SMSController _smsController = SMSController();

  void _sendSMS(String message) {
    _smsController.sendSMS(context, widget.phoneNumber, message);
  }

  Widget _buildVoiceCard(String title, String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _sendSMS(message),
          icon: const Icon(Icons.call),
          label: const Text("Send"),
          style: ElevatedButton.styleFrom(
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
