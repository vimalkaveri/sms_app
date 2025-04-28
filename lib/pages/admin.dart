import 'package:flutter/material.dart';
import '../sms_controller.dart';  // Make sure to import SMSController

class AdminPage extends StatefulWidget {
  final String phoneNumber;

  AdminPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _messageController = TextEditingController();
  final SMSController _smsController = SMSController();

  // Function to send SMS
  Future<void> _sendSMS() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      // Show an error if the message is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please enter a message."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Send the SMS
      await _smsController.sendSMS(
        phone: widget.phoneNumber,
        message: message,
      );

      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Message sent successfully!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      // Clear the message input field after sending
      _messageController.clear();
    } catch (e) {
      // Handle errors when sending SMS
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to send message: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Number Set'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number: ${widget.phoneNumber}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Enter Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
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
