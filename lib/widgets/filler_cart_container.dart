import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import '../constants/colors.dart';

class FillerCardContainer extends StatefulWidget {
  final VoidCallback onTapFilletLocation;
  final VoidCallback onTapFillerDetails;
  final VoidCallback onTapFillerServiceSts;

  const FillerCardContainer({
    super.key,
    required this.onTapFillerDetails,
    required this.onTapFillerServiceSts,
    required this.onTapFilletLocation,
  });

  @override
  State<FillerCardContainer> createState() => _FillerCardContainerState();
}

class _FillerCardContainerState extends State<FillerCardContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: k2Background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ARV411 @ Steel Line Garage Doors",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: k1mainColor,
              ),
            ),
            Divider(),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      child: Text(
                        "PICKED",
                        style: TextStyle(fontSize: 10, color: k1mainColor),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        "COMPLETE",
                        style: TextStyle(fontSize: 10, color: k1mainColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   height: 40,
            //   child: Stack(
            //     children: [
            //       SimpleAnimationProgressBar(
            //         height: 15,
            //         width: MediaQuery.of(context).size.width * 0.95,
            //         backgroundColor: Colors.grey.shade300,
            //         foregrondColor: Colors.blue,
            //         ratio: 0.5, // example progress
            //         direction: Axis.horizontal,
            //         curve: Curves.fastLinearToSlowEaseIn,
            //         duration: const Duration(seconds: 3),
            //         borderRadius: BorderRadius.circular(0),
            //         gradientColor: LinearGradient(
            //           colors: [
            //             // ignore: deprecated_member_use
            //             k1mainColor.withOpacity(0.7),
            //             // ignore: deprecated_member_use
            //             Colors.greenAccent.withOpacity(0.7),
            //           ],
            //         ),
            //       ),
            //       // Positioned markers over the progress bar
            //       Positioned.fill(
            //         child: LayoutBuilder(
            //           builder: (context, constraints) {
            //             final totalWidth = constraints.maxWidth;
            //             final markers = [0.5, 1.0];
            //             return Stack(
            //               children:
            //                   markers.map((ratio) {
            //                     if (ratio == 1.0) {
            //                       return Align(
            //                         alignment: Alignment.centerRight,
            //                         child: Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.end,
            //                           children: [
            //                             Container(
            //                               width: 2,
            //                               height:
            //                                   15, // Match the height of the progress bar
            //                               color: k2mainColor,
            //                             ),
            //                             // Optional: Label for the last marker (100%)
            //                             // Text(
            //                             //   "PHOTO",
            //                             //   style: TextStyle(fontSize: 12),
            //                             // ),
            //                           ],
            //                         ),
            //                       );
            //                     }
            //                     final left = totalWidth * ratio + 5;
            //                     return Positioned(
            //                       left: left,
            //                       top: 0,
            //                       bottom: 0,
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.end,
            //                         children: [
            //                           Container(
            //                             width: 2,
            //                             height:
            //                                 15, // Match the height of the progress bar
            //                             color: k2mainColor,
            //                           ),
            //                           // Label for the other markers (25%, 50%, 75%)
            //                           // Text(
            //                           //   "${(ratio * 100).toInt()}%",
            //                           //   style: TextStyle(fontSize: 12),
            //                           // ),
            //                         ],
            //                       ),
            //                     );
            //                   }).toList(),
            //             );
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: widget.onTapFilletLocation,
                        icon: Icon(Icons.location_on_outlined),
                        color: k1mainColor,
                      ),
                      Text("Location"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: widget.onTapFillerDetails,
                        icon: Icon(Icons.add),
                        color: k1mainColor,
                      ),
                      Text("Tickets"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: widget.onTapFillerServiceSts,
                        icon: Icon(Icons.remove_red_eye_outlined),
                        color: k1mainColor,
                      ),
                      Text("Details"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
