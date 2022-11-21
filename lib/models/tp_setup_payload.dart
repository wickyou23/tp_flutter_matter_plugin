enum TPCommissioningFlow {
  kCommissioningFlowStandard(0),
  kCommissioningFlowUserActionRequired(1),
  kCommissioningFlowCustom(2),
  kCommissioningFlowInvalid(3);

  factory TPCommissioningFlow.fromValue(int? value) {
    switch (value) {
      case 0:
        return kCommissioningFlowStandard;
      case 1:
        return kCommissioningFlowUserActionRequired;
      case 2:
        return kCommissioningFlowCustom;
      default:
        return kCommissioningFlowInvalid;
    }
  }

  const TPCommissioningFlow(this.value);
  final int value;
}

enum TPDiscoveryCapabilities {
  kDiscoveryCapabilitiesUnknown(0),
  kDiscoveryCapabilitiesSoftAP(1 << 0),
  kDiscoveryCapabilitiesBLE(1 << 1),
  kDiscoveryCapabilitiesOnNetwork(1 << 2);

  const TPDiscoveryCapabilities(this.value);
  final int value;
}

class TPSetupPlayload {
  final int version;
  final int vendorId;
  final String productId;
  final int discriminator;
  final bool hasShortDiscriminator;
  final String setupPasscode;
  final TPCommissioningFlow commissioningFlow;
  final Set<TPDiscoveryCapabilities> discoveryCapabilities;

  TPSetupPlayload(
      this.version,
      this.vendorId,
      this.productId,
      this.discriminator,
      this.hasShortDiscriminator,
      this.setupPasscode,
      this.commissioningFlow,
      this.discoveryCapabilities);

  factory TPSetupPlayload.fromJson(Map json) {
    final discoveryCapabilitiesValue =
        json['discoveryCapabilities'] as int? ?? 0;
    final discoveryCapabilitiesList = <TPDiscoveryCapabilities>{};
    for (var element in TPDiscoveryCapabilities.values) {
      if (discoveryCapabilitiesValue & element.value == element.value) {
        discoveryCapabilitiesList.add(element);
      }
    }

    return TPSetupPlayload(
        json['version'] as int? ?? -1,
        json['vendorId'] as int? ?? -1,
        json['productID'] as String? ?? '',
        json['discriminator'] as int? ?? -1,
        json['hasShortDiscriminator'] as bool? ?? false,
        json['setupPasscode'] as String? ?? '',
        TPCommissioningFlow.fromValue(json['commissioningFlow'] as int?),
        discoveryCapabilitiesList);
  }
}
