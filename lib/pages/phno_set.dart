import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/sms_controller.dart';

// Formatter to allow only digits or '+'
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    return RegExp(r'^[0-9+]*$').hasMatch(text) ? newValue : oldValue;
  }
}

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
      'label': '${index + 1}',
      'prefix': 'SPHO${index + 1} ',
      'controller': TextEditingController(),
    };
  });

  bool _isEditingFirst = false;

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

    if (!_isPhoneNumberValid(to)) {
      _showAlertDialog(
        'Invalid Phone Number',
        'Please enter a valid phone number (e.g., +919003042821 or 919003042821).',
      );
      return;
    }

    final message = '$prefix$additional';
    _smsController.sendSMS(context, to, message);
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

  Widget _buildMessageRow(Map<String, dynamic> type) {
    final isFirst = type['label'] == '1';

    if (isFirst && !_isEditingFirst) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isEditingFirst = true;
          });
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Want To Change Admin?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${type['label']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: type['controller'],
                  keyboardType: TextInputType.phone,
                  inputFormatters: [DigitsOnlyFormatter()],
                  decoration: InputDecoration(
                    hintText: isFirst
                        ? 'Enter new admin number...'
                        : 'Enter digits only...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.blue.shade300,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () => _sendSMS(type['prefix'], type['controller']),
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
        title: const Text('Set Phone Number'),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            ...messageTypes.map((type) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildMessageRow(type),
            )),
          ],
        ),
      ),
    );
  }
}
