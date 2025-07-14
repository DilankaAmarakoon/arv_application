import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;
import '../constants/colors.dart';
import '../constants/static_data.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/auth';

  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 1000);

  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      // }
      return null;
    });
  }

  Future<String?> _signupConfirm(String error, LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  bool isLoginSuccess = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FlutterLogin(
        theme: LoginTheme(
          primaryColor: Colors.white,
          errorColor: Colors.redAccent,
          buttonTheme: LoginButtonTheme(
            backgroundColor: Color(0xFF0A7880),
            splashColor: k2mainColor,
            highlightColor: Colors.black12,
          ),
          cardTheme: CardTheme(color: k2Background),
          inputTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: k1mainColor),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: k2mainColor, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        hideForgotPasswordButton: true,
        title: "ABC Staff ",
        logo: null,
        navigateBackAfterRecovery: true,
        onConfirmRecover: _signupConfirm,
        onConfirmSignup: _signupConfirm,
        loginAfterSignUp: false,
        userValidator: (value) {
          if (value!.isEmpty) {
            return "Enter Valid Email";
          }
          return null;
        },
        passwordValidator: (value) {
          if (value!.isEmpty) {
            return 'Enter Valid Password';
          }
          return null;
        },
        onLogin: (loginData) async {
          debugPrint('Login info');
          debugPrint('Name: ${loginData.name}');
          debugPrint('Password: ${loginData.password}');
          isLoginSuccess = false;

          int userId = await checkUserLogin(
            dbName,
            loginData.name,
            loginData.password,
          );
          debugPrint("User ID: $userId");
          if (userId > 0) {
            isLoginSuccess = true;
            return null;
          } else {
            isLoginSuccess = false;
            debugPrint("ddddddddd");
            return Future.value("Invalid Email or password");
          }
        },
        onSubmitAnimationCompleted: () {
          if (isLoginSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          }
        },
        onRecoverPassword: (name) {
          debugPrint('Recover password info');
          debugPrint('Name: $name');
          return _recoverPassword(name);
        },
      ),
    );
  }

  Future<int> checkUserLogin(
    String dbName,
    String userName,
    String password,
  ) async {
    try {
      final userId = await xml_rpc.call(
        Uri.parse(
          '${baseUrl}xmlrpc/2/common',
        ),
        'login',
        [dbName, userName, password],
      );
      if (userId != false) {
        SharedPreferences preferance = await SharedPreferences.getInstance();
        preferance.setInt("user_Id", userId);
        preferance.setString("password", password);
        return userId;
      }
      return -1;
    } catch (e) {
      return -1; // exception
    }
  }
}

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.all(8.0), child: Text("Log In")),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}
