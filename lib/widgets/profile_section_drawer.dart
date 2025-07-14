import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mangement/constants/colors.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/reusebleWidgets/action_btn.dart';
import 'package:staff_mangement/screens/login_screen.dart';

class ProfileSectionDrawer extends StatefulWidget {
  const ProfileSectionDrawer({super.key});

  @override
  State<ProfileSectionDrawer> createState() => _ProfileSectionDrawerState();
}

class _ProfileSectionDrawerState extends State<ProfileSectionDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: k2Background,
      width: 500,
      child: Padding(
        padding: mainPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("SDSDSD"),
            Text("SDSDSD"),
            Text("SDSDSD"),
            Text("SDSDSD"),
            Spacer(),
            ActionBtn(
              lable: "LOG OUT",
              onPressed: () async {
                SharedPreferences preference =
                    await SharedPreferences.getInstance();
                preference.clear();
                navigateBackLoginScree();
              },
              width: 100,
            ),
          ],
        ),
      ),
    );
  }

  navigateBackLoginScree() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
