import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sends "SPHO" via the SMS compose screen. The device replies with
/// TWO messages ("PR-M1:" and "PR-M2:"), so the user pastes each one in
/// separately and taps Parse once both are filled in. See status.dart
/// for why this no longer auto-captures replies.
class PhoneNumberGet extends StatefulWidget {
  final String phoneNumber;

  const PhoneNumberGet({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  State<PhoneNumberGet> createState() => _PhoneNumberGetState();
}

class _PhoneNumberGetState extends State<PhoneNumberGet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _m1Controller = TextEditingController();
  final TextEditingController _m2Controller = TextEditingController();
  final ValueNotifier<Map<String, dynamic>> _latestMessage = ValueNotifier({
    'message': {},
    'timestamp': 0,
  });

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    _loadLatestMessage();
  }

  Future<void> _saveLatestMessage(String message, int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    await prefs.setString('message_${keyPrefix}_phone', message);
    await prefs.setInt('message_${keyPrefix}_phone_time', timestamp);
  }

  Future<void> _loadLatestMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    final messageJson = prefs.getString('message_${keyPrefix}_phone');
    final timestamp = prefs.getInt('message_${keyPrefix}_phone_time') ?? 0;

    if (messageJson != null) {
      final structuredMessage = Map<String, dynamic>.from(jsonDecode(messageJson));
      _latestMessage.value = {
        'message': structuredMessage,
        'timestamp': timestamp,
      };
    }
  }

  Future<void> _sendSMS() async {
    final phoneNumber = _phoneController.text.trim();
    const fixedMessage = "SPHO";

    if (phoneNumber.isEmpty) {
      _showDialog("Validation Error", "Phone number is required.");
      return;
    }

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': fixedMessage},
    );

    final opened = await canLaunchUrl(uri) && await launchUrl(uri);
    if (!opened) {
      _showDialog("Could Not Open Messages", "No SMS app was found.");
    }
  }

  void _parsePastedReplies() {
    final m1 = _m1Controller.text.trim();
    final m2 = _m2Controller.text.trim();

    if (!m1.startsWith("PR-M1:") || !m2.startsWith("PR-M2:")) {
      _showDialog(
        "Couldn't Parse Replies",
        "Paste both device replies: the first starting with \"PR-M1:\" and "
            "the second starting with \"PR-M2:\".",
      );
      return;
    }

    final allParams = <String, String>{};
    final m1Lines = m1.split('\n');
    final m2Lines = m2.split('\n');
    final allLines = [...m1Lines.skip(1), ...m2Lines.skip(1)]; // skip PR-M1:/PR-M2:

    for (var i = 0; i < allLines.length; i++) {
      final param = 'P${i + 1}';
      final value = allLines[i].replaceAll('$param-', '').trim();
      allParams[param] = value;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _latestMessage.value = {'message': allParams, 'timestamp': timestamp};
    _saveLatestMessage(jsonEncode(allParams), timestamp);
    _m1Controller.clear();
    _m2Controller.clear();
    FocusScope.of(context).unfocus();
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

  Widget _buildMessageCard(Map<String, dynamic> messageData, String formattedDate) {
    final message = Map<String, dynamic>.from(messageData['message'] ?? {});

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Structured Status Message\n$formattedDate", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...List.generate(20, (index) {
              final key = 'P${index + 1}';
              final value = message[key] ?? 'N/A';
              return _buildStatusRow(key, value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _m1Controller.dispose();
    _m2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(title: const Text("Get Phone Number")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _sendSMS,
                icon: const Icon(Icons.send),
                label: const Text("Get Number"),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "The device replies with two messages. Paste each one below.",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _m1Controller,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'First reply',
                          hintText: 'Paste the reply starting with "PR-M1:"',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _m2Controller,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Second reply',
                          hintText: 'Paste the reply starting with "PR-M2:"',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _parsePastedReplies,
                          icon: const Icon(Icons.check),
                          label: const Text("Parse Replies"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: _latestMessage,
                builder: (context, data, _) {
                  final timestamp = data['timestamp'] ?? 0;
                  final formattedDate = timestamp != 0
                      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(timestamp))
                      : 'Unknown';

                  final message = Map<String, dynamic>.from(data['message'] ?? {});
                  if (message.isEmpty) {
                    return const Center(child: Text("No structured message parsed yet."));
                  }

                  return _buildMessageCard(data, formattedDate);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
