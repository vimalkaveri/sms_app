import 'package:flutter/material.dart';
import 'manupage.dart'; // Import DeviceDetailsScreen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _deviceNameController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Map<String, String>> devices = [];

  void _addDevice() {
    final deviceName = _deviceNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (deviceName.isEmpty || phoneNumber.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please fill out both fields."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      devices.add({'deviceName': deviceName, 'phoneNumber': phoneNumber});
    });

    // Clear the input fields after adding the device
    _deviceNameController.clear();
    _phoneController.clear();

    Navigator.pop(context);
  }

  void _navigateToAdminPage(Map<String, String> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailsScreen(device: device),
      ),
    );
  }

  void _editDevice(int index) {
    final device = devices[index];
    _deviceNameController.text = device['deviceName']!;
    _phoneController.text = device['phoneNumber']!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('EDIT DEVICE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 20),
                TextField(controller: _deviceNameController, decoration: InputDecoration(labelText: 'Device Name')),
                const SizedBox(height: 20),
                TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final updatedDeviceName = _deviceNameController.text.trim();
                    final updatedPhoneNumber = _phoneController.text.trim();
                    setState(() {
                      devices[index] = {'deviceName': updatedDeviceName, 'phoneNumber': updatedPhoneNumber};
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteDevice(int index) {
    setState(() {
      devices.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome Screen")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('ADD DEVICE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 20),
                          TextField(controller: _deviceNameController, decoration: InputDecoration(labelText: 'Device Name')),
                          const SizedBox(height: 20),
                          TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
                          const SizedBox(height: 20),
                          ElevatedButton(onPressed: _addDevice, child: const Text('Add Device')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Text("Add Device"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device['deviceName']!),
                  subtitle: Text('${device['phoneNumber']}'),
                  leading: Icon(Icons.message),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => _editDevice(index)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteDevice(index)),
                    ],
                  ),
                  onTap: () => _navigateToAdminPage(device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
