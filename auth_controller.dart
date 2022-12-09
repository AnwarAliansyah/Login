import 'package:get/get.dart';
import 'package:mlijo/data/repositories/sign/auth_repo.dart';
import 'package:mlijo/model/sign/response_model.dart';
import 'package:mlijo/model/sign/sign_up_model.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;

  AuthController({
    required this.authRepo,
  });

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<ResponseModel> registration(SignUpBody signUpBody) async {
    _isLoaded = true;
    update();
    Response response = await authRepo.registration(signUpBody);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(response.body["token"]);
      responseModel = ResponseModel(true, response.body["token"]);
      _isLoaded = false;
    } else {
      List<dynamic> errors = response.body["errors"];
      String errmsg = "";

      errors.forEach((key) {
        if (errors.length == 1) {
          if (key["code"] == "wa") {
            errmsg = "Nomor anda sudah digunakan";
          } else if (key["code"] == "email") {
            errmsg = "Email anda sudah digunakan";
          } else {
            errmsg =
                "Tidak berhasil membuat akun, mohon periksa kembali form registrasi";
          }
        } else {
          errmsg = "Nomor dan email anda sudah digunakan";
        }
      });

      responseModel = ResponseModel(false, errmsg);

      _isLoaded = false;
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> login(String wa, String password) async {
    _isLoaded = true;
    update();
    Response response = await authRepo.login(wa, password);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(response.body["token"]);
      responseModel = ResponseModel(true, response.body["token"]);
      _isLoaded = false;
    } else {
      responseModel = ResponseModel(false, response.statusText!);
      _isLoaded = false;
    }
    update();
    return responseModel;
  }

  void saveUserNumberAndPassword(String wa, String password) {
    authRepo.saveUserNumberAndPassword(wa, password);
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  bool userLoggedIn() {
    return authRepo.userLoggedIn();
  }

  bool clearSharedData() {
    return authRepo.clearSharedData();
  }
}
