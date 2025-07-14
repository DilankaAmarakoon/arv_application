import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/constants/colors.dart';
import 'package:staff_mangement/screens/picker_section.dart';
import 'package:staff_mangement/screens/staff_screen.dart';
import '../providers/handlle_data_provider.dart';
import 'filler_screen.dart.dart';

class DashbordDetails extends StatefulWidget {
  const DashbordDetails({super.key});

  @override
  State<DashbordDetails> createState() => _DashbordDetailsState();
}

class _DashbordDetailsState extends State<DashbordDetails>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final handleDataProvider = Provider.of<HandleDataProvider>(context,listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 350,
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
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: k1mainColor),
              ),
              child: GestureDetector(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    child: SvgPicture.asset(
                      'assets/icons/staff-symbol-svgrepo-com.svg',
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StaffScreen()),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 350,
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
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: k1mainColor),
              ),
              child: GestureDetector(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    child: SvgPicture.asset(
                      'assets/icons/vending-machine-svgrepo-com.svg',
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    // MaterialPageRoute(builder: (context) => FillerScreen()),
                    MaterialPageRoute(builder: (context) => PickerScreen()),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
