import 'package:flutter/material.dart';

import '../models/device.dart';
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

  const DeviceDetailsScreen({super.key, required this.device});

  static const Color primaryColor = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF6F8FC);

  // ---------------------------------------------------------------------------
  // SETTINGS
  // ---------------------------------------------------------------------------

  List<SettingsItem> get settings => [
    SettingsItem(
      icon: Icons.admin_panel_settings_rounded,
      label: 'Admin',
      color: Colors.indigo,
      page: (p) => AdminPage(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.phone_rounded,
      label: 'Ph No.',
      color: Colors.blue,
      page: (p) => PhoneNumberSet(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.message_rounded,
      label: 'Message',
      color: Colors.deepPurple,
      page: (p) => MessageSet(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.notifications_active_rounded,
      label: 'Alert',
      color: Colors.orange,
      page: (p) => AlertPage(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.layers_rounded,
      label: 'Zones',
      color: Colors.teal,
      page: (p) => ZoneSetPage(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.restart_alt_rounded,
      label: 'Reset',
      color: Colors.red,
      page: (p) => ResetPage(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.notification_important_rounded,
      label: 'Alert Opt.',
      color: Colors.amber.shade800,
      page: (p) => AlertOption(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.mic_rounded,
      label: 'Voice Rec.',
      color: Colors.pink,
      page: (p) => VoiceRecordPage(phoneNumber: p),
    ),
  ];

  // ---------------------------------------------------------------------------
  // STATUS
  // ---------------------------------------------------------------------------

  List<SettingsItem> get status => [
    SettingsItem(
      icon: Icons.phone_android_rounded,
      label: 'Ph No.',
      color: Colors.blue,
      page: (p) => PhoneNumberGet(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.message_rounded,
      label: 'Message',
      color: Colors.deepPurple,
      page: (p) => MessageGet(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.device_hub_rounded,
      label: 'Status',
      color: Colors.green,
      page: (p) => StatusPage(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.verified_rounded,
      label: 'Version',
      color: Colors.indigo,
      page: (p) => VersionPage(phoneNumber: p),
    ),
    SettingsItem(
      icon: Icons.help_outline_rounded,
      label: 'Help',
      color: Colors.teal,
      page: (_) => HelpPage(),
    ),
  ];

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void _openPage(BuildContext context, Widget Function(String) pageBuilder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pageBuilder(device.phoneNumber)),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Device Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ---------------------------------------------------------------
          // DEVICE HEADER
          // ---------------------------------------------------------------

          SliverToBoxAdapter(child: _buildDeviceHeader()),

          // ---------------------------------------------------------------
          // SETTINGS HEADER
          // ---------------------------------------------------------------
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'Settings',
              subtitle: 'Configure your device',
              icon: Icons.settings_rounded,
            ),
          ),

          // ---------------------------------------------------------------
          // SETTINGS GRID
          // ---------------------------------------------------------------
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = settings[index];

                return _buildActionCard(context, item);
              }, childCount: settings.length),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 170,
                mainAxisExtent: 142,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),

          // ---------------------------------------------------------------
          // STATUS HEADER
          // ---------------------------------------------------------------
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              title: 'Status',
              subtitle: 'View device information',
              icon: Icons.info_outline_rounded,
            ),
          ),

          // ---------------------------------------------------------------
          // STATUS GRID
          // ---------------------------------------------------------------
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = status[index];

                return _buildActionCard(context, item);
              }, childCount: status.length),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 170,
                mainAxisExtent: 142,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEVICE HEADER
  // ---------------------------------------------------------------------------

  Widget _buildDeviceHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Device icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(width: 16),

          // Device information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connected Device',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  device.deviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        device.phoneNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION CARD
  // ---------------------------------------------------------------------------

  Widget _buildActionCard(BuildContext context, SettingsItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _openPage(context, item.page);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(item.icon, color: item.color, size: 29),
              ),

              const SizedBox(height: 12),

              // Label
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF252525),
                ),
              ),

              const SizedBox(height: 5),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SETTINGS ITEM MODEL
// =============================================================================

class SettingsItem {
  final IconData icon;
  final String label;
  final Color color;
  final Widget Function(String) page;

  const SettingsItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.page,
  });
}
