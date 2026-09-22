import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class StatusPage extends StatefulWidget {
  final String phoneNumber;

  const StatusPage({
    required this.phoneNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  final ValueNotifier<Map<String, dynamic>> _latestMessage =
  ValueNotifier<Map<String, dynamic>>({
    'message': <String, dynamic>{},
    'timestamp': 0,
  });

  @override
  void initState() {
    super.initState();

    _phoneController.text = widget.phoneNumber;
    _loadLatestMessage();
  }

  // ---------------------------------------------------------------------------
  // PARSE DEVICE STATUS REPLY
  // ---------------------------------------------------------------------------

  Map<String, String>? _parseStatusBody(String rawBody) {
    final body = rawBody.trim();

    if (!body.startsWith('ST:')) {
      return null;
    }

    final content = body.substring(3).trim();

    String sensor1 = '';
    String sensor2 = '';
    String sms = '';
    String call = '';

    final lines = content
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);

    for (final line in lines) {
      if (line.startsWith('S1-')) {
        sensor1 = _decodeSensorStatus(
          line.substring(3).trim(),
        );
      } else if (line.startsWith('S2-')) {
        sensor2 = _decodeSensorStatus(
          line.substring(3).trim(),
        );
      } else if (line.startsWith('SMS-')) {
        sms = _decodeAvailability(
          line.substring(4).trim(),
        );
      } else if (line.startsWith('CALL-')) {
        call = _decodeAvailability(
          line.substring(5).trim(),
        );
      }
    }

    return {
      'S1': sensor1,
      'S2': sensor2,
      'SMS': sms,
      'CALL': call,
    };
  }

  // ---------------------------------------------------------------------------
  // DECODE SENSOR STATUS
  //
  // Example:
  //
  // E-A-O-CLS
  //
  // E   = Enabled
  // A   = Active
  // O   = Open
  // CLS = Closed
  // ---------------------------------------------------------------------------

  String _decodeSensorStatus(String value) {
    final parts = value.split('-');

    if (parts.length < 4) {
      return value;
    }

    final device = parts[0].trim();
    final input = parts[1].trim();
    final alert = parts[2].trim();
    final condition = parts[3].trim();

    final deviceText = {
      'E': 'Enabled',
      'D': 'Disabled',
    }[device] ??
        device;

    final inputText = {
      'A': 'Active',
      'D': 'Inactive',
    }[input] ??
        input;

    final alertText = {
      'O': 'Open',
      'C': 'Close',
      'S': 'Open and Close',
    }[alert] ??
        alert;

    final conditionText = {
      'CLS': 'Closed',
      'OPN': 'Open',
    }[condition] ??
        condition;

    // Use | internally so each value can be displayed separately.
    return '$deviceText|$inputText|$alertText|$conditionText';
  }

  // ---------------------------------------------------------------------------
  // DECODE SMS / CALL
  // ---------------------------------------------------------------------------

  String _decodeAvailability(String value) {
    return {
      'NIL': 'Disabled',
      'AVBL': 'Enabled',
    }[value] ??
        value;
  }

  // ---------------------------------------------------------------------------
  // SAVE STATUS
  // ---------------------------------------------------------------------------

  Future<void> _saveLatestMessage(
      String message,
      int timestamp,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final keyPrefix = widget.phoneNumber;

    await prefs.setString(
      'message_${keyPrefix}_status',
      message,
    );

    await prefs.setInt(
      'message_${keyPrefix}_status_time',
      timestamp,
    );
  }

  // ---------------------------------------------------------------------------
  // LOAD SAVED STATUS
  // ---------------------------------------------------------------------------

  Future<void> _loadLatestMessage() async {
    final prefs = await SharedPreferences.getInstance();

    final keyPrefix = widget.phoneNumber;

    final messageJson = prefs.getString(
      'message_${keyPrefix}_status',
    );

    final timestamp = prefs.getInt(
      'message_${keyPrefix}_status_time',
    ) ??
        0;

    if (messageJson == null) {
      return;
    }

    try {
      final decoded = jsonDecode(messageJson);

      if (decoded is Map) {
        _latestMessage.value = {
          'message': Map<String, dynamic>.from(decoded),
          'timestamp': timestamp,
        };
      }
    } catch (_) {
      // Ignore invalid saved data.
    }
  }

  // ---------------------------------------------------------------------------
  // SEND GSTS SMS
  // ---------------------------------------------------------------------------

  Future<void> _sendSMS() async {
    final phoneNumber = _phoneController.text.trim();

    const fixedMessage = 'GSTS';

    if (phoneNumber.isEmpty) {
      _showDialog(
        'Validation Error',
        'Phone number is required.',
      );
      return;
    }

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        'body': fixedMessage,
      },
    );

    try {
      final canOpen = await canLaunchUrl(uri);

      if (!canOpen) {
        _showDialog(
          'Could Not Open Messages',
          'No SMS app was found.',
        );
        return;
      }

      final opened = await launchUrl(uri);

      if (!opened) {
        _showDialog(
          'Could Not Open Messages',
          'The SMS application could not be opened.',
        );
      }
    } catch (_) {
      _showDialog(
        'SMS Error',
        'Unable to open the SMS application.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PARSE PASTED REPLY
  // ---------------------------------------------------------------------------

  void _parsePastedReply() {
    final parsed = _parseStatusBody(
      _replyController.text,
    );

    if (parsed == null) {
      _showDialog(
        "Couldn't Parse Reply",
        'The pasted text does not look like a status reply.\n\n'
            'Expected it to start with "ST:".',
      );
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    _latestMessage.value = {
      'message': parsed,
      'timestamp': timestamp,
    };

    _saveLatestMessage(
      jsonEncode(parsed),
      timestamp,
    );

    _replyController.clear();

    FocusScope.of(context).unfocus();
  }

  // ---------------------------------------------------------------------------
  // DIALOG
  // ---------------------------------------------------------------------------

  void _showDialog(
      String title,
      String content,
      ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SENSOR CARD
  // ---------------------------------------------------------------------------

  Widget _buildSensorCard(
      String title,
      String? value,
      ) {
    if (value == null || value.isEmpty) {
      return _buildSimpleStatusCard(
        title,
        'No data',
        Icons.sensors_off,
      );
    }

    final parts = value.split('|');

    if (parts.length < 4) {
      return _buildSimpleStatusCard(
        title,
        value,
        Icons.sensors,
      );
    }

    final input = parts[0];
    final device = parts[1];
    final alert = parts[2];
    final condition = parts[3];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            _buildDetailRow(
              'Input',
              input,
            ),

            _buildDetailRow(
              'Device',
              device,
            ),

            _buildDetailRow(
              'Alert',
              alert,
            ),

            _buildDetailRow(
              'Current condition',
              condition,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SIMPLE STATUS CARD
  // ---------------------------------------------------------------------------

  Widget _buildSimpleStatusCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DETAIL ROW
  // ---------------------------------------------------------------------------

  Widget _buildDetailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SMS / CALL STATUS CARD
  // ---------------------------------------------------------------------------

  Widget _buildAvailabilityCard(
      String title,
      String? value,
      IconData icon,
      ) {
    final displayValue =
    value == null || value.isEmpty ? 'No data' : value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              displayValue,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COMPLETE STATUS DISPLAY
  // ---------------------------------------------------------------------------

  Widget _buildMessageCard(
      Map<String, dynamic> messageData,
      String formattedDate,
      ) {
    final message = messageData['message'];

    if (message is! Map) {
      return const Center(
        child: Text('Invalid message format'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Device Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Received: $formattedDate',
          style: const TextStyle(
            color: Colors.blueGrey,
          ),
        ),

        const SizedBox(height: 12),

        _buildSensorCard(
          'Sensor 1',
          message['S1']?.toString(),
        ),

        _buildSensorCard(
          'Sensor 2',
          message['S2']?.toString(),
        ),

        _buildAvailabilityCard(
          'SMS',
          message['SMS']?.toString(),
          Icons.sms,
        ),

        _buildAvailabilityCard(
          'Call',
          message['CALL']?.toString(),
          Icons.phone,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _phoneController.dispose();
    _replyController.dispose();
    _latestMessage.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),

      appBar: AppBar(
        title: const Text('Device Status'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [
            // ---------------------------------------------------------------
            // GET STATUS
            // ---------------------------------------------------------------

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendSMS,
                icon: const Icon(Icons.send),
                label: const Text('Get Status'),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------------------------------------------------
            // PASTE REPLY
            // ---------------------------------------------------------------

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Paste Device Reply',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'After the device replies, open Messages, '
                          'copy its reply, and paste it below.',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _replyController,
                      maxLines: 6,

                      decoration: const InputDecoration(
                        hintText:
                        'Paste the device reply here...\n\n'
                            'Example:\n'
                            'ST:\n'
                            'S1-E-A-O-CLS,\n'
                            'S2-E-A-O-CLS,\n'
                            'SMS-AVBL,\n'
                            'CALL-AVBL',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,

                      child: ElevatedButton.icon(
                        onPressed: _parsePastedReply,
                        icon: const Icon(Icons.check),
                        label: const Text('Parse Reply'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------------------------------------------------
            // LATEST RESULT
            // ---------------------------------------------------------------

            ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: _latestMessage,

              builder: (
                  context,
                  data,
                  _,
                  ) {
                final timestamp = data['timestamp'] ?? 0;

                final formattedDate = timestamp != 0
                    ? DateFormat(
                  'yyyy-MM-dd HH:mm:ss',
                ).format(
                  DateTime.fromMillisecondsSinceEpoch(
                    timestamp,
                  ),
                )
                    : 'Unknown';

                final message = data['message'];

                if (message is! Map || message.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No structured message parsed yet.',
                      ),
                    ),
                  );
                }

                return _buildMessageCard(
                  data,
                  formattedDate,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}