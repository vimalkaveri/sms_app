//lib/pages/alertoption
import 'package:flutter/material.dart';

class AlertOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Settings Page',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Here, you can manage admin-related settings such as system configurations, user management, etc.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // You can add your logic to save settings or perform actions
                _showConfirmationDialog(context);
              },
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  // Sample confirmation dialog when saving settings
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to save the changes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement saving logic here
                Navigator.of(context).pop(); // Close dialog
                _showSuccessDialog(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog after saving
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Settings have been saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
