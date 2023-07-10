import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_rest_api/auth_provider.dart';
import 'package:flutter_auth_rest_api/auth_screen.dart';
import 'package:flutter_auth_rest_api/home_screen.dart';
import 'package:flutter_auth_rest_api/keys.dart';
import 'package:flutter_auth_rest_api/update_user_data_provider.dart';
import 'package:provider/provider.dart';
import 'keys.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_)=> AuthProvider()),
    ChangeNotifierProvider(create: (_)=>UpdateUserDataProvider() )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scaffoldMessengerKey: Keys.scaffoldMessengerKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthProvider>(builder: (context, provider, _) {
        return FutureBuilder(
            future: provider.isUserAuthenticated(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? snapshot.data!
                      ? const HomeScreen()
                      : const AuthScreen()
                  : const Scaffold(
                      body: Center(
                        child: Text("Waiting"),
                      ),
                    );
            });
      }),
    );
  }
}
