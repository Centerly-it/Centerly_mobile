import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();
    // initialization();
  }

  // void initialization() async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   FlutterNativeSplash.remove();
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Login View')));
  }
}
