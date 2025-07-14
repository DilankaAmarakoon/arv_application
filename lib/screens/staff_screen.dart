import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:staff_mangement/Models/staff_task_data_model.dart';
import 'package:staff_mangement/constants/colors.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import 'package:staff_mangement/screens/staff_details.dart';
import 'package:staff_mangement/widgets/profile_section_drawer.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  StaffTaskDataList staffTaskDataList = StaffTaskDataList();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    callStaffData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarSection(context),
        endDrawer: Drawer(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(child: ProfileSectionDrawer()),
          ),
        ),
        body: isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: k1mainColor,
                size: 30,
              ),
              SizedBox(height: 16),
            ],
          ),
        )
            : Padding(
          padding: mainPadding,
          child: ListView.builder(
            itemCount: staffTaskDataList.staffTaskDataList.length,
            itemBuilder: (BuildContext context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: StaffDetails(
                  index: index,
                  dataList: staffTaskDataList.staffTaskDataList[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> callStaffData() async {
    await staffTaskDataList.fetchStaffData(context);
    setState(() {
      isLoading = false;
    });
  }
}
