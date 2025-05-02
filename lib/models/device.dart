class Device {
  String deviceName;
  String phoneNumber;

  Device({required this.deviceName, required this.phoneNumber});

  Map<String, String> toMap() {
    return {
      'deviceName': deviceName,
      'phoneNumber': phoneNumber,
    };
  }

  factory Device.fromMap(Map<String, String> map) {
    return Device(
      deviceName: map['deviceName']!,
      phoneNumber: map['phoneNumber']!,
    );
  }
}
