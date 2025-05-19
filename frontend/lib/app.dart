import 'package:flutter/material.dart';
import 'features/order/screens/order_form_screen.dart';
import 'features/admin/screens/add_product_screen.dart';
import 'features/kitchen/screens/kitchen_screen.dart'; // por crear


class KioskApp extends StatefulWidget {
  const KioskApp({super.key});

  @override
  State<KioskApp> createState() => _KioskAppState();
}

class _KioskAppState extends State<KioskApp> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    OrderFormScreen(),
    AddProductScreen(),
    KitchenScreen(), // placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menú'),
    BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Agregar'),
    BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Cocina'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eKiosk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'features/order/screens/order_screen.dart';

// class KioskApp extends StatelessWidget {
//   const KioskApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'eKiosk UI 2.0',
//       theme: ThemeData.dark().copyWith(
//         primaryColor: Colors.deepPurple,
//         scaffoldBackgroundColor: Colors.black,
//         textTheme: const TextTheme(
//           headlineLarge: TextStyle(
//             fontSize: 30,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       home: const OrderScreen(),
//     );
//   }
// }
