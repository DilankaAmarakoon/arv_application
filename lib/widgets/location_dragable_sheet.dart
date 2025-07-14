import 'package:flutter/material.dart';
import 'package:staff_mangement/constants/padding.dart';
import 'package:staff_mangement/reusebleWidgets/action_btn.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';

class LocationDragableSheet {
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
                                height: 300,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("07 Mar 2025"),
                                      Text(
                                        "Location Details",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: k1mainColor,
                                          ),
                                          Text(
                                            "47 Hammond Rd, Dandenong South ,VIC ,3175",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
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
                                            "Location note(s)",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
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
                                                "This is location notes section",
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
                                            "Veiw all location details",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text("detail 1"),
                                      Text("detail 2"),
                                      Text("detail 3"),
                                      Text("detail 4"),
                                      Text("detail 5"),
                                      Text("detail 6"),
                                      Text("detail 7"),
                                      Text("detail 8"),
                                      Text("detail 9"),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: ActionBtn(
                                  lable: "NAVIGATE",
                                  height: 50,
                                  width: 100,
                                  onPressed: () {
                                    _openMap();
                                  },
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

  Future<void> _openMap() async {
    final double latitude = 6.861186;
    final double longitude = 80.873704;

    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }
}
