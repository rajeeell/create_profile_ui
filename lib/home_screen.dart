import 'package:flutter/material.dart';
import 'package:flutter_auth_rest_api/update_user_data_provider.dart';
import 'package:flutter_auth_rest_api/widgets/auth_button.dart';
import 'package:flutter_auth_rest_api/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateUserDataProvider>(builder: (context, provider, _) {
      return Scaffold(
        appBar: AppBar(title: const Text("Update Profile data")),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: provider.changePasswordController,
                hintText: "Password",
                iconData: Icons.password,
              ),
              AuthButton(
                title: "Change password",
                onTap: provider.changePassword,
              ),
              const Divider(),
              CustomTextField(
                  controller: provider.userNameController,
                  iconData: Icons.person,
                  hintText: "Username"),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: provider.loadImage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [Text("Load image"), Icon(Icons.add)],
                ),
              ),
              if (provider.photoUrl.isNotEmpty)
                Image.network(provider.photoUrl, height: 100),
              AuthButton(onTap: provider.updateData, title: "Update info"),
              const Divider(),
              AuthButton(
                  title: "Log Out",
                  onTap: () {
                    provider.logOut(context);
                  }),
            ],
          ),
        ),
      );
    });
  }
}
