import 'package:flutter/material.dart';
import '../controller/sms_controller.dart';

class PhoneNumberSet extends StatefulWidget {
  final String phoneNumber;

  const PhoneNumberSet({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _PhoneNumberSetState createState() => _PhoneNumberSetState();
}

class _PhoneNumberSetState extends State<PhoneNumberSet> {
  final SMSController _smsController = SMSController();
  late TextEditingController _phoneController;

  final List<Map<String, dynamic>> messageTypes = List.generate(20, (index) {
    return {
      'label': 'Phone Number ${index + 1}',
      'prefix': 'SPHO${index + 1} ',
      'controller': TextEditingController(),
      'icon': Icons.sms_outlined,
    };
  });

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
    for (var type in messageTypes) {
      type['controller'].dispose();
    }
    super.dispose();
  }

  bool _isPhoneNumberValid(String phoneNumber) {
    final phoneRegExp = RegExp(r'^\+?[0-9]+$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  void _sendSMS(String prefix, TextEditingController controller) {
    final to = _phoneController.text.trim();
    final additional = controller.text.trim();

    // Validate phone number format
    if (!_isPhoneNumberValid(to)) {
      _showAlertDialog('Invalid Phone Number', 'Please enter a valid phone number (e.g., +919003042821 or 919003042821).');
      return;
    }

    if (additional.isEmpty) {
      _showAlertDialog('Message is empty', 'Please enter a message before sending.');
      return;
    }

    final message = '$prefix$additional';
    _smsController.sendSMS(context, to, message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent: $message')),
    );
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> type) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(type['icon'], color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '${type['label']} ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: type['controller'],
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _sendSMS(type['prefix'], type['controller']),
                icon: const Icon(Icons.send),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
      appBar: AppBar(
        title: const Text('Advanced SMS Sender'),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: messageTypes.length,
          itemBuilder: (context, index) {
            return _buildMessageCard(messageTypes[index]);
          },
        ),
      ),
    );
  }
}
