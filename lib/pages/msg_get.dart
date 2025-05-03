//lib/pages/msg_get
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../controller/sms_controller.dart';


class MessageGet extends StatefulWidget {
  final String phoneNumber;

  const MessageGet({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _MessageGetState createState() => _MessageGetState();
}

class _MessageGetState extends State<MessageGet> {
  final SMSController _smsController = SMSController();
  List<SmsMessage> receivedMessages = [];

  // Hardcoded message
  final String predefinedMessage = 'ADMIN'; // Hardcoded message

  @override
  void initState() {
    super.initState();
    _smsController.requestPermissions(context);
    _smsController.startListeningForSMS(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Sends the hardcoded "ADMIN" message to the phone number passed dynamically
  void _sendSMS() {
    final String phoneNumber = widget.phoneNumber;  // Use the phone number passed to the page
    _smsController.sendSMS(context, phoneNumber, predefinedMessage);
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
            // Button to send the hardcoded "ADMIN" message
            ElevatedButton.icon(
              onPressed: _sendSMS,
              label: const Text('Set Admin'),
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


