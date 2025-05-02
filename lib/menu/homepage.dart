import 'package:flutter/material.dart';
import '../models/device.dart';
import 'manupage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _deviceNameController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Device> devices = [];

  void _openDeviceDialog({Device? device, int? index}) {
    _deviceNameController.text = device?.deviceName ?? '';
    _phoneController.text = device?.phoneNumber ?? '';

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
                Text(
                  device == null ? 'ADD DEVICE' : 'EDIT DEVICE',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _deviceNameController,
                  decoration: InputDecoration(labelText: 'Device Name'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final updatedDeviceName = _deviceNameController.text.trim();
                    final updatedPhoneNumber = _phoneController.text.trim();

                    setState(() {
                      if (device == null) {
                        devices.add(Device(deviceName: updatedDeviceName, phoneNumber: updatedPhoneNumber));
                      } else {
                        devices[index!] = Device(deviceName: updatedDeviceName, phoneNumber: updatedPhoneNumber);
                      }
                    });

                    Navigator.pop(context);
                    _deviceNameController.clear();
                    _phoneController.clear();
                  },
                  child: Text(device == null ? 'Add Device' : 'Save Changes'),
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

  // Navigate to DeviceDetailsScreen and pass the device
  void _navigateToDeviceDetails(Device device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailsScreen(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome Screen")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _openDeviceDialog(),
            child: const Text("Add Device"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.deviceName),
                  subtitle: Text(device.phoneNumber),
                  leading: const Icon(Icons.message),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _openDeviceDialog(device: device, index: index)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteDevice(index)),
                    ],
                  ),
                  onTap: () => _navigateToDeviceDetails(device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
