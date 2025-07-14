import 'package:flutter/material.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import 'package:staff_mangement/screens/dashboard_details.dart';
import '../widgets/profile_section_drawer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarSection(context),
        endDrawer: const Drawer(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(child: ProfileSectionDrawer()),
          ),
        ),
        body: Padding(
          padding: mainPadding,
          child: const Column(
            children: [DashbordDetails()],
          ),
        ),
      ),
    );
  }
}
