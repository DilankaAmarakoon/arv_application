import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/Models/picker_machine_details_model.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/providers/notification_state_provider.dart';
import 'package:staff_mangement/reusebleWidgets/app_bar_section.dart';
import 'package:staff_mangement/widgets/profile_section_drawer.dart';
import 'package:staff_mangement/widgets/filler_cart_container.dart';
import '../Models/picker_machine_product.dart';
import '../providers/handlle_data_provider.dart';
import '../widgets/details_dragable_sheet.dart';
import '../widgets/location_dragable_sheet.dart';
import '../widgets/picker_product_cart.dart';
import '../widgets/picker_matchin_cart.dart';
import '../widgets/service_sts_dragable_sheet.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
   List<MachineDetailsModel> _machineListFuture = [];

  @override
  void initState() {
    super.initState();
    fetchMachineDetails();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarSection(context),
        endDrawer: Drawer(
          child: Align(
            alignment: Alignment.topCenter,
            child: const ProfileSectionDrawer(),
          ),
        ),
        body: ListView.builder(
          itemCount: _machineListFuture.length,
          itemBuilder: (context, index) {
            final machine = _machineListFuture[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: PickerMatchingCart(
                detailsName: machine.name,
                machineName: machine.machineName,
                route: machine.routeName,
                machineCount: machine.machineCount,
                machineId: machine.id,
              ),
            );
          },
        ),
      ),
    );
  }

  fetchMachineDetails() async {
    try {
      final machineList = await MachineDetailsData().fetchPickerMachineData();
      setState(() {
        _machineListFuture = machineList;
      });
    } catch (e) {
      print("Error fetching machine details: $e");
    }
  }
}

