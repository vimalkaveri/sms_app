// lib/pages/msg_set.dart
import 'package:flutter/material.dart';
import '../sms_controller.dart';

class MessageSet extends StatefulWidget {
  final String phoneNumber;

  MessageSet({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _MessageSetState createState() => _MessageSetState();
}

class _MessageSetState extends State<MessageSet> {
  final _messageController = TextEditingController();
  final SMSController _smsController = SMSController();

  void _sendSMS() async {
    try {
      await _smsController.sendSMS(
        phone: widget.phoneNumber,
        message: _messageController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SMS sent successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send SMS: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Message')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Enter your message',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendSMS,
              child: Text('Send SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
