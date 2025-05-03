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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  device == null ? 'Add Device' : 'Edit Device',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _deviceNameController,
                  decoration: InputDecoration(
                    labelText: 'Device Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(device == null ? 'Add Device' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    final updatedDeviceName = _deviceNameController.text.trim();
                    final updatedPhoneNumber = _phoneController.text.trim();

                    if (updatedDeviceName.isEmpty || updatedPhoneNumber.isEmpty) return;

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

  void _navigateToDeviceDetails(Device device) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeviceDetailsScreen(device: device)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Manager"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDeviceDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: devices.isEmpty
          ? const Center(
        child: Text(
          "No devices added yet.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.phone_android, color: Colors.blue),
              ),
              title: Text(
                device.deviceName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(device.phoneNumber),
              onTap: () => _navigateToDeviceDetails(device),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _openDeviceDialog(device: device, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDevice(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
