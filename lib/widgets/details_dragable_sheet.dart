import 'package:flutter/material.dart';
import 'package:staff_mangement/constants/padding.dart';
import '../constants/colors.dart';

class DetailsDragableSheet {
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
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.6,
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
                                height: 340,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Ticket Details",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        "Communication device 43433145645564",
                                      ),
                                      Text(
                                        "Received Communication types : corupt |dex|Live",
                                      ),
                                      Text(
                                        "Last Communication Time : 07 Mar 2025 03:45.p.m",
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.note_alt_rounded,
                                            color: k1mainColor,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              border: Border.all(
                                                width: 0.5,
                                                color: k1mainColor,
                                              ),
                                            ),
                                            child: Text(
                                              "Close 3.00 p.m",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                // ignore: deprecated_member_use
                                                color: k1mainColor.withOpacity(
                                                  0.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.note_alt_rounded,
                                            color: k1mainColor,
                                          ),
                                          Text(
                                            "Other matchine  note(s)",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 300,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: k1mainColor,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: TextEditingController(
                                            text:
                                                "This is matchine notes section",
                                          ),
                                          enabled: false, // disables the field
                                          maxLines: 5,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.details_outlined,
                                            color: k1mainColor,
                                          ),
                                          Text(
                                            "Tickets details",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
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
