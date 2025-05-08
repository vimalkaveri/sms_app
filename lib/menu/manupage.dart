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

  final MaterialColor _primarySwatch = Colors.blue;

  final List<SettingsItem> settings = [
    SettingsItem(icon: Icons.admin_panel_settings, label: 'Admin', page: (p) => AdminPage(phoneNumber: p)),
    SettingsItem(icon: Icons.phone, label: 'Ph No.', page: (p) => PhoneNumberSet(phoneNumber: p)),
    SettingsItem(icon: Icons.message, label: 'Message', page: (p) => MessageSet(phoneNumber: p)),
    SettingsItem(icon: Icons.notifications, label: 'Alert', page: (p) => AlertPage(phoneNumber: p)),
    SettingsItem(icon: Icons.layers, label: 'Zones', page: (p) => ZoneSetPage(phoneNumber: p)),
    SettingsItem(icon: Icons.refresh, label: 'Reset', page: (p) => ResetPage(phoneNumber: p)),
    SettingsItem(icon: Icons.notification_important, label: 'Alert Opt.', page: (p) => AlertOption(phoneNumber: p)),
    SettingsItem(icon: Icons.mic, label: 'Voice Rec.', page: (p) => VoiceRecordPage(phoneNumber: p)),
  ];

  final List<StatusItem> status = [
    StatusItem(icon: Icons.phone_android, label: 'Ph No.', page: (p) => PhoneNumberGet(phoneNumber: p)),
    StatusItem(icon: Icons.message, label: 'Message', page: (p) => MessageGet(phoneNumber: p)),
    StatusItem(icon: Icons.device_hub, label: 'Status', page: (p) => StatusPage(phoneNumber: p)),
    StatusItem(icon: Icons.verified_user, label: 'Version', page: (p) => VersionPage(phoneNumber: p)),
    StatusItem(icon: Icons.help_outline, label: 'Help', page: (_) => HelpPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        centerTitle: true,
        backgroundColor: _primarySwatch.shade700,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Settings", Icons.settings),
            const SizedBox(height: 10),
            _buildGrid(context, settings.map((s) => _buildTile(context, s.icon, s.label, s.page)).toList()),
            const SizedBox(height: 30),
            _buildSectionHeader("Status", Icons.info),
            const SizedBox(height: 10),
            _buildGrid(context, status.map((s) => _buildTile(context, s.icon, s.label, s.page)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(device.deviceName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(device.phoneNumber, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primarySwatch.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primarySwatch.shade700),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<Widget> tiles) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: tiles,
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String label, Function(String) pageBuilder) {
    return Material(
      color: _primarySwatch.shade50,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => pageBuilder(device.phoneNumber)));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _primarySwatch.shade100,
                child: Icon(icon, color: _primarySwatch.shade700, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
