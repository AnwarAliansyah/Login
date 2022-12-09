import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:mlijo/data/api/api_client.dart';
import 'package:mlijo/model/sign/sign_up_model.dart';
import 'package:mlijo/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({
    required this.apiClient,
    required this.sharedPreferences,
  });

  Future<Response> registration(SignUpBody signUpBody) async {
    return await apiClient.postData(
        AppConstans.REGISTRATION_URI, signUpBody.toJson());
  }

  bool userLoggedIn() {
    return sharedPreferences.containsKey(AppConstans.TOKEN);
  }

  Future<Response> login(String wa, String password) async {
    return await apiClient
        .postData(AppConstans.LOGIN_URI, {"wa": wa, "password": password});
  }

  Future<bool> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(token);
    return await sharedPreferences.setString(AppConstans.TOKEN, token);
  }

  Future<void> saveUserNumberAndPassword(String wa, String password) async {
    try {
      await sharedPreferences.setString(AppConstans.NUMBER, wa);
      await sharedPreferences.setString(AppConstans.PASSWORD, password);
    } catch (e) {
      throw e;
    }
  }

  Future<Response> updateToken() async {
    String? _deviceToken;

    if (GetPlatform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _deviceToken = await _saveDeviceToken();
      }
    } else {
      _deviceToken = await _saveDeviceToken();
      print(_deviceToken);
    }

    return await apiClient.postData(AppConstans.TOKEN_URI,
        {"_method": "put", "cm_firebase_token": _deviceToken});
  }

  Future<String?> _saveDeviceToken() async {
    String? _deviceToken = '@';
    if (!GetPlatform.isWeb) {
      try {
        FirebaseMessaging.instance.requestPermission();
        _deviceToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print(e);
      }
    }

    if (_deviceToken != null) {
      print("Device token = " + _deviceToken);
    }

    return _deviceToken;
  }

  bool clearSharedData() {
    sharedPreferences.remove(AppConstans.TOKEN);
    sharedPreferences.remove(AppConstans.PASSWORD);
    sharedPreferences.remove(AppConstans.NUMBER);
    apiClient.token = "";
    apiClient.updateHeader("");
    return true;
  }
}
