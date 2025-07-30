import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class PickerServiceRunModel {
  final int id;
  final String name;
  final String routeName;
  final String status;
  final List machines;
  final int machineCount;

  PickerServiceRunModel({
    required this.id,
    required this.name,
    required this.routeName,
    required this.status,
    required this.machines,
    required this.machineCount,
  });

  //
  // factory MachinePickListModel.fromJson(Map<String, dynamic> json) {
  //   return MachinePickListModel(
  //     id: json['id'] as int,
  //     name: json['name'] as String,
  //   );
  // }

  factory PickerServiceRunModel.fromXmlRpc(Map<String, dynamic> xmlRpcData) {
    return PickerServiceRunModel(
      id: xmlRpcData['id'] as int,
      name: xmlRpcData['name'],
      status: "active",
      routeName: xmlRpcData['route_id'][1] as String,
      machines: xmlRpcData['machine_ids'],
      machineCount: xmlRpcData['machine_count'],
    );
  }
}