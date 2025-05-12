import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import '../controller/sms_controller.dart';

class MessageSet extends StatefulWidget {
  final String phoneNumber;

  const MessageSet({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _MessageSetState createState() => _MessageSetState();
}

class _MessageSetState extends State<MessageSet> {
  late TextEditingController _phoneController;
  final TextEditingController _messageController1 = TextEditingController();
  final TextEditingController _messageController2 = TextEditingController();
  final SMSController _smsController = SMSController();

  final String predefinedMessage1 = 'SMSG1 ';
  final String predefinedMessage2 = 'SMSG2 ';

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
    _messageController1.dispose();
    _messageController2.dispose();
    super.dispose();
  }

  void _sendSMSG(String prefix, TextEditingController controller) {
    final to = _phoneController.text.trim();
    final additionalMessage = controller.text.trim();

    if (additionalMessage.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation Error'),
          content: const Text('Message cannot be empty. Please enter Alert text.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final fullMessage = '$prefix$additionalMessage';
    _smsController.sendSMS(context, to, fullMessage);
  }

  Widget _buildMessageInputCard({
    required String label,
    required String prefix,
    required TextEditingController controller,
    required VoidCallback onSubmit,
    required IconData icon,
  }) {
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
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '$label',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
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
                onPressed: onSubmit,
                  icon: const Icon(Icons.send),
                  label: const Text("Send Message"),

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
        title: const Text('Set Alert SMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildMessageInputCard(
              label: 'Message Type 1',
              prefix: predefinedMessage1,
              controller: _messageController1,
              onSubmit: () => _sendSMSG(predefinedMessage1, _messageController1),
              icon: Icons.message_outlined,
            ),
            _buildMessageInputCard(
              label: 'Message Type 2',
              prefix: predefinedMessage2,
              controller: _messageController2,
              onSubmit: () => _sendSMSG(predefinedMessage2, _messageController2),
              icon: Icons.message_outlined,
              //icon: Icons.mark_chat_read_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
