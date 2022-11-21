class TPDiscoverDevice {
  final String deviceName;
  final List<String?> ipAddressList;
  final int discriminator;

  TPDiscoverDevice(this.deviceName, this.ipAddressList, this.discriminator);

  factory TPDiscoverDevice.fromJson(Map<String, dynamic> json) =>
      TPDiscoverDevice(
        json["deviceName"] as String,
        (json["ipAddressList"] as List).map((e) => e as String).toList(),
        json["discriminator"] as int,
      );
}
