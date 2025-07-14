import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/providers/notification_state_provider.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import 'package:staff_mangement/widgets/profile_section_drawer.dart';
import 'package:staff_mangement/widgets/filler_cart_container.dart';
import '../widgets/details_dragable_sheet.dart';
import '../widgets/location_dragable_sheet.dart';
import '../widgets/service_sts_dragable_sheet.dart';

class FillerScreen extends StatefulWidget {
  const FillerScreen({super.key});

  @override
  State<FillerScreen> createState() => _FillerScreenState();
}

class _FillerScreenState extends State<FillerScreen> {
  @override
  Widget build(BuildContext context) {
    LocationDragableSheet locationSheet = LocationDragableSheet();
    DetailsDragableSheet detailSheet = DetailsDragableSheet();
    ServiceStatusDragableSheet serviceStatusSheet =
        ServiceStatusDragableSheet();
    return SafeArea(
      child: Scaffold(
        appBar: appBarSection(context),
        endDrawer: Drawer(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(child: ProfileSectionDrawer()),
          ),
        ),
        body: Padding(
          padding: mainPadding,
          child: RefreshIndicator(
            onRefresh: () async {
              Future<void>.delayed(const Duration(seconds: 3));
              Provider.of<NotificationStateProvider>(
                context,
                listen: false,
              ).fetchNotificationCount(0);
            },
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: FillerCardContainer(
                    onTapFillerDetails: () {
                      detailSheet.openDraggableSheet(context);
                    },
                    onTapFillerServiceSts: () {
                      serviceStatusSheet.openDraggableSheet(context);
                    },
                    onTapFilletLocation: () {
                      locationSheet.openDraggableSheet(context);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
