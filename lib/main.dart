import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:staff_mangement/constants/colors.dart';
import 'package:staff_mangement/providers/handlle_data_provider.dart';
import 'package:staff_mangement/providers/notification_state_provider.dart';
import 'package:staff_mangement/screens/home_page.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NotificationStateProvider(),
        ),ChangeNotifierProvider(
          create: (context) => HandleDataProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Staff Management',
      theme: ThemeData(
        primaryColor: k1mainColor,
        colorScheme: ColorScheme.fromSeed(seedColor: k1mainColor),
      ),
      home: const HomePage(),
    );
  }
}
