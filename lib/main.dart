import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMS Sender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Telephony telephony = Telephony.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  // Request SMS permissions
  Future<void> requestPermissions() async {
    final status = await Permission.sms.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS permission is required to send messages.")),
      );
    }
  }

  // Function to send SMS
  Future<void> sendSMS() async {
    final isGranted = await Permission.sms.isGranted;
    final phone = _phoneController.text.trim();
    final message = _msgController.text.trim();

    if (!isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS permission not granted.")),
      );
      return;
    }

    if (phone.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both phone number and message.")),
      );
      return;
    }

    try {
      await telephony.sendSms(
        to: phone,
        message: message,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS sent successfully.")),
      );
    } catch (e) {
      print("Error sending SMS: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send SMS.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SMS Sender")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter phone number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _msgController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Message",
                hintText: "Enter your message (Hindi or any language)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendSMS,
              child: Text("Send SMS"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
