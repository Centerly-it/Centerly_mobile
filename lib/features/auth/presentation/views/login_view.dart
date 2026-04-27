import 'package:centrally/core/res/assets_manager.dart';
import 'package:centrally/core/res/color_manager.dart';
import 'package:centrally/core/res/style_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidht = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorManager.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidht * 0.045),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                AssetsManager.centerlyLogo,
                height: screenHeight * 0.35,
                width: screenWidht * 0.5,
              ),

              Text(tr('welcome_back'), style: StyleManager.head3Bold(context)),
              const SizedBox(height: 12),
              Text(
                tr('login_subtitle'),
                style: StyleManager.bodyRegular(context),
              ),
              const SizedBox(height: 32),
              Text(
                tr('identifier_label'),
                style: StyleManager.bodyMeduim(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
