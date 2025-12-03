import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_qr_scanner/qr_scanner_page.dart';
import 'package:package_ekyc/assets.dart';
import 'package:package_ekyc/base_app/base_app.src.dart';
import 'package:package_ekyc/core/router/app_route.dart';
import 'package:package_ekyc/core/theme/colors.dart';
import 'package:package_ekyc/core/values/dimens.dart';
import 'package:package_ekyc/generated/locales.g.dart';
import 'package:package_ekyc/shares/widgets/form/base_form_login.dart';

import '../../../../shares/shares.src.dart';
import '../qr.src.dart';

part 'qr_view.dart';

class QRNativePage extends BaseGetWidget<QRNativeController> {
  const QRNativePage({super.key});

  @override
  QRNativeController get controller => Get.put(QRNativeController());

  @override
  Widget buildWidgets(BuildContext context) {
    return Scaffold(
        appBar: BackgroundAppBar.buildAppBar(
          "Cung cấp thông tin QR",
          isColorGradient: false,
          leading: true,
          backgroundColor: AppColors.basicWhite,
        ),
        backgroundColor: AppColors.basicWhite,
        body: buildLoadingOverlay(() => _buildBody(controller)));
  }
}
