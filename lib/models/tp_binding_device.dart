class TPBindingDevice {
  final int fabricIndex;
  final int deviceId;
  final int endpoint;
  final int cluster;

  TPBindingDevice(
    this.fabricIndex,
    this.deviceId,
    this.endpoint,
    this.cluster,
  );

  factory TPBindingDevice.fromJson(Map json) {
    return TPBindingDevice(
      json['fabricIndex'] as int,
      json['node'] as int,
      json['endpoint'] as int,
      json['cluster'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fabricIndex': fabricIndex,
      'node': deviceId,
      'endpoint': endpoint,
      'cluster': cluster,
    };
  }
}
