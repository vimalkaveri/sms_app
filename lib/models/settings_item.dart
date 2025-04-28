// lib/models/settings_item.dart
import 'package:flutter/material.dart';

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
