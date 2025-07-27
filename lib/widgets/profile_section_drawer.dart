// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:staff_mangement/constants/colors.dart';
// import 'package:staff_mangement/constants/padding.dart';
// import 'package:staff_mangement/reusebleWidgets/action_btn.dart';
// import 'package:staff_mangement/screens/login_screen.dart';
//
// class ProfileSectionDrawer extends StatefulWidget {
//   const ProfileSectionDrawer({super.key});
//
//   @override
//   State<ProfileSectionDrawer> createState() => _ProfileSectionDrawerState();
// }
//
// class _ProfileSectionDrawerState extends State<ProfileSectionDrawer> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: k2Background,
//       width: 500,
//       child: Padding(
//         padding: mainPadding,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text("SDSDSD"),
//             Text("SDSDSD"),
//             Text("SDSDSD"),
//             Text("SDSDSD"),
//             Spacer(),
//             ActionBtn(
//               lable: "LOG OUT",
//               onPressed: () async {
//                 SharedPreferences preference =
//                     await SharedPreferences.getInstance();
//                 preference.clear();
//                 navigateBackLoginScree();
//               },
//               width: 100,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   navigateBackLoginScree() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SimpleLoginScreen()),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';
import '../constants/theme.dart';

class ProfileSectionDrawer extends StatelessWidget {
  const ProfileSectionDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeader(),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  icon: Icons.people_outlined,
                  title: 'Staff Management',
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  icon: Icons.kitchen,
                  title: 'Machine Operations',
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  onTap: () => Navigator.pop(context),
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(color: AppColors.divider),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.onPrimary,
              child: Icon(
                Icons.person,
                size: 35,
                color: AppColors.primary,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: AppSpacing.md),
              Text(
                'Staff Member',
                style: AppTextStyles.body1,
              ),
              Text(
                'staff@company.com',
                style: AppTextStyles.body1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.body1,
      ),
      onTap: onTap,
      hoverColor: AppColors.primary.withOpacity(0.1),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Version 1.0.0',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.clear();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const SimpleLoginScreen(),
          ),
              (route) => false,
        );
      }
    }
  }
}