// lib/menu/manupage.dart
import 'package:flutter/material.dart';
import '../models/settings_item.dart';
import '../pages/admin.dart';
import '../pages/msg_set.dart';


class DeviceDetailsScreen extends StatelessWidget {
  final Map<String, String> device;

  DeviceDetailsScreen({required this.device, Key? key}) : super(key: key);

  final List<SettingsItem> settings = [
    SettingsItem(icon: Icons.admin_panel_settings, label: 'ADMIN', page: (phoneNumber) => AdminPage(phoneNumber: phoneNumber)),
    SettingsItem(icon: Icons.phone, label: 'Ph No.', page: (phoneNumber) => AdminPage(phoneNumber: phoneNumber)),
    SettingsItem(icon: Icons.message, label: 'MESSAGE', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildTitle()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '${device['deviceName']}\n${device['phoneNumber']}',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 9),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: settings.length,
          itemBuilder: (context, index) {
            return _buildSettingItem(
              context,
              settings[index].icon,
              settings[index].label,
              settings[index].page,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String label, Function(String) page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page(device['phoneNumber']!),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
