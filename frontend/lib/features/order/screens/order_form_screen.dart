import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  List<dynamic> _menu = [];
  Map<String, int> _quantities = {};
  String _paymentMethod = 'cash';
  String? _response;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final url = Uri.parse("http://127.0.0.1:8000/menu"); // usa IP si es Android
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> menuData = json.decode(response.body);
      setState(() {
        _menu = menuData;
        _quantities = {
          for (var item in menuData) item['product_id']: 0,
        };
      });
    }
  }

  Future<void> _submitOrder() async {
    final selectedItems = _menu.where((item) => _quantities[item['product_id']]! > 0).toList();

    if (selectedItems.isEmpty) {
      setState(() {
        _response = "Selecciona al menos un producto.";
      });
      return;
    }

    final items = selectedItems.map((item) {
      final qty = _quantities[item['product_id']]!;
      return {
        "product_id": item['product_id'],
        "name": item['name'],
        "quantity": qty,
        "price": item['price']
      };
    }).toList();

    final total = items.fold<double>(0.0, (sum, item) => sum + item['quantity'] * item['price']);

    final order = {
      "items": items,
      "total": total,
      "payment_method": _paymentMethod
    };

    final url = Uri.parse("http://127.0.0.1:8000/menu");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(order),
    );

    final data = json.decode(response.body);
    final orderId = data["order_id"];

    // Enviar al endpoint correspondiente
    final paymentUrl = Uri.parse(
      _paymentMethod == "cash"
          ? "http://127.0.0.1:8000/cashier/pay"
          : "http://127.0.0.1:8000/terminal/pay",
    );

    final paymentResponse = await http.post(
      paymentUrl,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "order_id": orderId
        }),
    );

    setState(() {
      _response = paymentResponse.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Orden")),
      body: _menu.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _menu.length,
                      itemBuilder: (context, index) {
                        final item = _menu[index];
                        final qty = _quantities[item['product_id']]!;
                        return ListTile(
                          title: Text("${item['name']} - \$${item['price']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: qty > 0
                                    ? () {
                                        setState(() {
                                          _quantities[item['product_id']] = qty - 1;
                                        });
                                      }
                                    : null,
                              ),
                              Text(qty.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _quantities[item['product_id']] = qty + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Pagar en Caja')),
                      DropdownMenuItem(value: 'card', child: Text('Pagar con Terminal')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Método de Pago'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitOrder,
                    child: const Text('Enviar Orden'),
                  ),
                  if (_response != null) ...[
                    const SizedBox(height: 10),
                    Text("Respuesta del servidor:\n$_response"),
                  ],
                ],
              ),
            ),
    );
  }
}
