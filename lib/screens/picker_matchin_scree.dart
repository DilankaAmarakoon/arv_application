import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/Models/picker_machine_product.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/providers/notification_state_provider.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import 'package:staff_mangement/widgets/profile_section_drawer.dart';
import 'package:staff_mangement/widgets/filler_cart_container.dart';
import '../widgets/details_dragable_sheet.dart';
import '../widgets/location_dragable_sheet.dart';
import '../widgets/picker_product_cart.dart';
import '../widgets/picker_matchin_cart.dart';
import '../widgets/service_sts_dragable_sheet.dart';

class PickerMatchinScreen extends StatefulWidget {
  final List<PickerMachineProductModel> pickerMachineProductList;
   PickerMatchinScreen({super.key,required this.pickerMachineProductList});

  @override
  State<PickerMatchinScreen> createState() => _PickerMatchinScreenState();
}

class _PickerMatchinScreenState extends State<PickerMatchinScreen> {
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
                  itemCount: widget.pickerMachineProductList.length,
                  itemBuilder: (BuildContext context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: PickerCardContainer(
                                        productName: widget.pickerMachineProductList[index].displayName,
                                      ),
                                    );
                  },
              ),
            ),
          ),
        ));
  }
}
