import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml_rpc/client_c.dart' as xml_rpc;

import '../constants/static_data.dart';

class PickerMachineProductModel {
  final int id;
  final int productId;
  final String displayName;
  final String machineName;
  final String displayImage;
  final int pickAmount;
  final String barcode;
  bool isPicked;
  bool isFilled;

  PickerMachineProductModel({
    required this.id,
    required this.productId,
    required this.displayName,
    required this.machineName,
    required this.displayImage,
    required this.pickAmount,
    required this.barcode,
    required this.isPicked,
    required this.isFilled,
  });

  factory PickerMachineProductModel.fromXmlRpc(Map<String, dynamic> xmlRpcData) {
    return (PickerMachineProductModel(
        id: xmlRpcData["id"],
        productId: xmlRpcData["product_id"] == false ?  0  :xmlRpcData["product_id"][0],
        barcode: xmlRpcData["barcode"]?? "",
        displayName :xmlRpcData["product_id"] == false ? "" :xmlRpcData["product_id"][1],
        machineName :xmlRpcData["machine_id"] ==false ?  "" : xmlRpcData["machine_id"][1],
        pickAmount: xmlRpcData["pick_amount"],
        isPicked: xmlRpcData["picked"],
        isFilled: xmlRpcData["filled"],
        displayImage: xmlRpcData["image_1920"] == false ? "" :xmlRpcData["image_1920"]  ,
    ));
  }
}
