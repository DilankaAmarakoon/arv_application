import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class PickerMachineProductModel {
  final int id;
  final int productId;
  final String displayName;
  final int pickAmount;
  bool isPicked;
  bool isFilled;

  PickerMachineProductModel({
    required this.id,
    required this.productId,
    required this.displayName,
    required this.pickAmount,
    required this.isPicked,
    required this.isFilled,
  });

  factory PickerMachineProductModel.fromXmlRpc(Map<String, dynamic> xmlRpcData) {
    return (PickerMachineProductModel(
        id: xmlRpcData["id"],
        productId: xmlRpcData["product_id"][0],
        displayName :xmlRpcData["product_id"][1],
        pickAmount: xmlRpcData["pick_amount"],
        isPicked: xmlRpcData["picked"],
       isFilled: xmlRpcData["filled"],
    ));
  }
}
