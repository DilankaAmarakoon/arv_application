import 'package:flutter/material.dart';
import '../Models/picker_machine_product.dart';
import '../constants/colors.dart';
import '../screens/picker_matchin_scree.dart';

class PickerMatchingCart extends StatefulWidget {
  final String detailsName;
  final String machineName;
  final String route;
  final int machineCount;
  final int machineId;

  const PickerMatchingCart({
    super.key,
    required this.detailsName,
    required this.machineName,
    required this.route,
    required this.machineCount,
    required this.machineId,
  });

  @override
  State<PickerMatchingCart> createState() => _PickerMatchingCartState();
}

class _PickerMatchingCartState extends State<PickerMatchingCart>
    with SingleTickerProviderStateMixin {
  bool isSelected = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  PickerMachineProductDetailsData pickerMachineProductDetailsData  = PickerMachineProductDetailsData();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

   _onTap() async{
    setState(() {
      isSelected = !isSelected;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    List<PickerMachineProductModel> list = await pickerMachineProductDetailsData.fetchPickerMachineProductData(widget.machineId);
   await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PickerMatchinScreen(pickerMachineProductList:list)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isSelected ? k1mainColor.withOpacity(0.1) : Colors.white,
                    isSelected ? k1mainColor.withOpacity(0.05) : Colors.grey[50]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? k1mainColor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? k1mainColor.withOpacity(0.3) : Colors.grey[200]!,
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Machine Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: k1mainColor.withOpacity(0.1),
                          border: Border.all(
                            color: k1mainColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.precision_manufacturing_outlined,
                          color: k1mainColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Machine Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Details Name
                            Text(
                              widget.detailsName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),

                            // Machine Name and Count
                            Row(
                              children: [
                                Icon(
                                  Icons.precision_manufacturing,
                                  color: k1mainColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "${widget.machineName} (${widget.machineCount} machines)",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Route
                            Row(
                              children: [
                                Icon(
                                  Icons.route_outlined,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.route,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Location
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}