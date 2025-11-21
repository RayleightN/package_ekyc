import 'package:flutter/material.dart';
import 'package:package_ekyc/base_app/base_app.src.dart';
import 'package:package_ekyc/shares/shares.src.dart';
import 'package:package_ekyc/shares/utils/time/date_utils.dart';

import '../../../../core/router/app_route.dart';
import '../../qr_kyc/controllers/qr_controller.dart';
import '../../qr_kyc/model/qr_user_information.dart';
import 'get_data_qr.dart';

class QRNativeController extends BaseGetxController {
  String? barcodeController;
  String? idIdentity;
  String? information;
  String? informationIdCard;
  final AppController appController = Get.find<AppController>();

  final formKey = GlobalKey<FormState>();
  final idDocumentController = TextEditingController();

  QrUserInformation qrInformationResult = QrUserInformation();

  RxBool isSuccess = false.obs;

  @override
  Future<void> onInit() async {
    showLoadingOverlay();

    hideLoadingOverlay();
    super.onInit();
  }

  void getData(String barcodeScanRes) {
    try {
      qrInformationResult = GetDataQr.instance.getData(barcodeScanRes);
      barcodeController = barcodeScanRes;
      idIdentity = barcodeController?.substring(0, 12);
      information = barcodeController?.substring(13);
      List<String> splitStrings = information?.split("|") ?? [];
      if (splitStrings.isNotEmpty) {
        DateTime? dateTimeDob = _convertDatetimeQr(splitStrings[2]);
        DateTime? dateTimeDor = _convertDatetimeQr(splitStrings[5]);
        appController.qrUserInformation.documentNumber = idIdentity;
        appController.qrUserInformation.dateOfBirth =
            convertDateToString(dateTimeDob, pattern1);
        appController.qrUserInformation.dateOfIssuer =
            convertDateToString(dateTimeDor, pattern1);
        appController.qrUserInformation.dateOfExpiry = convertDateToString(
          calculateExpiryDate(dateTimeDob, dateTimeDor),
          pattern1,
        );
        appController.qrUserInformation.fullName = splitStrings[1];
        appController.qrUserInformation.gender = splitStrings[3];
        appController.qrUserInformation.address = splitStrings[4];
        appController.qrUserInformation.informationIdCard = splitStrings[0];
        isSuccess.value = true;
        Get.toNamed(AppRoutes.routeScanNfcKyc);
        return;
      }
    } catch (e) {
      showFlushNoti(
        "QR không hợp lệ",
        type: FlushBarType.error,
      );
      hideLoadingOverlay();
    }
  }

  void getDataToEnter(String text) {
    if (formKey.currentState?.validate() ?? false) {
      appController.qrUserInformation.documentNumber = text;
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      Get.toNamed(AppRoutes.routeScanNfcKyc);
    }
  }
}

DateTime? _convertDatetimeQr(String dateString) {
  if (dateString.length == 8) {
    int day = int.parse(dateString.substring(0, 2));
    int month = int.parse(dateString.substring(2, 4));
    int year = int.parse(dateString.substring(4, 8));

    return DateTime(year, month, day);
  }
  return null;
}
