import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleMessage {
  final String body;
  final String address;
  final int date;

  SimpleMessage({required this.body, required this.address, required this.date});

  factory SimpleMessage.fromJson(Map<String, dynamic> json) {
    return SimpleMessage(
      body: json['body'],
      address: json['address'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'body': body,
    'address': address,
    'date': date,
  };
}

class PhoneNumberGet extends StatefulWidget {
  final String phoneNumber;

  const PhoneNumberGet({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  State<PhoneNumberGet> createState() => _PhoneNumberGetState();
}

class _PhoneNumberGetState extends State<PhoneNumberGet> {
  final Telephony _telephony = Telephony.instance;
  final TextEditingController _phoneController = TextEditingController();
  final ValueNotifier<List<SimpleMessage>> _validMessages = ValueNotifier([]);
  final ValueNotifier<bool> _responseReceived = ValueNotifier(false);

  Timer? _timeoutTimer;
  String? _lastSentNumber;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    _requestPermissions();
    _loadLatestMessages();
    _listenToIncomingSMS();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [Permission.sms, Permission.phone].request();

    if (!statuses[Permission.sms]!.isGranted || !statuses[Permission.phone]!.isGranted) {
      _showDialog("Permission Error", "SMS & Phone permissions are required.");
    }
  }

  void _listenToIncomingSMS() {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final body = message.body?.trim() ?? '';
        final sender = message.address?.replaceAll(RegExp(r'\D'), '');
        final expected = _lastSentNumber?.replaceAll(RegExp(r'\D'), '');

        if (!_responseReceived.value && sender != null && expected != null && sender.endsWith(expected)) {
          _responseReceived.value = true;
          _timeoutTimer?.cancel();
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }

        if (body.startsWith("PR-M1:") || body.startsWith("PR-M2:")) {
          final newMessage = SimpleMessage(
            body: message.body ?? '',
            address: message.address ?? '',
            date: message.date ?? DateTime.now().millisecondsSinceEpoch,
          );

          final updatedMessages = [..._validMessages.value, newMessage];
          _validMessages.value = updatedMessages;
          _saveLatestMessages(updatedMessages);
        }
      },
      listenInBackground: false,
    );
  }

  Future<void> _sendSMS() async {
    final phoneNumber = _phoneController.text.trim();
    const fixedMessage = "SPHO";

    if (phoneNumber.isEmpty) {
      _showDialog("Validation Error", "Phone number is required.");
      return;
    }

    if (!await Permission.sms.isGranted) {
      if (!await Permission.sms.request().isGranted) {
        _showDialog("Permission Denied", "SMS permission not granted.");
        return;
      }
    }

    _lastSentNumber = phoneNumber;
    _responseReceived.value = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Waiting for reply...'),
          ],
        ),
      ),
    );

    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (!_responseReceived.value && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        _showDialog("No Response", "Please try again later.");
      }
    });

    try {
      await _telephony.sendSms(to: phoneNumber, message: fixedMessage);
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      _timeoutTimer?.cancel();
      _showDialog("Error", "SMS failed to send: \${e.toString()}");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  String _cleanMessageBody(String body) {
    return body.replaceAll(RegExp(r"^(PR-M1:|PR-M2:)\s*"), "").trim();
  }

  Widget _buildSmsCard(List<SimpleMessage> messages) {
    final messageBodies = messages.map((m) => _cleanMessageBody(m.body)).join("\n");
    final parts = messageBodies.split("\n").map((msg) => msg.trim()).toList();

    final formattedMessage = List.generate(parts.length, (index) {
      return "${parts[index]}";  // Use double quotes here
    }).join("\n");


    final date = messages.isNotEmpty
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(messages.last.date))
        : 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Received Messages $date",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const Divider(),
            Text(
              formattedMessage.isEmpty ? 'No Messages Received' : formattedMessage,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLatestMessages(List<SimpleMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'messages_\${widget.phoneNumber}';
    final encodedMessages = messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(key, encodedMessages);
  }

  Future<void> _loadLatestMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'messages_\${widget.phoneNumber}';
    final savedList = prefs.getStringList(key) ?? [];
    final List<SimpleMessage> loadedMessages =
    savedList.map((jsonStr) => SimpleMessage.fromJson(jsonDecode(jsonStr))).toList();
    _validMessages.value = [...loadedMessages];
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Get Phone Number")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _sendSMS,
              icon: const Icon(Icons.send),
              label: const Text("Get Ph number"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<SimpleMessage>>(
                valueListenable: _validMessages,
                builder: (context, messages, _) {
                  return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (_, index) {
                      return _buildSmsCard(messages);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}