import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageGet extends StatefulWidget {
  final String phoneNumber;

  const MessageGet({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  State<MessageGet> createState() => _MessageGetState();
}

class _MessageGetState extends State<MessageGet> {
  final Telephony _telephony = Telephony.instance;
  final TextEditingController _phoneController = TextEditingController();
  final ValueNotifier<Map<String, dynamic>> _latestMessage = ValueNotifier({
    'message': {},
    'timestamp': 0,
  });
  final ValueNotifier<bool> _responseReceived = ValueNotifier(false);

  Timer? _timeoutTimer;
  String? _lastSentNumber;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    _requestPermissions();
    _listenToIncomingSMS();
    _loadLatestMessage();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    if (!statuses[Permission.sms]!.isGranted || !statuses[Permission.phone]!.isGranted) {
      _showDialog("Permission Error", "SMS & Phone permissions are required.");
    }
  }

  void _listenToIncomingSMS() {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final sender = message.address?.replaceAll(RegExp(r'\D'), '');
        final expected = _lastSentNumber?.replaceAll(RegExp(r'\D'), '');

        if (!_responseReceived.value &&
            sender != null &&
            expected != null &&
            sender.endsWith(expected)) {
          _responseReceived.value = true;
          _timeoutTimer?.cancel();
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }

        final body = message.body?.trim() ?? '';

        if (body.startsWith("MR:")) {
          final content = body.replaceFirst("MR:", "").trim();
          final lines = content.split('\n').map((e) => e.trim()).toList();

          String m1Alert = '';
          String m2Alert = '';

          for (var line in lines) {
            if (line.startsWith("M1-")) {
              m1Alert = line.replaceFirst("M1-", "").trim();
            } else if (line.startsWith("M2-")) {
              m2Alert = line.replaceFirst("M2-", "").trim();
            }
          }

          final structuredMessage = {
            'M1_ALERT': m1Alert,
            'M2_ALERT': m2Alert,
          };

          final timestamp = message.date ?? DateTime.now().millisecondsSinceEpoch;

          // Update ValueNotifier with new message data
          _latestMessage.value = {
            'message': structuredMessage,
            'timestamp': timestamp,
          };

          _saveLatestMessage(jsonEncode(structuredMessage), timestamp);
        }
      },
      listenInBackground: false,
    );
  }

  Future<void> _saveLatestMessage(String message, int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    await prefs.setString('message_${keyPrefix}_message', message);
    await prefs.setInt('message_${keyPrefix}_timestamp', timestamp);
  }

  Future<void> _loadLatestMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    final messageJson = prefs.getString('message_${keyPrefix}_message');
    final timestamp = prefs.getInt('message_${keyPrefix}_timestamp') ?? 0;

    if (messageJson != null) {
      final structuredMessage = jsonDecode(messageJson);
      _latestMessage.value = {
        'message': structuredMessage,
        'timestamp': timestamp,
      };
    }
  }

  Future<void> _sendSMS() async {
    final phoneNumber = _phoneController.text.trim();
    const fixedMessage = "SMSG"; // Changed message to "SMSG"

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
      _showDialog("Error", "SMS failed to send: ${e.toString()}");
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

  Widget _buildMessageCard(Map<String, dynamic> messageData, String formattedDate) {
    final message = messageData['message'];
    if (message is! Map<String, dynamic>) {
      return const Center(child: Text("Invalid message format"));
    }

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
            _buildStatusRow("M1 Alert", message['M1_ALERT']), // Change key here
            _buildStatusRow("M2 Alert", message['M2_ALERT']), // Change key here
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? 'N/A', style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
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
      appBar: AppBar(title: const Text("Structured SMS Reader")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _sendSMS,
              icon: const Icon(Icons.send),
              label: const Text("Send SMS Request"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: _latestMessage,
                builder: (context, data, _) {
                  final timestamp = data['timestamp'] ?? 0;
                  final formattedDate = timestamp != 0
                      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(timestamp))
                      : 'Unknown';

                  if ((data['message'] as Map).isEmpty) {
                    return const Center(child: Text("No structured message received yet."));
                  }

                  return _buildMessageCard(data, formattedDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
