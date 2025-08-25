import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';
import 'dart:convert';
import 'dart:typed_data';
class MachinePickListModel {
  final int id;
  final int pick_list_id;
  final String name;
  double latitude;
  double longitude;
  String state;
  final List pickListIds;
  List basketNumbers;
  List basketNumbersDisplay;

  MachinePickListModel({
    required this.id,
    required this.pick_list_id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.state,
    required this.pickListIds,
    required this.basketNumbers,
    required this.basketNumbersDisplay,
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
      id: xmlRpcData['machine_id'] == false ? 0 : xmlRpcData['machine_id'][0]  as int,
      pick_list_id: xmlRpcData['id']  as int,
      name: xmlRpcData['machine_id'] == false ?  "" :xmlRpcData['machine_id'][1] as String,
      state: xmlRpcData['state'] as String,
      pickListIds: xmlRpcData['pick_list_ids'] as List,
      basketNumbers: xmlRpcData['tag_ids'],
      basketNumbersDisplay: List<String>.from(xmlRpcData['tag_names'] ?? []),
      latitude: xmlRpcData['latitude'],
      longitude: xmlRpcData['longitude'],
    );
  }
}