import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

abstract class TPDeviceControlResponse {
  final String deviceId;

  TPDeviceControlResponse(this.deviceId);
}

class TPDeviceControlError extends TPDeviceControlResponse {
  final String errorMessage;
  final TPDeviceErrorType errorType;

  factory TPDeviceControlError.unknown() =>
      TPDeviceControlError('', TPDeviceErrorType.kTPControlUnknowError, '');

  TPDeviceControlError(super.deviceId, this.errorType, this.errorMessage);
}

class TPDeviceControlSuccess extends TPDeviceControlResponse {
  TPDeviceControlSuccess(super.deviceId);
}

class TPDeviceControlHelper {
  static TPDeviceControlResponse handleControlResponse(Map? response) {
    if (response == null) {
      return TPDeviceControlError.unknown();
    }

    if (response.containsKey(tpControlSuccessKey)) {
      Map successMap = response[tpControlSuccessKey] as Map;
      String deviceId = (successMap['deviceId'] as String?) ?? '';
      if (deviceId.isNotEmpty) {
        return TPDeviceControlSuccess(deviceId);
      }

      return TPDeviceControlError.unknown();
    } else if (response.containsKey(tpControlErrorKey)) {
      Map errorMap = response[tpControlErrorKey] as Map;
      final deviceId = errorMap['deviceId'] as String? ?? '';
      final errorType = errorMap['errorType'] as int? ?? 0xffffffff;
      final errorMessage = errorMap['errorMessage'] as String? ?? '';
      final deviceEventError = TPDeviceControlError(
          deviceId, TPDeviceErrorType.fromValue(errorType), errorMessage);
      return deviceEventError;
    } else {
      return TPDeviceControlError.unknown();
    }
  }
}
