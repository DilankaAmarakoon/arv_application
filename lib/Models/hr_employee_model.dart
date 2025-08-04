import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class DropDownModel {
  final int id;
  final String string_id;
  final String name;

  DropDownModel({
    required this.id,
    this.string_id ="",
    required this.name,
  });

  //
  // factory MachinePickListModel.fromJson(Map<String, dynamic> json) {
  //   return MachinePickListModel(
  //     id: json['id'] as int,
  //     name: json['name'] as String,
  //   );
  // }

  factory DropDownModel.fromXmlRpc(Map<String, dynamic> xmlRpcData) {
    return DropDownModel(
      id: xmlRpcData['id']  as int,
      name: xmlRpcData['name']  as String,
    );
  }
}