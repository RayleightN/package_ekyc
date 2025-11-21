import 'package:package_ekyc/assets.dart';
import 'package:package_ekyc/base_app/base_app.src.dart';
import 'package:package_ekyc/const.dart';
import 'package:package_ekyc/core/core.src.dart';
import 'package:package_ekyc/modules/authentication_kyc/nfc_kyc/nfc_kyc.src.dart';

import '../../shares/shares.src.dart';
import 'modules/authentication_kyc/nfc_kyc/nfc_dialog/read_nfc.dart';
import 'modules/authentication_kyc/qr_kyc/qr_kyc.src.dart';
import 'modules/sdk/sdk.src.dart';

class PackageEkyc {
  static Future<SendNfcRequestModel?> readOnlyNFC({
    GuidNFC? guidNFC,
    bool isScanQRNative = false,
  }) async {
    Get.toNamed(AppRoutes.initApp);
    AppController appController = Get.put(AppController());

    appController.isOnlyNFC = true;
    appController.guidNFC = guidNFC;
    appController.isScanQRNative = isScanQRNative;

    Assets.isFromModules = true;
    var result = await appController.checkPermissionApp();
    Get.back();
    Get.delete<AppController>();
    return result;
  }

  static Future<SendNfcRequestModel?> checkEKYC(
    SdkRequestModel sdkRequestModel, {
    QrUserInformation? qrUserInformation,
    GuidNFC? guidNFC,
    bool isScanQRNative = false,
  }) async {
    Get.toNamed(AppRoutes.initApp);
    AppController appController = Get.put(AppController());
    Assets.isFromModules = true;
    appController.sdkModel = sdkRequestModel;
    appController.guidNFC = guidNFC;
    appController.isScanQRNative = isScanQRNative;

    appController.qrUserInformation.documentNumber =
        sdkRequestModel.documentNumber;
    if (qrUserInformation != null) {
      appController.qrUserInformation = qrUserInformation;
    }

    AppConstSDK.apiKey = appController.sdkModel.apiKey;
    var result = await appController.checkPermissionApp();
    Get.back();
    Get.delete<AppController>();
    return result;
  }

  static Future<void> readCCCD({
    required String idDocument,
    required Function(SendNfcRequestModel sendNfcRequestModel) onSuccess,
    String? otherPaper,
    String? residentVMN,
    String? introduceScanNfc1,
    String? introduceScanNfc2,
    String? introduceScanNfc20,
    String? introduceScanNfc40,
    String? introduceScanNfc60,
    String? introduceScanNfc80,
    String? introduceScanNfcSuccess,
    String? introduceScanNfcError,
  }) async {
    await ReadNfc().readCCCD(
      idDocument: idDocument,
      onSuccess: onSuccess,
      otherPaper: otherPaper,
      residentVMN: residentVMN,
      introduceScanNfc1: introduceScanNfc1,
      introduceScanNfc2: introduceScanNfc2,
      introduceScanNfc20: introduceScanNfc20,
      introduceScanNfc40: introduceScanNfc40,
      introduceScanNfc60: introduceScanNfc60,
      introduceScanNfc80: introduceScanNfc80,
      introduceScanNfcSuccess: introduceScanNfcSuccess,
      introduceScanNfcError: introduceScanNfcError,
    );
  }
}
