//lib/pages/version
import 'package:flutter/material.dart';

class Version extends StatefulWidget {
  @override
  _PhNoPageState createState() => _PhNoPageState();
}

class _PhNoPageState extends State<Version> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Number Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone Number Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Here you can set or update the phone number.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Form to input phone number
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Enter Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _savePhoneNumber(context);
                }
              },
              child: Text('Save Phone Number'),
            ),
          ],
        ),
      ),
    );
  }

  // Save the phone number and show a confirmation dialog
  void _savePhoneNumber(BuildContext context) {
    // In a real app, you would save the phone number to your data source (e.g., database, shared preferences)

    String phoneNumber = _phoneController.text;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Phone Number Saved'),
          content: Text('Your phone number $phoneNumber has been saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Optionally pop back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
