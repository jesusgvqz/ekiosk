import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config.dart';
import '../../../core/widgets/themed_scaffold.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  String? _response;

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = {
      "product_id": _productIdController.text,
      "name": _nameController.text,
      "price": double.tryParse(_priceController.text) ?? 0,
    };

    final url = Uri.parse("${AppConfig.baseUrl}/menu");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(product),
    );

    setState(() {
      _response = response.statusCode == 200
          ? "Producto agregado con éxito"
          : "Error: ${response.body}";
    });

    _productIdController.clear();
    _nameController.clear();
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(title: const Text("Agregar Platillo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(labelText: 'ID del Producto'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  return (parsed == null || parsed <= 0) ? 'Precio inválido' : null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text("Guardar Producto"),
              ),
              if (_response != null) ...[
                const SizedBox(height: 10),
                Text(_response!),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
