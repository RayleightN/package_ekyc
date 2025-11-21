part of 'qr_native_page.dart';

Widget _buildBody(QRNativeController controller) {
  return Scaffold(
    backgroundColor: AppColors.basicWhite,
    body: Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Obx(() => controller.isSuccess.value
                  ? const SizedBox()
                  : QrScannerPage(
                      onScanResult: (result) {
                        controller.getData(result);
                      },
                    )),
              Positioned.fill(
                child: CustomPaint(
                  painter: QRScanOverlayPainter(
                    isSquare: true,
                    cutOutBorderRadius: 1,
                    overlayColor: AppColors.basicWhite,
                    borderColor: Colors.white70,
                    borderWidth: 2.0,
                    cornerColor: AppColors.primaryBlue1,
                    cornerLength: 26,
                    cornerStrokeWidth: 4.0,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 0,
                child: SizedBox(
                  width: Get.width,
                  child: const Center(
                    child: TextUtils(
                      text: "Đặt mã QR vào khung để thực hiện xác thực CCCD",
                      availableStyle: StyleEnum.bodyBold,
                      color: AppColors.colorBlack,
                      maxLine: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildInputCCCD(controller),
        _buildListGuild(), // hiển thị dưới cùng
      ],
    ),
  );
}

Widget _buildListGuild() {
  return Container(
    decoration: const BoxDecoration(
      color: AppColors.secondaryCamPastel2,
      borderRadius: BorderRadius.all(Radius.circular(AppDimens.radius10)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextUtils(
          text: "Hướng dẫn:",
          color: AppColors.colorDisable,
          availableStyle: StyleEnum.subBold,
          maxLine: 3,
        ),
        TextUtils(
          text: "Bước 1: Đặt mã QR trên thẻ CCCD vào vị trí khung",
          color: AppColors.colorDisable,
          availableStyle: StyleEnum.bodyRegular,
          maxLine: 3,
        ),
        sdsSB5,
        TextUtils(
          text:
              "Bước 2: Chờ hệ thống định danh và xác thực cho tới khi có thông báo thành công.",
          color: AppColors.colorDisable,
          availableStyle: StyleEnum.bodyRegular,
          maxLine: 3,
        ),
      ],
    ).paddingAll(AppDimens.padding15),
  ).paddingOnly(
    left: AppDimens.padding15,
    right: AppDimens.padding15,
    bottom: AppDimens.padding10,
  );
}

Widget _buildInputCCCD(QRNativeController controller) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      GestureDetector(
        onTap: () {
          Get.bottomSheet(BaseBottomSheet(
            title: "",
            body: Column(
              children: [
                Form(
                  key: controller.formKey,
                  child: BaseFormLogin.buildInputData(
                      title: "Số CCCD",
                      textEditingController: controller.idDocumentController,
                      isLoading: false,
                      hintText: "Nhập số CCCD",
                      textInputType: TextInputType.number,
                      currentNode: FocusNode().obs,
                      errorValidator:
                          LocaleKeys.register_account_errorValidatorCCCD.tr,
                      onValidator: (text) => UtilWidget.validateId(text),
                      fillColor: AppColors.basicWhite.obs,
                      autoFocus: true,
                      onEditingComplete: () {
                        controller.getDataToEnter(
                            controller.idDocumentController.text);
                      }),
                ),
                ButtonUtils.buildButton(
                  LocaleKeys.registerCa_continue.tr,
                  () {
                    controller
                        .getDataToEnter(controller.idDocumentController.text);
                  },
                  // isLoading: isShowLoading,
                  // backgroundColor: AppColors.primaryCam1,
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ).paddingAll(AppDimens.paddingDefault),
              ],
            ),
            noHeader: true,
          )).then((value) => controller.idDocumentController.clear());
        },
        child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  spreadRadius: -3.4,
                  blurRadius: 0.5,
                  offset: Offset(0, -3.5),
                ),
              ],
            ),
            child: SvgPicture.asset(Assets.ASSETS_SVG_ICON_BUTTON_QR_SVG)),
      ),
    ],
  ).paddingSymmetric(horizontal: Get.width / 4);
}

class QRScanOverlayPainter extends CustomPainter {
  QRScanOverlayPainter({
    this.cutOutWidth,
    this.cutOutHeight,
    this.cutOutBorderRadius = 16,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.55),
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.cornerColor,
    this.cornerLength = 28,
    this.cornerStrokeWidth = 4.0,
    this.isSquare = true,
  });

  /// Nếu không truyền, tự tính theo tỉ lệ màn hình
  final double? cutOutWidth;
  final double? cutOutHeight;
  final double cutOutBorderRadius;

  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  final Color? cornerColor;
  final double cornerLength;
  final double cornerStrokeWidth;

  /// Nếu true -> khung vuông; false -> dùng cutOutWidth/Height
  final bool isSquare;

  @override
  void paint(Canvas canvas, Size size) {
    // ===== 1) Tính khung quét ở giữa =====
    final w = cutOutWidth ??
        min(size.width * 0.82, size.height * 0.55); // rộng mặc định
    final h = isSquare
        ? w
        : (cutOutHeight ??
            min(size.height * 0.32, size.width * 0.6)); // cao mặc định

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: w,
      height: h,
    );
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(cutOutBorderRadius));

    // ===== 2) Vẽ overlay tối + khoét lỗ =====
    final overlayPath = Path()..addRect(Offset.zero & size);
    final cutoutPath = Path()..addRRect(rrect);
    final evenOdd =
        Path.combine(PathOperation.difference, overlayPath, cutoutPath);

    final overlayPaint = Paint()..color = overlayColor;
    canvas.drawPath(evenOdd, overlayPaint);

    // ===== 3) Viền khung =====
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, borderPaint);

    // ===== 4) 4 góc nổi bật (tuỳ chọn) =====
    final cColor = cornerColor ?? borderColor;
    final cornerPaint = Paint()
      ..color = cColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerStrokeWidth
      ..strokeCap = StrokeCap.round;

    final l = cornerLength;
    // top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(l, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, l), cornerPaint);
    // top-right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-l, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, l), cornerPaint);
    // bottom-left
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft + Offset(l, 0), cornerPaint);
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft + Offset(0, -l), cornerPaint);
    // bottom-right
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight + Offset(-l, 0), cornerPaint);
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight + Offset(0, -l), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant QRScanOverlayPainter oldDelegate) => true;
}
