import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:dmrtd/dmrtd.dart';
import 'package:dmrtd/extensions.dart';
import 'package:package_ekyc/generated/locales.g.dart';
import 'package:package_ekyc/shares/shares.src.dart';
import 'package:dmrtd/src/proto/can_key.dart';

import '../../../../core/values/const.dart';
import '../model/nfc_mrtd_data.dart';
import '../model/nfc_request_model.dart';

class ReadNfc {
  final NfcProvider nfc = NfcProvider();
  RxBool isReading = false.obs;
  RxInt processQuantity = 0.obs;
  Rx<MrtdData>? mrtdData;
  bool isCloseDialog = false;
  SendNfcRequestModel sendNfcRequestModel = SendNfcRequestModel();

  Future<void> readCCCD({
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
    introduceScanNfc1 ??= LocaleKeys.nfc_introduceScanNfc1.tr;
    introduceScanNfc2 ??= LocaleKeys.nfc_introduceScanNfc2.tr;
    introduceScanNfc20 ??= LocaleKeys.nfc_introduceScanNfc4.tr;
    introduceScanNfc40 ??= LocaleKeys.nfc_introduceScanNfc5.tr;
    introduceScanNfc60 ??= LocaleKeys.nfc_introduceScanNfc6.tr;
    introduceScanNfc80 ??= LocaleKeys.nfc_introduceScanNfc7.tr;
    introduceScanNfcSuccess ??= LocaleKeys.nfc_introduceScanNfc8.tr;
    introduceScanNfcError ??= LocaleKeys.nfc_introduceScanNfcError.tr;

    try {
      processQuantity.value = 0;
      await nfc.connect(
          timeout: const Duration(seconds: 10),
          iosAlertMessage: introduceScanNfc1);
      isReading.value = true;
      final passport = Passport(nfc);
      // nfc.setIosAlertMessage(LocaleKeys.nfc_introduceScanNfc2.tr);
      final mrtdDataTemp = MrtdData();
      processQuantity.value = 1;
      await nfc.setIosAlertMessage(formatProgressMsg(introduceScanNfc2, 0));
      print(formatProgressMsg(introduceScanNfc2, 0));

      final accessKey = CanKey(idDocument.substring(6));
      final efCardAccessData = AppConst.key.parseHex();

      EfCardAccess efCardAccess = EfCardAccess.fromBytes(efCardAccessData);
      //PACE session
      await passport.startSessionPACE(accessKey, efCardAccess);

      processQuantity.value = 1;
      await nfc.setIosAlertMessage(formatProgressMsg(introduceScanNfc20, 20));
      print(formatProgressMsg(introduceScanNfc20, 20));
      mrtdDataTemp.com = await passport.readEfCOM();

      if (mrtdDataTemp.com!.dgTags.contains(EfDG1.TAG)) {
        mrtdDataTemp.dg1 = await passport.readEfDG1();
      }
      if (mrtdDataTemp.com!.dgTags.contains(EfDG2.TAG)) {
        mrtdDataTemp.dg2 = await passport.readEfDG2();
      }
      processQuantity.value = 4;

      await nfc.setIosAlertMessage(formatProgressMsg(introduceScanNfc40, 40));
      print(formatProgressMsg(introduceScanNfc40, 40));

      if (mrtdDataTemp.com!.dgTags.contains(EfDG13.TAG)) {
        mrtdDataTemp.dg13 = await passport.readEfDG13();
      }
      if (mrtdDataTemp.com!.dgTags.contains(EfDG14.TAG)) {
        mrtdDataTemp.dg14 = await passport.readEfDG14();
      }

      if (mrtdDataTemp.com!.dgTags.contains(EfDG15.TAG)) {
        mrtdDataTemp.dg15 = await passport.readEfDG15();
        mrtdDataTemp.aaSig = await passport.activeAuthenticate(Uint8List(8));
      }
      sendNfcRequestModel.dg1DataB64 = mrtdDataTemp.dg1?.toBytes().base64();
      sendNfcRequestModel.dg2DataB64 = mrtdDataTemp.dg2?.toBytes().base64();
      sendNfcRequestModel.dg13DataB64 = mrtdDataTemp.dg13?.toBytes().base64();
      sendNfcRequestModel.dg14DataB64 = mrtdDataTemp.dg14?.toBytes().base64();
      sendNfcRequestModel.fileId = "";
      await nfc.setIosAlertMessage(formatProgressMsg(introduceScanNfc60, 60));
      print(formatProgressMsg(introduceScanNfc60, 60));
      processQuantity.value = 6;

      mrtdDataTemp.sod = await passport.readEfSOD();
      sendNfcRequestModel.sodData = mrtdDataTemp.sod?.toBytes().base64();

      mrtdData?.value = mrtdDataTemp;

      sendNfcRequestModel.type = "ID";
      _getDgGlobal(mrtdDataTemp);
      await nfc.setIosAlertMessage(formatProgressMsg(introduceScanNfc80, 80));
      print(formatProgressMsg(introduceScanNfc80, 80));

      sendNfcRequestModel.otherPaper = otherPaper;
      sendNfcRequestModel.mrz = removeSpecialCharacters(
          utf8.decode(mrtdDataTemp.dg1!.toBytes(), allowMalformed: true));

      ///conver Dg13 VNM
      String decodedString =
          utf8.decode(mrtdDataTemp.dg13!.toBytes(), allowMalformed: true);
      String rawData = removeSpecialCharacters(decodedString);
      sendNfcRequestModel.raw = rawData;
      _getDg13VNM(mrtdDataTemp.dg13!.toBytes(), residentVMN);

      processQuantity.value = 10;
      await nfc
          .setIosAlertMessage(formatProgressMsg(introduceScanNfcSuccess, 100));
      print(formatProgressMsg(introduceScanNfcSuccess, 100));

      onSuccess(sendNfcRequestModel);
      await nfc.disconnect();
    } catch (e) {
      if (!isCloseDialog) {
        await nfc.disconnect(iosErrorMessage: introduceScanNfcError);
        print("Lỗi đọc NFC: $e");
        processQuantity.value = 0;
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
      }
    } finally {
      isReading.value = false;
      await nfc.disconnect();
    }
  }

  void _getDgGlobal(MrtdData mrtdDataTemp) {
    sendNfcRequestModel.number =
        mrtdDataTemp.dg1?.mrz.optionalData.substring(0, 12);
    sendNfcRequestModel.name =
        "${mrtdDataTemp.dg1?.mrz.lastName} ${mrtdDataTemp.dg1?.mrz.firstName}";
    sendNfcRequestModel.firstName = mrtdDataTemp.dg1?.mrz.firstName;
    sendNfcRequestModel.lastName = mrtdDataTemp.dg1?.mrz.lastName;
    sendNfcRequestModel.dob = mrtdDataTemp.dg1?.mrz.dateOfBirth.toString();
    sendNfcRequestModel.doe = mrtdDataTemp.dg1?.mrz.dateOfExpiry.toString();
    sendNfcRequestModel.sex = mrtdDataTemp.dg1?.mrz.gender;
    sendNfcRequestModel.nationality = mrtdDataTemp.dg1?.mrz.country;
    sendNfcRequestModel.mrz = removeSpecialCharacters(
        utf8.decode(mrtdDataTemp.dg1!.toBytes(), allowMalformed: true));
    sendNfcRequestModel.file =
        mrtdDataTemp.dg2?.toBytes().base64().substring(112);
    sendNfcRequestModel.aaSignature = mrtdDataTemp.dg14?.toBytes().base64();
    sendNfcRequestModel.aaPublicKey =
        mrtdDataTemp.dg15?.aaPublicKey.toBytes().base64();
    sendNfcRequestModel.keyAlg = mrtdDataTemp.dg15?.aaPublicKey.type.toString();
  }

  void _getDg13VNM(Uint8List byteDg13, String? residentVMN) {
    Uint8List encodedData = Uint8List.fromList(byteDg13);
    ASN1Parser parser = ASN1Parser(encodedData);
    ASN1Object asn1Object = parser.nextObject();
    if (asn1Object is ASN1Sequence) {
      ASN1Sequence sequence = asn1Object;
      String asn1Data = sequence.elements[0].toString();
      RegExp regex = RegExp(r'(UTF8String|PrintableString)\((.*?)\)');
      Iterable<Match> matches = regex.allMatches(asn1Data);
      List<String> listDg13 = [];
      for (Match match in matches) {
        // String stringType = match.group(1)??"";
        String value = match.group(2) ?? "";
        listDg13.add(value);
      }
      if (listDg13.length >= 15) {
        bool isValid(String? value) => value != null && value.isNotEmpty;

        sendNfcRequestModel.numberVMN = listDg13[0];
        sendNfcRequestModel.nameVNM = listDg13[1];
        sendNfcRequestModel.dobVMN = listDg13[2];
        sendNfcRequestModel.sexVMN = listDg13[3];
        sendNfcRequestModel.nationalityVMN = listDg13[4];
        sendNfcRequestModel.nationVNM = listDg13[5];
        sendNfcRequestModel.religionVMN = listDg13[6];
        sendNfcRequestModel.homeTownVMN = listDg13[7];

        String? residentValue = listDg13[8];
        sendNfcRequestModel.residentVMN =
            isValid(residentValue) ? residentValue : (residentVMN ?? "");

        sendNfcRequestModel.identificationSignsVNM = listDg13[9];
        if (listDg13[10].isNotEmpty) {
          sendNfcRequestModel.registrationDateVMN = listDg13[10];
        }
        sendNfcRequestModel.doeVMN = listDg13[11];
        sendNfcRequestModel.nameDadVMN = listDg13[12];
        sendNfcRequestModel.nameMomVMN = listDg13[13];
        if (listDg13.length == 16) {
          if (startsWithNumber(listDg13[14])) {
            sendNfcRequestModel.otherPaper = listDg13[14];
          } else {
            sendNfcRequestModel.nameCouple = listDg13[14];
          }
        } else if (listDg13.length == 17) {
          if (startsWithNumber(listDg13[15])) {
            sendNfcRequestModel.otherPaper = listDg13[15];
            sendNfcRequestModel.nameCouple = listDg13[14];
          } else {
            sendNfcRequestModel.otherPaper = listDg13[14];
            sendNfcRequestModel.nameCouple = listDg13[15];
          }
        }
      }
    }
  }

  bool startsWithNumber(String input) {
    if (input.isEmpty) {
      return false;
    }

    String firstChar = input.substring(0, 1);
    return int.tryParse(firstChar) != null;
  }

  String removeSpecialCharacters(String input) {
    return input.replaceAll(
        RegExp(
            r'[^\w\s\r\f\t,:/-áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴđĐ]'),
        '');
  }
}
