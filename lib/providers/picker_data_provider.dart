import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mangement/Models/picker_machine_product.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;
import '../Models/machine_pick_list_model.dart';
import '../Models/picker_service_run_model.dart';
import '../static_data.dart';
import 'package:intl/intl.dart';

class PickerDataProvider with ChangeNotifier {
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<PickerServiceRunModel> pickerServiceRunDetails = [];
  List<MachinePickListModel> pickerMachineDetails = [];
  List<PickerMachineProductModel> pickerMachineProductDetails = [];

  Future fetchServiceRunList() async {
    print("formattedDate  $formattedDate");

    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");

      if (userId == null || password == null) return [];

      final pickerServiceRun = await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'service.run',
          'search_read',
          [
            [
              ['planned_date','=', formattedDate]
            ]
          ],
          {
            'fields': ['id', 'name', 'route_id','machine_ids','machine_count'],
          },
        ],
      );

      print("pickerServiceRun: $pickerServiceRun");
      pickerServiceRunDetails =
          pickerServiceRun
              .cast<Map<String, dynamic>>()
              .map((data) => PickerServiceRunModel.fromXmlRpc(data))
              .toList()
              .cast<PickerServiceRunModel>();

      return pickerServiceRunDetails;
    } catch (e) {
      print("❌ Error in fetchMachinePickList: $e");
      return [];
    }
  }
  Future fetchMachinePickList({required String role,required  int serviceRunId}) async {
    print("formattedDate  $formattedDate");
    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");

      if (userId == null || password == null) return [];

      // Second API call - get machine data
      final filtered =  role == 'picker' ?[
        [
          ['service_run_id','=',serviceRunId]
        ],
      ]:[
        [
          ['planned_date', '=', formattedDate],
          ['state', '!=', 'draft'],
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
            'fields': ['id', 'machine_id', 'pick_list_ids','state','planned_date'],
          },
        ],
      );

      print("Machine Pick List new: $machinePickList");
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
      final filtered =  role == 'picker' ?[
        [
          ['id', 'in', machineProductIdsList],
        ],
      ]:[
        [
          ['id', 'in', machineProductIdsList],
          ['picked', '=', true],
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
            'fields': ['id', 'product_id', 'pick_amount', 'picked', 'filled','machine_id'],
          },
        ],
      );

      print("machineProductDatamachineProductData,,,<<$machineProductData");

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

  Future<bool> savePickerMachineProductData(String role, List<int> pickListId) async {

    print("hjj....>${pickListId}");
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
            pickListId,
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

  void updateMachinePickListState(int pickListId, String newState) {
    for (MachinePickListModel item in pickerMachineDetails) {
      if (item.pick_list_id == pickListId) {
        item.state = newState;
        break;
      }
    }
    notifyListeners(); // This will update all listening widgets
  }

}
