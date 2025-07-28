import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mangement/Models/picker_machine_product.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;
import '../Models/machine_pick_list_model.dart';
import '../static_data.dart';
import 'package:intl/intl.dart';

class PickerDataProvider with ChangeNotifier {
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<MachinePickListModel> pickerMachineDetails = [];
  List<PickerMachineProductModel> pickerMachineProductDetails = [];

  Future fetchMachinePickList({required String role}) async {
    print("formattedDate  $formattedDate");

    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");

      if (userId == null || password == null) return [];

      // Second API call - get machine data
      final filtered = [
        [
          ['planned_date', '=', "2025-07-27"],
          // ['state', '=', role == 'picker' ? 'draft' : 'picked'],
        ],
      ];
      final machinePickList = await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'machine.pick.list',
          'search_read',
          filtered,
          {
            'fields': ['id', 'machine_id', 'pick_list_ids','state'],
          },
        ],
      );

      print("Machine Pick List: $machinePickList");
      pickerMachineDetails =
          machinePickList
              .cast<Map<String, dynamic>>()
              .map((data) => MachinePickListModel.fromXmlRpc(data))
              .toList()
              .cast<MachinePickListModel>();

      return pickerMachineDetails;
    } catch (e) {
      print("❌ Error in fetchMachinePickList: $e");
      return [];
    }
  }

  Future fetchPickerMachineProductData(String role,List machineProductIdsList) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");
      if (userId == null || password == null) return [];
      final filtered = [
        [
          ['id', 'in', machineProductIdsList],
          ['picked', '=', role == "picker" ? false: true],
        ],
      ];
      final machineProductData = await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'pick.list',
          'search_read',
          filtered,
          {
            'fields': ['id', 'product_id', 'pick_amount', 'picked', 'filled'],
          },
        ],
      );

      print("machineProductDatamm.>${machineProductData}");

      pickerMachineProductDetails =
          machineProductData
              .cast<Map<String, dynamic>>()
              .map((data) => PickerMachineProductModel.fromXmlRpc(data))
              .toList()
              .cast<PickerMachineProductModel>();

      return pickerMachineProductDetails;

      return [];
    } catch (e) {
      print("❌ Error in fetchPickerMachineData: $e");
      return [];
    }
  }

  Future<bool> savePickerMachineProductData(String role, int pickListId) async {
    List<int> pickedAndDFillsIds = pickerMachineProductDetails
        .where((item) =>
    role == "picker" ? item.isPicked == true : item.isFilled == true)
        .map((item) => item.id)
        .whereType<int>()
        .toList();

    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");

      if (userId == null || password == null) {
        print("❌ Missing user credentials");
        return false;
      }

      print("🔍 Starting update process...");
      print("🔍 Picked/Filled IDs: $pickedAndDFillsIds");

      final fieldUpdate =
      role == "picker" ? {"picked": true} : {"filled": true};

      // ✅ CALL pick.list write
      await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'pick.list',
          'write',
          [pickedAndDFillsIds, fieldUpdate],
        ],
      );

      // ✅ CALL machine.pick.list write
      await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'machine.pick.list',
          'write',
          [
            [pickListId],
            role == "picker"
                ? {"state": "picked"}
                : {"state": "filled"},
          ],
        ],
      );

      return true;
    } catch (e) {
      print("❌ Error in savePickerMachineProductData: $e");
      return false;
    }
  }

}
