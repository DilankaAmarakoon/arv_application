import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class MachinePickListModel {
  final int id;
  final int pick_list_id;
  final String name;
  final List pickListIds;

  MachinePickListModel({
    required this.id,
    required this.pick_list_id,
    required this.name,
    required this.pickListIds,
  });

  //
  // factory MachinePickListModel.fromJson(Map<String, dynamic> json) {
  //   return MachinePickListModel(
  //     id: json['id'] as int,
  //     name: json['name'] as String,
  //   );
  // }

  factory MachinePickListModel.fromXmlRpc(Map<String, dynamic> xmlRpcData) {
    return MachinePickListModel(
      id: xmlRpcData['machine_id'][0]  as int,
      pick_list_id: xmlRpcData['id']  as int,
      name: xmlRpcData['machine_id'][1] as String,
      pickListIds: xmlRpcData['pick_list_ids'] as List,
    );
  }
}