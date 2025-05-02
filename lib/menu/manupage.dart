import 'package:flutter/material.dart';
import '../models/device.dart';
import '../models/settings_item.dart';
import '../pages/admin.dart';
import '../pages/msg_set.dart';
import '../pages/help.dart';
import '../pages/msg_get.dart';
import '../pages/phno_get.dart';
import '../pages/phno_set.dart';
import '../pages/status.dart';
import '../pages/version.dart';
import '../pages/voice_record.dart';
import '../pages/alertoption.dart';
import '../pages/reset.dart';
import '../pages/alert.dart';
import '../pages/zone_set.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final Device device;

  DeviceDetailsScreen({required this.device, Key? key}) : super(key: key);

  final List<SettingsItem> settings = [
    SettingsItem(
      icon: Icons.admin_panel_settings,
      label: 'ADMIN',
      page: (phoneNumber) => AdminPage(phoneNumber: phoneNumber),
    ),
    SettingsItem(
      icon: Icons.phone,
      label: 'Ph No.',
      page: (phoneNumber) => PhoneNumberSet(phoneNumber: phoneNumber),
    ),
    SettingsItem(
      icon: Icons.message,
      label: 'MESSAGE',
      page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),
    ),
    SettingsItem(icon: Icons.notifications, label: 'ALERT', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    SettingsItem(icon: Icons.layers, label: 'ZONES', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    SettingsItem(icon: Icons.refresh, label: 'RESET', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    SettingsItem(icon: Icons.notification_important, label: 'ALERT OPTION', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    SettingsItem(icon: Icons.mic, label: 'VOICE RECORD', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
  ];

  final List<StatusItem> status = [
    StatusItem(icon: Icons.phone_android, label: 'PH NO.', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    StatusItem(icon: Icons.message, label: 'MESSAGE', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    StatusItem(icon: Icons.device_hub, label: 'STATUS',page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    StatusItem(icon: Icons.verified_user, label: 'VERSION', page: (phoneNumber) => MessageSet(phoneNumber: phoneNumber),),
    StatusItem(icon: Icons.help_outline, label: 'HELP', page: (phoneNumber) => HelpPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSettingsSection(context),
            const SizedBox(height: 20),
            _buildStatusSection(context),
          ],
        ),
      ),
    );
  }

  // Title widget for the app bar
  Widget _buildTitle() {
    return Text(
      '${device.deviceName}\n${device.phoneNumber}',
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // Settings section widget
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
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

  // Status section widget
  Widget _buildStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 9),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: status.length,
          itemBuilder: (context, index) {
            return _buildSettingItem(
              context,
              status[index].icon,
              status[index].label,
              status[index].page,
            );
          },
        ),
      ],
    );
  }

  // Common widget for setting and status items
  Widget _buildSettingItem(BuildContext context, IconData icon, String label, Function(String) page) {
    return InkWell(
      onTap: () {
        // Use the page function to create an instance and pass the phone number
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page(device.phoneNumber),
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
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Define settings and status items as data models for clarity and maintainability

class SettingsItem {
  final IconData icon;
  final String label;
  final Function(String) page;

  SettingsItem({required this.icon, required this.label, required this.page});
}

class StatusItem {
  final IconData icon;
  final String label;
  final Function(String) page;

  StatusItem({required this.icon, required this.label, required this.page});
}
