import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/notificationHandle/firbase_notification.dart';
import 'package:staff_mangement/providers/notification_state_provider.dart';
import 'package:staff_mangement/screens/dashboard_screen.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoggedIn = false; // renamed for clarity

  @override
  void initState() {
    super.initState();
    _checkUserAlreadyLoggedOrNot();
    NotificationServices().initializing(
      Provider.of<NotificationStateProvider>(context, listen: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoggedIn ? Dashboard() : SimpleLoginScreen(),
    );
  }

  void _checkUserAlreadyLoggedOrNot() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? id = pref.getInt("user_Id");
    if (id != null && id > 0) {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }
}
