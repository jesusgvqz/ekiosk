import 'package:flutter/material.dart';
import 'kitchen_screen.dart';
import 'product_list_screen.dart';
import 'add_product_screen.dart';
import 'theme_screen.dart';
import '../../../core/widgets/themed_scaffold.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    KitchenScreen(),
    ProductListScreen(),
    AddProductScreen(),
    ThemeScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Órdenes"),
    BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Productos"),
    BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Agregar"),
    BottomNavigationBarItem(icon: Icon(Icons.color_lens), label: "Tema"),
  ];

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text("Panel Administrativo"),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
