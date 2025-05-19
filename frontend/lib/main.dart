import 'package:flutter/material.dart';
import 'features/client/screens/client_menu_screen.dart';
import 'features/admin/screens/admin_home_screen.dart';

void main() {
  runApp(const KioskApp());
}

class KioskApp extends StatelessWidget {
  const KioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eKiosk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const ClientMenuScreen(),
        '/admin': (context) => const AdminHomeScreen(),
      },
    );
  }
}
