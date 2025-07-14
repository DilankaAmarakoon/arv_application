import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class MachineDetailsModel {
  final int id;
  final String name;
  final String routeName;
  final String machineName;
  final int machineCount;

  MachineDetailsModel({
    required this.id,
    required this.name,
    required this.routeName,
    required this.machineName,
    required this.machineCount,
  });
}

class MachineDetailsData {
  Future<List<MachineDetailsModel>> fetchPickerMachineData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final userId = pref.getInt("user_Id");
      final password = pref.getString("password");
      if (userId == null || password == null) return [];

      final machineData = await xml_rpc.call(
        Uri.parse("$baseUrl/xmlrpc/2/object"),
        'execute_kw',
        [
          dbName,
          userId,
          password,
          'service.run',
          'search_read',
          [[]],
          {
            'fields': [
              'id', 'name', 'route_id', 'machine_ids', 'machine_count','pick_list_ids'
            ],
          },
        ],
      );
      // final machineDetails = await xml_rpc.call(
      //   Uri.parse("$baseUrl/xmlrpc/2/object"),
      //   'execute_kw',
      //   [
      //     dbName,
      //     userId,
      //     password,
      //     'service.run.machine',
      //     'search_read',
      //     [[
      //       ['service_run_id', '=',2],
      //     ]],
      //     {
      //       'fields': [
      //         'id', 'display_name',
      //       ],
      //     },
      //   ],
      // );
      print("Machine Data: $machineData");
      if (machineData.isNotEmpty) {
        return machineData.map<MachineDetailsModel>((item) {
          return MachineDetailsModel(
            id: item['id'],
            name: item['name'],
            routeName: item['route_id'] == false ? "" :item['route_id'][1],
            machineName: "ssssss",
            machineCount: item['machine_count'] ?? 0,
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