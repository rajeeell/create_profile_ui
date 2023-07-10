import 'package:flutter/material.dart';
import 'package:flutter_auth_rest_api/auth_provider.dart';
import 'package:flutter_auth_rest_api/widgets/auth_button.dart';
import 'package:flutter_auth_rest_api/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: authProvider.emailController,
                hintText: "Email",
                iconData: Icons.email,
              ),
              CustomTextField(
                controller: authProvider.passwordController,
                hintText: "Password",
                iconData: Icons.key,
              ),
              if (authProvider.authStatus == AuthStatus.signUp)
                CustomTextField(
                  controller: authProvider.confirmPasswordController,
                  hintText: "Confirm password",
                  iconData: Icons.key,
                ),
              const SizedBox(
                height: 10,
              ),
              if (!authProvider.isLoading)
                AuthButton(
                  title: authProvider.authStatus == AuthStatus.signUp
                      ? "Sign Up"
                      : "Sign in",
                  onTap: () {
                    authProvider.authenticate();
                  },
                ),
              if (authProvider.isLoading) const CircularProgressIndicator(),
              TextButton(
                child: const Text("Forget Password"),
                onPressed: () {
                  authProvider.showForgetPasswordDialogBox(context);
                },
              ),
              TextButton(
                child: Text(authProvider.authStatus == AuthStatus.signUp
                    ? "Already have and account"
                    : "Create an account"),
                onPressed: () {
                  authProvider.setAuthStatus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
