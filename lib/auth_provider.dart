import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
      ApiResponce apiResponse = ApiResponce.fromJson(jsonDecode(userData!));
      bool isTokenValid =
          DateTime.now().isBefore(DateTime.parse(apiResponse.expiresIn!));
      if (isTokenValid && apiResponse.idToken!.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  authenticate() async {
    _isLoading = true;
    notifyListeners();
    print(verifyPassword());
    if (verifyPassword()) {
      try {
        final response = await http.post(
            Uri.parse(
              _authStatus == AuthStatus.signUp
                  ? apiConstants.api_Signup
                  : apiConstants.api_SignIn,
            ),
            body: jsonEncode({
              "email": emailController.text,
              "password": passwordController.text,
              "returnSecureToken": true,
            }));

        if (response.statusCode == 200) {
          ApiResponce apiResponse =
              ApiResponce.fromJson(jsonDecode(response.body));
          print(apiResponse.email);
          print(apiResponse.expiresIn);
          print(apiResponse.idToken);
          print(apiResponse.localId);
          apiResponse.expiresIn = DateTime.now()
              .add(Duration(seconds: int.parse(apiResponse.expiresIn!)))
              .toIso8601String();
          print(apiResponse.expiresIn);

          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();

          sharedPreferences.setString(
              "userData", jsonEncode(apiResponse.toJson()));
          //operation is success
        } else if (response.statusCode == 400) {
          AuthError authError = AuthError.fromJson(jsonDecode(response.body));
          String error =
              Helper.authErrorHandler(authError.error!.message.toString());
          Keys.snackBar(error, true);
          // operation is failure
        } else {
          Keys.snackBar("Error Occurred", true);
        }
      } catch (error) {
        Keys.snackBar(error.toString(), true);
      }
    } else {
      if (passwordController.text.isEmpty &&
          confirmPasswordController.text.isEmpty) {
        Keys.snackBar("Please enter a password", true);
      } else {
        Keys.snackBar("Password and confirm password does not match", true);
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  showForgetPasswordDialogBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: const Text("Enter your email"),
          content: CustomTextField(
              hintText: "Email",
              iconData: Icons.email,
              controller: emailController),
          actions: [
            AuthButton(
              title: "Send password link",
              onTap: () {
                forgetPassword(emailController.text);
              },
            )
          ],
        );
      },
    );
  }


  forgetPassword(String email) async {
    final response = await http.post(
      Uri.parse(apiConstants.api_ForgetPassword),
      body: jsonEncode({"requestType": "PASSWORD_RESET", "email": email}),
    );
    if (response.statusCode == 200) {
      Keys.snackBar("Password reset Email sent.", false);
    } else {
      Keys.snackBar("Error", true);
    }
  }
}
