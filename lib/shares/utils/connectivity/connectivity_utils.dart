import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Hàm trả về Future<bool>:
/// true = Có internet
/// false = Mất mạng
Future<bool> checkNetwork() async {
  bool hasInternet = await InternetConnection().hasInternetAccess;
  return hasInternet;
}