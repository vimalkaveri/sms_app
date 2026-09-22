import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sends "GVER" via the SMS compose screen; the user pastes the
/// device's "GV:" reply back in to see it parsed. See status.dart for
/// why this no longer auto-captures the reply.
class VersionPage extends StatefulWidget {
  final String phoneNumber;

  const VersionPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  State<VersionPage> createState() => _VersionPageState();
}

class _VersionPageState extends State<VersionPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
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

  Map<String, String>? _parseVersionBody(String rawBody) {
    final body = rawBody.trim();
    if (!body.startsWith("GV:")) return null;

    final content = body.replaceFirst("GV:", "").trim();
    final lines = content.split('\n').map((e) => e.trim()).toList();

    String version = '';
    String imei = '';
    String gsm = '';

    for (var line in lines) {
      if (line.startsWith("NANO")) {
        final versionLine = line.replaceFirst("NANO", "").trim();
        final versionMatch = RegExp(r"VER:\s*([0-9.]+)").firstMatch(versionLine);
        if (versionMatch != null) {
          version = versionMatch.group(1) ?? '';
        }
      } else if (line.startsWith("IMEI")) {
        imei = line.replaceFirst("IMEI:", "").trim();
      } else if (line.startsWith("GSM")) {
        gsm = line.replaceFirst("GSM:", "").trim();
      }
    }

    return {'VERSION': version, 'IMEI': imei, 'GSM': gsm};
  }

  Future<void> _saveLatestMessage(String message, int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    await prefs.setString('message_${keyPrefix}_version', message);
    await prefs.setInt('message_${keyPrefix}_version_time', timestamp);
  }

  Future<void> _loadLatestMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    final messageJson = prefs.getString('message_${keyPrefix}_version');
    final timestamp = prefs.getInt('message_${keyPrefix}_version_time') ?? 0;

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
    const fixedMessage = "GVER";

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

  void _parsePastedReply() {
    final parsed = _parseVersionBody(_replyController.text);
    if (parsed == null) {
      _showDialog(
        "Couldn't Parse Reply",
        "The pasted text doesn't look like a version reply (expected it to start with \"GV:\").",
      );
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _latestMessage.value = {'message': parsed, 'timestamp': timestamp};
    _saveLatestMessage(jsonEncode(parsed), timestamp);
    _replyController.clear();
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
            _buildStatusRow("Version", message['VERSION']),
            _buildStatusRow("IMEI", message['IMEI']),
            _buildStatusRow("GSM", message['GSM']),
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
    _phoneController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(title: const Text("Version")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton.icon(
              onPressed: _sendSMS,
              icon: const Icon(Icons.send),
              label: const Text("Get Version"),
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
                      "After the device replies, open Messages, copy its reply, and paste it below.",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _replyController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Paste the device\'s reply here (starts with "GV:")',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _parsePastedReply,
                        icon: const Icon(Icons.check),
                        label: const Text("Parse Reply"),
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

                if ((data['message'] as Map).isEmpty) {
                  return const Center(child: Text("No structured message parsed yet."));
                }

                return _buildMessageCard(data, formattedDate);
              },
            ),
          ],
        ),
      ),
    );
  }
}
