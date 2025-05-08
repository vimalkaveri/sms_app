class Device {
  final String deviceName;
  final String phoneNumber;

  Device({required this.deviceName, required this.phoneNumber});

  // Convert a Device to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'phoneNumber': phoneNumber,
    };
  }

  // Convert a Map (JSON) to a Device
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceName: json['deviceName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
