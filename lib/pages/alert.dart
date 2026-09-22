import 'package:flutter/material.dart';
import '../controller/sms_controller.dart';

class AlertPage extends StatefulWidget {
  final String phoneNumber;

  const AlertPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final SMSController _smsController = SMSController();

  String selectedAlertType1 = 'Select Alert Type';
  String selectedAlertType2 = 'Select Alert Type';

  final Map<String, String> alertTypeMap = {
    'OPEN': 'O',
    'CLOSE': 'C',
    'OPEN & CLOSE': 'S',
  };

  @override
  void initState() {
    super.initState();
    _smsController.requestPermissions(context);
    _smsController.startListeningForSMS(context);
  }

  void _sendSMS() {
    String predefinedMessage = 'SALT ';
    String? code1 = alertTypeMap[selectedAlertType1];
    String? code2 = alertTypeMap[selectedAlertType2];

    if (code1 != null && code2 != null) {
      predefinedMessage += '$code1$code2';

      _smsController.sendSMS(context, widget.phoneNumber, predefinedMessage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message sent: $predefinedMessage')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both alert types')),
      );
    }
  }

  Widget _buildDropdown(String selectedValue, void Function(String?) onChanged,
      String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            //color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueAccent, width: 1),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: alertTypeMap.containsKey(selectedValue)
                ? selectedValue
                : null,
            hint: const Text('Select Alert Type'),
            isExpanded: true,
            items: alertTypeMap.keys.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
            // Remove the default underline
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You can uncomment this if you want the Scaffold to have a background color
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        title: const Text('Alert Type Setup'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          elevation: 6,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          //color: const Color(0xFFF2F6FC),
          // Apply background color to Card
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Set Alert for Admin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  selectedAlertType1,
                      (value) {
                    setState(() {
                      selectedAlertType1 = value!;
                    });
                  },
                  'INPUT 1',
                ), // Label changed to INPUT 1
                const SizedBox(height: 16),
                _buildDropdown(
                  selectedAlertType2,
                      (value) {
                    setState(() {
                      selectedAlertType2 = value!;
                    });
                  },
                  'INPUT 2',
                ), // Label changed to INPUT 2
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _sendSMS,
                  icon: const Icon(Icons.send),
                  label: const Text('Alert Type'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}