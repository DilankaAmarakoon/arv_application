import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/providers/notification_state_provider.dart';
import 'package:staff_mangement/widgets/notification_cart.dart';

PreferredSizeWidget appBarSection(BuildContext context) {
  final notificationProvider = Provider.of<NotificationStateProvider>(context);
  NotificationCart notificationCart = NotificationCart();
  return AppBar(
    actions: [
      Stack(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  if (notificationProvider.notificationCount > 0) {
                    notificationCart.notificationPressed(context);
                  }
                },
                icon: Icon(Icons.notifications, size: 30),
              );
            },
          ),
          notificationProvider.notificationCount > 0
              ? Positioned(
                right: 5,
                top: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notificationProvider.notificationCount.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
              : SizedBox(),
        ],
      ),
      Builder(
        builder: (context) {
          return Stack(
            children: [
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Icon(Icons.person, size: 30),
              ),
            ],
          );
        },
      ),
    ],
  );
}
