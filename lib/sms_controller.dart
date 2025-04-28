import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class SMSController {
  final Telephony _telephony = Telephony.instance;
  List<String> receivedMessages = [];

  // StreamController for managing the received messages
  final StreamController<List<String>> _messageController = StreamController<List<String>>();

  // Getter for the received messages stream
  Stream<List<String>> get messageStream => _messageController.stream;

  // Function to request SMS permissions
  Future<void> requestPermissions() async {
    final PermissionStatus status = await Permission.sms.request();
    if (status.isGranted) {
      print('SMS permission granted');
    } else {
      print('SMS permission denied');
    }
  }

  // Function to send SMS
  Future<void> sendSMS({required String phone, required String message}) async {
    await _telephony.sendSms(to: phone, message: message);
  }

  // Function to listen for incoming SMS using listenIncomingSms method
  void listenForSms() {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // Add the received SMS to the list
        receivedMessages.add('From: ${message.address}, Message: ${message.body}');

        // Update the stream with new received messages
        _messageController.sink.add(receivedMessages);
      },
    );
  }

  // Don't forget to close the stream controller when it's no longer needed
  void dispose() {
    _messageController.close();
  }
}
