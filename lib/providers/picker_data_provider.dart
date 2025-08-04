import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mangement/Models/hr_employee_model.dart';
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
  List<DropDownModel> hrEmployeeData = [];

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
          ['service_run_id','=',serviceRunId],
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
            'fields': ['id', 'machine_id', 'pick_list_ids','state','planned_date','filler_employee_id','basket_no'],
          },
        ],
      );
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
    List<dynamic> lk  =[
      {"name":"951316"},
      {"name":"951311"},
      {"name":"937918"},
      {"name":"928732"},
      {"name":"927257"},
      {"name":"921788"},
      {"name":"951316"},
      {"name":"951311"},
      {"name":"937918"},
    ];
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
            'fields': ['id', 'product_id', 'pick_amount', 'picked', 'filled','machine_id','barcode'],
          },
        ],
      );

      // if(role == "picker"){
      //   print("ssdffffffff");
      //   for(int i =0; i< lk.length; i++){
      //     machineProductData[i]["barcode"] = lk[i]["name"];
      //   }
      // }


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
  Future fetchHrEmployeeDataData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");
      if (userId == null || password == null) return [];
      final hrEmployeeDataSet = await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'hr.employee',
          'search_read',
          [[]],
          {
            'fields': ['id','name'],
          },
        ],
      );
      hrEmployeeData =
          hrEmployeeDataSet.cast<Map<String, dynamic>>()
              .map((data) => DropDownModel.fromXmlRpc(data))
              .toList()
              .cast<DropDownModel>();

      return hrEmployeeData;
    } catch (e) {
      print("❌ Error in hrEmployee: $e");
      return [];
    }
  }

  Future<bool> savePickerMachineProductData(String role, List<int> pickListId, Map requiredData) async {
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
      print("requiredData,,..$requiredData");

      Map<String, dynamic> finalRequiredData = {};
      finalRequiredData["state"] = role == "picker" ? "picked" : "filled";

      // Add requiredData only if role is not "picker"
      if (role != "picker") {
        print("🔍 Final required data: $requiredData");
        // Clean and add requiredData fields
      }
      print("🔍 Final required data: $finalRequiredData");
      if (role != "picker") {
        // Create attachments from the base64 image data
        List<int> createdAttachmentIds = [];
        for(int i = 0; i < requiredData["filler_attachment_ids"].length; i++) {
          String base64ImageData = requiredData["filler_attachment_ids"][i];
          try {
            var result = await xml_rpc.call(
              Uri.parse("$baseUrl/xmlrpc/2/object"),
              'execute_kw',
              [
                dbName,
                userId,
                password,
                'ir.attachment',
                'create',
                [
                  {
                    'name': 'Filler_Photo_${DateTime.now().millisecondsSinceEpoch}_${i + 1}.jpg',
                    'res_model': 'machine.pick.list',
                    'res_id': requiredData["machineId"],
                    'datas': base64ImageData,
                    'mimetype': 'image/jpeg',
                    'type': 'binary',
                  }
                ],
              ],
            );

            if (result != null && result is int) {
              createdAttachmentIds.add(result);
              print("✅ Created attachment with ID: $result");
            }
          } catch (e) {
            print("❌ Error creating attachment $i: $e");
          }
        }
        print("✅ Created createdAttachmentIds with ID: $createdAttachmentIds");

        // Update requiredData with the created attachment IDs
        requiredData["filler_attachment_ids"] = createdAttachmentIds;

        requiredData.forEach((key, value) {
          if (value != null && key != "machineId") {
            if (value is String || value is int || value is double || value is bool) {
              finalRequiredData[key] = value;
            } else if (value is DateTime) {
              finalRequiredData[key] = value.toIso8601String();
            } else if (value is List && key == "filler_attachment_ids") {
              // Keep attachment IDs as a list, don't convert to string
              finalRequiredData[key] = value; // Keep as List<int>
            } else if (value is List) {
              finalRequiredData[key] = value.join(',');
            } else {
              finalRequiredData[key] = value.toString();
            }
          }
        });
      }
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
            finalRequiredData
          ],
        ],
      );

      return true;
    } catch (e) {
      print("❌ Error in savePickerMachineProductData: $e");
      return false;
    }
  }
  Future<bool> saveBasketNumbersData(pickListId, basketNumbers) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");

      if (userId == null || password == null) {
        print("❌ Missing user credentials");
        return false;
      }

      // 🔍 DEBUG: Print the pickListId being sent
      print("🔍 Attempting to update pickListId: $pickListId");
      print("🔍 Basket numbers: $basketNumbers");

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
            {"basket_no": basketNumbers}
          ],
        ],
      );
      return true;
    } catch (e) {
      print("❌ Error in savePickerMachineProductData: $e");
      print("❌ Failed pickListId: $pickListId");
      return false;
    }
  }
  Future saveServiceRunPickerForm(requiredData,serviceRunId) async {
    print("formattedDate  $formattedDate");

    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");

      if (userId == null || password == null) return [];

      await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'service.run',
          'write',
          [
            [serviceRunId],
            requiredData
          ],
        ],
      );
    } catch (e) {
      print("❌ Error in fetchMachinePickList: $e");
      return [];
    }
  }
  void updateMachinePickListState(List pickListId, String newState) {
    for (MachinePickListModel item in pickerMachineDetails) {
      for(int i =0; i<pickListId.length;i++){
        if (item.pick_list_id == pickListId[i]) {
          item.state = newState;
          break;
        }
      }
    }
    notifyListeners(); // This will update all listening widgets
  }

}
