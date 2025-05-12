import 'package:flutter/material.dart';
import '../controller/sms_controller.dart';

class AlertOption extends StatefulWidget {
  final String phoneNumber;

  const AlertOption({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _AlertOptionState createState() => _AlertOptionState();
}

class _AlertOptionState extends State<AlertOption> {
  final SMSController _smsController = SMSController();

  @override
  void initState() {
    super.initState();
    _smsController.requestPermissions(context);
    _smsController.startListeningForSMS(context);
  }

  void _sendSMS(String message) {
    _smsController.sendSMS(context, widget.phoneNumber, message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert command sent: $message')),
    );
  }

  Widget _buildAlertCard(String title, String message, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: ElevatedButton(
          onPressed: () => _sendSMS(message),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text("Set", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        title: const Text('Alert Options'),
        centerTitle: true,
        //backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAlertCard("Call Only", "SOCS YN", Icons.phone, Colors.green),
            _buildAlertCard("SMS Only", "SOCS NY", Icons.sms, Colors.orange),
            _buildAlertCard("Call & SMS", "SOCS YY", Icons.notifications_active, Colors.blue),
            _buildAlertCard("No Alert", "SOCS NN", Icons.notifications_off, Colors.redAccent),
          ],
        ),
      ),
    );
  }
}
