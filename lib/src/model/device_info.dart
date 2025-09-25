class DeviceInfo {
  ///platform e.g. android, ios
  final String platform;

  ///App bundle id e.g. com.example.app
  final String bundleId;

  ///Unique device identifier
  final String deviceId;

  ///Name of device
  final String deviceName;

  ///Name of operating system
  final String osName;

  DeviceInfo({
    required this.platform,
    required this.bundleId,
    required this.deviceId,
    required this.deviceName,
    required this.osName,
  });

  Map<String, String> toJson() => {
    'platform': platform,
    'bundleId': bundleId,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'osName': osName,
  };
}
