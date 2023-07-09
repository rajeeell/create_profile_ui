import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_auth_rest_api/api_constants.dart';
import 'package:flutter_auth_rest_api/helper.dart';
import 'package:flutter_auth_rest_api/keys.dart';
import 'package:flutter_auth_rest_api/model/api_response.dart';
import 'package:flutter_auth_rest_api/model/auth_error.dart';
import 'package:flutter_auth_rest_api/widgets/auth_button.dart';
import 'package:flutter_auth_rest_api/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { signIn, signUp }

class AuthProvider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  AuthStatus _authStatus = AuthStatus.signUp;
  AuthStatus get authStatus => _authStatus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  setAuthStatus() {
    _authStatus = _authStatus == AuthStatus.signUp
        ? AuthStatus.signIn
        : AuthStatus.signUp;
    notifyListeners();
  }

  bool verifyPassword() {
    if (_authStatus == AuthStatus.signUp) {
      if (passwordController.text == confirmPasswordController.text &&
          passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<bool> isUserAuthenticated() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userData = sharedPreferences.getString("userData");
    if (userData != null) {
      print("data shared from pref:");
      ApiResponce apiResponce = ApiResponce.fromJson(jsonDecode(userData!));
      bool isTokenValid =
          DateTime.now().isBefore(DateTime.parse(apiResponce.expiresIn!));
      if (isTokenValid && apiResponce.idToken!.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  showForgetPasswordDialogBox(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          TextEditingController textEditingController = TextEditingController();
          return AlertDialog(
            title: const Text("Enter your email"),
            content: CustomTextField(
                controller: emailController,
                iconData: Icons.email,
                hintText: "Email"),
            actions: [
              AuthButton(
                  title: "Send password link",
                  onTap: () {
                    forgetPassword(emailController.text);
                  })
            ],
          );
        });
  }

  forgetPassword(String email) async {
    final response = await http.post(Uri.parse(apiConstants.api_ForgetPassword),
        body: jsonEncode({"requestType": "PASSWORD_RESET", "email": email}));
    if (response.statusCode == 200) {
      Keys.snackBar("Password reset email sent");
    } else {
      Keys.snackBar("Error");
    }
  }

  changePassword(String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userData = sharedPreferences.getString("userData");
    ApiResponce apiResponce = ApiResponce.fromJson(jsonDecode(userData!));
    final response = await http.post(Uri.parse(apiConstants.api_ChangePassword),
        body: jsonEncode({
          "idToken": apiResponce.idToken,
          "password": password,
          "returnSecureToken": true
        }
        ));
    print(response.body);
  }

  authenticate() async {
    _isLoading = true;
    notifyListeners();
    //await Future.delayed(Duration(seconds: 2));
    print(verifyPassword());
    if (verifyPassword()) {
      try {
        final response = await http.post(
            Uri.parse(authStatus == AuthStatus.signUp
                ? apiConstants.api_Signup
                : apiConstants.api_SignIn),
            body: jsonEncode({
              "email": emailController.text,
              "password": passwordController.text,
              "returnSecureToken": true
            }));

        if (response.statusCode == 200) {
          ApiResponce apiResponce =
              ApiResponce.fromJson(jsonDecode(response.body));
          print(apiResponce.email);
          print(apiResponce.expiresIn);
          print(apiResponce.idToken);
          print(apiResponce.localId);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(
              "userData", jsonEncode(apiResponce.toJson()));
        } else if (response.statusCode == 400) {
          AuthError authError = AuthError.fromJson(jsonDecode(response.body));
          String error =
              Helper.authErrorHandler(authError.error!.message.toString());
          Keys.snackBar(error);
        } else {
          Keys.snackBar("An error occured");
          print(response.body);
        }
      } catch (error) {
        Keys.snackBar(error.toString());
      }
    } else {
      if (passwordController.text.isEmpty &&
          confirmPasswordController.text.isEmpty) {
        Keys.snackBar("Please enter a password");
      } else {
        Keys.snackBar("Password and confirmed password do no match");
      }
    }
    _isLoading = false;
    notifyListeners();
  }
}
