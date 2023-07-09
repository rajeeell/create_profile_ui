import 'package:flutter/material.dart';
import 'package:flutter_auth_rest_api/auth_provider.dart';
import 'package:flutter_auth_rest_api/widgets/auth_button.dart';
import 'package:flutter_auth_rest_api/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
                controller: authProvider.emailController,
                iconData: Icons.email,
                hintText: "Email"),
            CustomTextField(
                controller: authProvider.passwordController,
                iconData: Icons.key,
                hintText: "Password"),
            if (authProvider.authStatus == AuthStatus.signUp)
              CustomTextField(
                  controller: authProvider.confirmPasswordController,
                  iconData: Icons.key,
                  hintText: "Confirm password"),
            const SizedBox(height: 20),
            AuthButton(
              title: authProvider.authStatus == AuthStatus.signUp
                  ? "Sign Up"
                  : "Sign In",
              onTap: () {
                authProvider.authenticate();
              },
            ),
            TextButton(
              child: const Text("Forget Password"),
              onPressed: () {
                authProvider.showForgetPasswordDialogBox(context);
              },
            ),
            TextButton(
              child: authProvider.authStatus == AuthStatus.signUp
                  ? const Text("Already have an account")
                  : const Text("Create an account"),
              onPressed: () {
                authProvider.setAuthStatus();
              },
            ),
          ],
        ),
      ),
    );
  }
}
