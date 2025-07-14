import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mangement/constants/static_data.dart';

class StaffTaskDataModel {
  int? id;
  String? taskName;
  String? taskDesc;
  String? remarks;
  bool? isCompleted;

  StaffTaskDataModel({
    this.id,
    this.taskName,
    this.taskDesc,
    this.remarks,
    this.isCompleted,
  });
}
//ll
class StaffTaskDataList {
  List<StaffTaskDataModel> staffTaskDataList = [];
  Future<void> fetchStaffData(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    try {
      final dio = Dio();
      Response response = await dio.post(
        '${baseUrl}api/task_line',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {"user_id": preferences.getInt("user_Id")},
      );
      if (response.statusCode == 200) {
        for (dynamic item in response.data["result"]["task_lines"]) {
          item['remarks'] = item['remark'] == false ? "" : item['remark'];
          item['task_id'] = item['task_id'] == false ? "" : item['task_id'];
          staffTaskDataList.add(
            StaffTaskDataModel(
              id: item['id'],
              taskName: item['task_name'],
              taskDesc: item['description'],
              remarks: item["remarks"],
              isCompleted: item['is_complete'],
            ),
          );
        }
      }
    } on DioException catch (e) {
      // ignore: avoid_print
      print('Dio Error: ${e.message}');

      // if (e.response != null) {
      //   if (e.response!.statusCode == 401) {
      //     print('Unauthorized - 401');
      //   } else if (e.response!.statusCode == 500) {
      //     print('Internal Server Error - 500');
      //   } else {
      //     print('Error with status code: ${e.response!.statusCode}');
      //   }
      // } else {
      //   print('Error without server response: ${e.message}');
      // }
    } catch (e) {
      // ignore: avoid_print
      print('Unexpected error: $e');
    }
  }
}
