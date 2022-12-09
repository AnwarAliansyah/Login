import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mlijo/controllers/sign/auth_controller.dart';
import 'package:mlijo/pages/initial/sign/sign_up.dart';
import 'package:mlijo/routes/route_helper.dart';
import 'package:mlijo/show_custom_message.dart';

import 'package:mlijo/utils/app_constants.dart';
import 'package:mlijo/utils/dimensions.dart';
import 'package:mlijo/widgets/big_text.dart';
import 'package:mlijo/widgets/custom_loader.dart';
import 'package:mlijo/widgets/small_text.dart';
import 'package:mlijo/widgets/text_field_container.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var waController = TextEditingController();
    var passwordController = TextEditingController();

    void _login(AuthController authController) {
      String wa = waController.text.trim();
      String password = passwordController.text.trim();

      if (wa.isEmpty) {
        showCustomSnackBar("Masukkan nomor WA anda", title: "Nomor Wa");
      } else if (password.isEmpty) {
        showCustomSnackBar("Masukkan password anda", title: "Password");
      } else if (password.length < 6) {
        showCustomSnackBar("Password anda harus lebih dari 6 karakter",
            title: "Password");
      } else {
        authController.login(wa, password).then((status) {
          if (status.isSuccess) {
            showCustomSnackBar("Berhasil login", title: "Login");

            Get.offNamed(RouteHelper.getHome(0));
          } else {
            showCustomSnackBar("Nomor atau Password yang Anda masukkan salah!",
                title: "Login");
          }
        });
      }
    }

    return SafeArea(
      child: Scaffold(
        body: GetBuilder<AuthController>(
          builder: (authController) {
            return !authController.isLoaded
                ? SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: Dimensions.sH * .4,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.h30,
                          ),
                          child: BigText(
                            text: "Sign In",
                            size: Dimensions.f15 * 2,
                          ),
                        ),
                        SizedBox(height: Dimensions.h40),
                        Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.h30,
                            ),
                            child: Column(
                              children: [
                                TextFieldContainer(
                                    controller: waController,
                                    keyboardType: TextInputType.phone,
                                    hintText: "Nomor",
                                    icon: Icons.whatsapp_outlined),
                                TextFieldContainer(
                                  isObscure: true,
                                  controller: passwordController,
                                  hintText: "Password",
                                  icon: Icons.lock,
                                ),
                              ],
                            )),
                        SizedBox(height: Dimensions.h40),
                        GestureDetector(
                          onTap: () {
                            _login(authController);
                          },
                          child: Center(
                            child: Container(
                              height: Dimensions.h25 * 2,
                              width: Dimensions.w30 * 6,
                              decoration: BoxDecoration(
                                  color: AppConstans.darkestColor,
                                  borderRadius:
                                      BorderRadius.circular(Dimensions.r20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: Dimensions.r5,
                                      offset: Offset(0, 3),
                                    ),
                                  ]),
                              child: Center(
                                child: BigText(
                                  text: "Sign in",
                                  color: Colors.white,
                                  size: Dimensions.f20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Dimensions.h30),
                        Center(
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BigText(
                                  text: "Belum punya akun?",
                                  color: Colors.grey,
                                  size: Dimensions.f15,
                                ),
                                SizedBox(
                                  width: Dimensions.w10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.offNamed(RouteHelper.getSignUp());
                                  },
                                  child: BigText(
                                    text: "Buat Akun",
                                    size: Dimensions.f17,
                                    color: AppConstans.darkestColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomLoader();
          },
        ),
      ),
    );
  }
}
