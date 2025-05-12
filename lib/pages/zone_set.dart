import 'package:flutter/material.dart';
import '../controller/sms_controller.dart';

class ZoneSetPage extends StatefulWidget {
  final String phoneNumber;

  const ZoneSetPage({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  _ZoneSetState createState() => _ZoneSetState();
}

class _ZoneSetState extends State<ZoneSetPage> {
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
      const SnackBar(content: Text('Command sent')),
    );
  }

  Widget _buildActionButton(String label, String message, {IconData? icon}) {
    return ElevatedButton.icon(
      onPressed: () => _sendSMS(message),
      icon: Icon(icon ?? Icons.settings, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        //backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, /*color: Colors.blueAccent*/),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, /*color: Colors.blueAccent*/),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(
        title: const Text('Zone Configuration'),
        centerTitle: true,
        //backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionCard(
              'Activate Zone-All',
              Icons.lock_open,
              [
                _buildActionButton("Activate", "SACTA", icon: Icons.play_arrow),
              ],
            ),
            _buildSectionCard(
              'Deactivate Zone-All',
              Icons.lock,
              [
                _buildActionButton("Deactivate", "SDATA", icon: Icons.stop),
              ],
            ),
            _buildSectionCard(
              'Enable Zone',
              Icons.toggle_on,
              [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildActionButton("Enable All", "SENBA", icon: Icons.select_all),
                    _buildActionButton("Zone 1", "SENB 1", icon: Icons.looks_one),
                    _buildActionButton("Zone 2", "SENB2", icon: Icons.looks_two),
                  ],
                ),
              ],
            ),
            _buildSectionCard(
              'Disable Zone',
              Icons.toggle_off,
              [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildActionButton("Disable All", "SDSBA", icon: Icons.cancel),
                    _buildActionButton("Zone 1", "SDSB 1", icon: Icons.looks_one),
                    _buildActionButton("Zone 2", "SDSB 2", icon: Icons.looks_two),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
