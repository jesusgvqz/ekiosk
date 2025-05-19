import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> _products = [];

  Future<void> _fetchProducts() async {
    final url = Uri.parse("${AppConfig.baseUrl}/menu");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body);
      });
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final url = Uri.parse("${AppConfig.baseUrl}/menu/$productId");
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      _fetchProducts(); // Recargar después de eliminar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar: ${response.body}")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return _products.isEmpty
        ? const Center(child: Text("No hay productos registrados"))
        : ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text("ID: ${product['product_id']} - \$${product['price']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(product['product_id']),
                ),
              );
            },
          );
  }

  void _confirmDelete(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: const Text("¿Estás seguro de eliminar este producto?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(productId);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
