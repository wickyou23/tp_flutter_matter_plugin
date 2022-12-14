import 'package:tp_flutter_matter_package/models/tp_device.dart';
import 'package:tp_flutter_matter_package/tp_matter_channel_const.dart';

abstract class TPMatterResponse {
  final String deviceId;

  TPMatterResponse(this.deviceId);
}

class TPMatterResponseError extends TPMatterResponse {
  final String errorMessage;
  final TPDeviceErrorType errorType;

  factory TPMatterResponseError.unknown() =>
      TPMatterResponseError('', TPDeviceErrorType.kTPControlUnknowError, '');

  TPMatterResponseError(super.deviceId, this.errorType, this.errorMessage);
}

class TPMatterResponseSuccess<T> extends TPMatterResponse {
  final T? data;

  TPMatterResponseSuccess(super.deviceId, {this.data});
}

class TPMatterHelper {
  static TPMatterResponse handleControlResponse(Map? response) {
    if (response == null) {
      return TPMatterResponseError.unknown();
    }

    if (response.containsKey(tpSendSuccessKey)) {
      Map successMap = response[tpSendSuccessKey] as Map;
      String deviceId = (successMap['deviceId'] as String?) ?? '';
      if (deviceId.isNotEmpty) {
        return TPMatterResponseSuccess(
          deviceId,
          data: successMap['data'],
        );
      }

      return TPMatterResponseError.unknown();
    } else if (response.containsKey(tpSendErrorKey)) {
      Map errorMap = response[tpSendErrorKey] as Map;
      final deviceId = errorMap['deviceId'] as String? ?? '';
      final errorType = errorMap['errorType'] as int? ?? 0xffffffff;
      final errorMessage = errorMap['errorMessage'] as String? ?? '';
      final deviceEventError = TPMatterResponseError(
          deviceId, TPDeviceErrorType.fromValue(errorType), errorMessage);
      return deviceEventError;
    } else {
      return TPMatterResponseError.unknown();
    }
  }
}
