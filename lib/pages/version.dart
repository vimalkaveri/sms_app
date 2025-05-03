//lib/pages/version
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../controller/sms_controller.dart';


class VersionPage extends StatefulWidget {
  final String phoneNumber;

  const VersionPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _VersionPageState createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  late TextEditingController _phoneController;
  final TextEditingController _messageController = TextEditingController();
  List<SmsMessage> receivedMessages = [];
  final SMSController _smsController = SMSController();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _smsController.requestPermissions(context);
    _smsController.startListeningForSMS(context);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendSMS() {
    final to = _phoneController.text.trim();
    final message = _messageController.text.trim();
    _smsController.sendSMS(context, to, message);
  }

  Widget _buildMessageTile(SmsMessage message) {
    return ListTile(
      leading: const Icon(Icons.sms),
      title: Text(message.body ?? 'No Content'),
      subtitle: Text('From: ${message.address ?? ''}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Sender & Receiver')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _sendSMS,
              icon: const Icon(Icons.send),
              label: const Text('Send SMS'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Received Messages:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: receivedMessages.length,
                itemBuilder: (context, index) =>
                    _buildMessageTile(receivedMessages[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
