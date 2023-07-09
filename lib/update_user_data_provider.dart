import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_rest_api/api_constants.dart';
import 'package:flutter_auth_rest_api/keys.dart';
import 'package:flutter_auth_rest_api/model/auth_error.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'model/api_response.dart';

class UpdateUserDataProvider extends ChangeNotifier {
  TextEditingController userNameController = TextEditingController();
  TextEditingController changePasswordController = TextEditingController();
  String photoUrl = "";
  late File file;

  loadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    print(image!.path);
    file = File(image.path);
    final firebaseImage = await FirebaseStorage.instance
        .ref("user_images")
        .child(image.name)
        .putFile(file);
    photoUrl = await firebaseImage.ref.getDownloadURL();
    notifyListeners();
  }

  updateData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userData = sharedPreferences.getString("userData");
    if (userData != null) {
      ApiResponce apiResponse = ApiResponce.fromJson(jsonDecode(userData));

      final response =
          await http.post(Uri.parse(apiConstants.apiUpdateUserDate),
              body: jsonEncode({
                "idToken": apiResponse.idToken,
                "displayName": userNameController.text,
                "photoUrl": photoUrl,
                "returnSecureToken": true
              }));
      print(response.body);
    }
  }

  changePassword() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userData = sharedPreferences.getString("userData");
    ApiResponce apiResponseLocal = ApiResponce.fromJson(jsonDecode(userData!));

    final response = await http.post(
      Uri.parse(ApiResponce.apiChangePassword),
      body: jsonEncode({
        "idToken": apiResponseLocal.idToken,
        "password": changePasswordController.text,
        "returnSecureToken": true
      }),
    );
    if (response.statusCode == 200) {
      ApiResponce apiResponse = ApiResponce.fromJson(jsonDecode(response.body));
      apiResponse.expiresIn = DateTime.now()
          .add(Duration(seconds: int.parse(apiResponse.expiresIn!)))
          .toIso8601String();

      sharedPreferences.setString("userData", jsonEncode(apiResponse.toJson()));

      ApiResponce _response = ApiResponce.fromJson(jsonDecode(response.body));
      Keys.snackBar("Password change successfully",false);

    } else {
      AuthError authError = AuthError.fromJson(jsonDecode(response.body));
      print(authError.error!.message);
      Keys.snackBar(authError.error!.message.toString(),true);
    }
  }
}
