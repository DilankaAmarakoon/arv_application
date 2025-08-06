import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class DropDownModel {
  final int id;
  final String string_id;
  final String name;

  DropDownModel({
    required this.id,
    this.string_id = "",
    required this.name,
  });

  factory DropDownModel.fromXmlRpc(Map<String, dynamic> xmlRpcData) {
    return DropDownModel(
      id: xmlRpcData['id'] as int,
      name: xmlRpcData['name'] as String,
    );
  }

  // Add these methods to fix the dropdown issue
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropDownModel &&
        other.id == id &&
        other.string_id == string_id &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, string_id, name);

  @override
  String toString() => 'DropDownModel(id: $id, string_id: $string_id, name: $name)';
}