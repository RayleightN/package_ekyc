import 'package:flutter/material.dart';
import 'package:package_ekyc/assets.dart';
import 'package:package_ekyc/base_app/base_app.src.dart';
import 'package:package_ekyc/const.dart';
import 'package:package_ekyc/core/core.src.dart';
import 'package:package_ekyc/modules/authentication_kyc/nfc_kyc/nfc_kyc.src.dart';

import '../../shares/shares.src.dart';
import 'modules/authentication_kyc/qr_kyc/qr_kyc.src.dart';
import 'modules/sdk/sdk.src.dart';

class PackageEkyc {
  static Future<SendNfcRequestModel?> readOnlyNFC({
    GuidNFC? guidNFC,
  }) async {
    Get.toNamed(AppRoutes.initApp);
    AppController appController = Get.put(AppController());

    appController.isOnlyNFC = true;
    appController.guidNFC = guidNFC;

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
    // required GlobalKey<NavigatorState> eKycRouterKey,
    Function(SendNfcRequestModel? kycData)? onSuccess,
  }) async {
    Get.toNamed(AppRoutes.initApp);
    AppController appController = Get.put(AppController());
    Assets.isFromModules = true;
    appController.sdkModel = sdkRequestModel;
    appController.guidNFC = guidNFC;
    appController.onSuccess = onSuccess;
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
}
