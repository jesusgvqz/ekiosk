import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String _paymentMethod = 'cash';

  String? _response;

  Future<void> _submitOrder() async {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final price = double.tryParse(_priceController.text) ?? 0;

    final total = quantity * price;

    final order = {
      "items": [
        {
          "product_id": "001",
          "name": _productController.text,
          "quantity": quantity,
          "price": price
        }
      ],
      "total": total,
      "payment_method": _paymentMethod
    };

    final url = Uri.parse("http://localhost:8000/orders"); // cambia IP si estás en Android
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(order),
    );

    setState(() {
      _response = response.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Orden')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productController,
                decoration: const InputDecoration(labelText: 'Producto'),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Pago en Caja')),
                  DropdownMenuItem(value: 'card', child: Text('Pago con Terminal')),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Método de Pago'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOrder,
                child: const Text('Enviar Orden'),
              ),
              const SizedBox(height: 20),
              if (_response != null)
                Text('Respuesta del backend:\n$_response'),
            ],
          ),
        ),
      ),
    );
  }
}
