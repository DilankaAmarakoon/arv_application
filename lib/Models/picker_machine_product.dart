import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class PickerMachineProductModel {
  final int id;
  final int productId;
  final String displayName;

  PickerMachineProductModel({
    required this.id,
    required this.productId,
    required this.displayName,
  });
}

class PickerMachineProductDetailsData {
  Future<List<PickerMachineProductModel>> fetchPickerMachineProductData(machineId) async {
    print("Fetching Picker Machine Product Data for machineId: $machineId");
    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");
      if (userId == null || password == null) return [];

      final machineProductData = await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'pick.list',
          'search_read',
          [[
            ['id', '=', 3],
          ]],
          {
            'fields': [
              'id', 'display_name', 'product_id',
            ],
          },
        ],
      );
      print("Machine Product Data: $machineProductData");
      if (machineProductData.isNotEmpty) {
        return machineProductData.map<PickerMachineProductModel>((item) {
          return PickerMachineProductModel(
            id: item['id'],
            productId:item['product_id'][0],
            displayName: item['display_name'],
          );
        }).toList();
      }


      return [];
    } catch (e) {
      print("❌ Error in fetchPickerMachineData: $e");
      return [];
    }
  }


}