import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class BasketDetailsModel {
  final int id;
  final String name;
  final String code;

  BasketDetailsModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory BasketDetailsModel.fromXmlRpc(Map<String, dynamic> xmlRpcData) {
    return BasketDetailsModel(
      id: xmlRpcData['id'] as int,
      name: xmlRpcData['name'],
      code: xmlRpcData['code']  == false ? "951316" : xmlRpcData['code'] as String,
    );
  }
}