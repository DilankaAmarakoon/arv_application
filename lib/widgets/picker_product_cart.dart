import 'package:flutter/material.dart';

import '../constants/colors.dart';

class PickerCardContainer extends StatefulWidget {
  final String productName;


  const PickerCardContainer({
    Key? key,
    required this.productName,
  }) : super(key: key);

  @override
  State<PickerCardContainer> createState() => _PickerCardContainerState();
}

class _PickerCardContainerState extends State<PickerCardContainer> {
  bool isPicked = false;
  int pickAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isPicked
                ? k1mainColor.withOpacity(0.08)
                : Colors.white,
            isPicked
                ?k1mainColor.withOpacity(0.04)
                : Colors.grey[50]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: isPicked
                ? k1mainColor.withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isPicked
                ? k1mainColor.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isPicked
              ? k1mainColor.withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              isPicked = !isPicked;
              pickAmount = isPicked ? 1 : 0;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header Section
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Product Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: k1mainColor.withOpacity(0.1),
                          border: Border.all(
                            color: k1mainColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: k1mainColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Product Name
                      Text(
                        widget.productName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Quantity Section
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isPicked
                          ? k1mainColor.withOpacity(0.1)
                          : Colors.grey[100],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pickAmount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isPicked
                                ? k1mainColor
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Status Section
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPicked ? "Selected" : "Available",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isPicked
                              ? k1mainColor
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: isPicked,
                          onChanged: (value) {
                            setState(() {
                              isPicked = value ?? false;
                              pickAmount = isPicked ? 1 : 0;
                            });
                          },
                          activeColor: k1mainColor,
                          checkColor: Colors.white,
                          side: BorderSide(
                            color: k1mainColor.withOpacity(0.3),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage:
// PickerCardContainer(
//   productName: "Sample Product",
//   k1mainColor: Colors.blue,
// )