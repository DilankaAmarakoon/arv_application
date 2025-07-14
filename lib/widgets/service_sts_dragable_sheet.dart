import 'package:flutter/material.dart';
import 'package:staff_mangement/constants/padding.dart';
import '../constants/colors.dart';

class ServiceStatusDragableSheet {
  void openDraggableSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows full screen drag
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(context);
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Padding(
                  padding: mainPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: SizedBox()),
                          Expanded(
                            child: Divider(thickness: 2, color: Colors.black87),
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                      Card(
                        shape: RoundedRectangleBorder(),
                        child: Padding(
                          padding: mainPadding,
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  "ARV411 @ Steel Line Garage Doors",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: k1mainColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 540,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Service Status",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      ExpansionTile(
                                        collapsedBackgroundColor: k1mainColor,
                                        collapsedTextColor: k1Background,
                                        backgroundColor: k2Background,
                                        textColor: k1mainColor,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pick List",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text("Machine pick list items"),
                                          ],
                                        ),
                                        children: [
                                          Text("List 1"),
                                          Text("List 2"),
                                          Text("List 3"),
                                          Text("List 4"),
                                          Text("List 5"),
                                          Text("List 6"),
                                        ],
                                      ),
                                      ExpansionTile(
                                        collapsedBackgroundColor: k1mainColor,
                                        collapsedTextColor: k1Background,
                                        backgroundColor: k2Background,
                                        textColor: k1mainColor,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Coin mech",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text("Does not require fill"),
                                          ],
                                        ),
                                        children: [
                                          Text("List 1"),
                                          Text("List 2"),
                                          Text("List 3"),
                                          Text("List 4"),
                                          Text("List 5"),
                                          Text("List 6"),
                                        ],
                                      ),
                                      ExpansionTile(
                                        collapsedBackgroundColor: k1mainColor,
                                        collapsedTextColor: k1Background,
                                        backgroundColor: k2Background,
                                        textColor: k1mainColor,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Cash Bag",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text("No Cash Bag set"),
                                          ],
                                        ),
                                        children: [
                                          Text("List 1"),
                                          Text("List 2"),
                                          Text("List 3"),
                                          Text("List 4"),
                                          Text("List 5"),
                                          Text("List 6"),
                                        ],
                                      ),
                                      ExpansionTile(
                                        collapsedBackgroundColor: k1mainColor,
                                        collapsedTextColor: k1Background,
                                        backgroundColor: k2Background,
                                        textColor: k1mainColor,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Tub",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text("Tub : D204"),
                                          ],
                                        ),
                                        children: [
                                          Text("List 1"),
                                          Text("List 2"),
                                          Text("List 3"),
                                          Text("List 4"),
                                          Text("List 5"),
                                          Text("List 6"),
                                        ],
                                      ),
                                      ExpansionTile(
                                        collapsedBackgroundColor: k1mainColor,
                                        collapsedTextColor: k1Background,
                                        backgroundColor: k2Background,
                                        textColor: k1mainColor,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Machine photos",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text("photo has been taken"),
                                          ],
                                        ),
                                        children: [
                                          Text("List 1"),
                                          Text("List 2"),
                                          Text("List 3"),
                                          Text("List 4"),
                                          Text("List 5"),
                                          Text("List 6"),
                                        ],
                                      ),
                                      ExpansionTile(
                                        collapsedBackgroundColor: k1mainColor,
                                        collapsedTextColor: k1Background,
                                        backgroundColor: k2Background,
                                        textColor: k1mainColor,
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Confirmed Stock Level",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text("Confirmed"),
                                          ],
                                        ),
                                        children: [
                                          Text("List 1"),
                                          Text("List 2"),
                                          Text("List 3"),
                                          Text("List 4"),
                                          Text("List 5"),
                                          Text("List 6"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
