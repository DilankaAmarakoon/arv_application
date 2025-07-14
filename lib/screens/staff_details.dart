import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:staff_mangement/Models/staff_task_data_model.dart';
import '../../constants/colors.dart';
import '../constants/static_data.dart';

class StaffDetails extends StatefulWidget {
  final int index;
  final StaffTaskDataModel dataList;
  const StaffDetails({super.key, required this.index, required this.dataList});

  @override
  State<StaffDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<StaffDetails> {
  StaffTaskDataList staffTaskDataList = StaffTaskDataList();
  late TextEditingController remarkController;
  bool isSwitch = false;
  double offsetX = 0.0;

  Timer? lockSwitchTime;
  bool isSwitchLock = false;
  @override
  void initState() {
    widget.dataList.remarks =
        widget.dataList.remarks == "true" ? "" : widget.dataList.remarks;
    isSwitchLock = widget.dataList.isCompleted! ? true : false;
    remarkController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    lockSwitchTime?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          offsetX += details.delta.dx;
          if (offsetX < 0) offsetX = 0;
          if (offsetX > 60) offsetX = 60;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          if (offsetX > 50) {
            offsetX = 60;
          } else {
            offsetX = 0;
          }
        });
      },
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.14,
            width: 100,
            decoration: BoxDecoration(
              color: k1mainColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    openRemarkPopup(widget.dataList.remarks, widget.index);
                  });
                },
                icon: Icon(
                  Icons.comment_bank_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(offsetX, 0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.14,
              decoration: BoxDecoration(
                color: k2Background,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.dataList.taskName!,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            widget.dataList.taskDesc!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          Row(
                            children: [
                              widget.dataList.remarks! != ""
                                  ? Text(
                                    "Remarks:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                  : SizedBox(),
                              Text(
                                widget.dataList.remarks!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            value: widget.dataList.isCompleted!,
                            onChanged: (value) {
                              setState(() {
                                if (!isSwitchLock) {
                                  widget.dataList.isCompleted = value;
                                }
                                if (!widget.dataList.isCompleted!) {
                                  saveCompletedState();
                                  isSwitchLock = false;
                                }
                                if (widget.dataList.isCompleted!) {
                                  saveCompletedState();
                                  lockSwitchBtn();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void lockSwitchBtn() {
    lockSwitchTime?.cancel();
    lockSwitchTime = Timer(Duration(seconds: 30), () {
      isSwitchLock = true;
      setState(() {});
    });
  }

  openRemarkPopup(remarks, index) {
    remarkController.text = remarks;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Remark"),
          content: TextField(
            controller: remarkController,
            decoration: InputDecoration(hintText: "Enter your remark"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  offsetX = 0;
                  widget.dataList.remarks = remarkController.text;
                });
                saveRemarks();
                Navigator.of(context).pop();
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCompletedState() async {
    try {
      final dio = Dio();
      Response response = await dio.post(
        '${baseUrl}api/task_complete',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "task_line_id": widget.dataList.id,
          "is_complete": widget.dataList.isCompleted,
        },
      );
      if (response.statusCode == 200) {}
    } on DioException catch (e) {
      // ignore: avoid_print
      print('Dio Error: ${e.message}');
    } catch (e) {
      // ignore: avoid_print
      print('Unexpected error: $e');
    }
  }

  Future<void> saveRemarks() async {
    try {
      final dio = Dio();
      Response response = await dio.post(
        '${baseUrl}api/task_remark',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "task_line_id": widget.dataList.id,
          "remark": widget.dataList.remarks,
        },
      );
      if (response.statusCode == 200) {}
    } on DioException catch (e) {
      // ignore: avoid_print
      print('Dio Error: ${e.message}');
    } catch (e) {
      // ignore: avoid_print
      print('Unexpected error: $e');
    }
  }
}
