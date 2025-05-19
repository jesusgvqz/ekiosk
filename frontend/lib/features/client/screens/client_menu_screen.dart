import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config.dart';
import '../../../core/widgets/themed_scaffold.dart';

class ClientMenuScreen extends StatefulWidget {
  const ClientMenuScreen({super.key});

  @override
  State<ClientMenuScreen> createState() => _ClientMenuScreenState();
}

class _ClientMenuScreenState extends State<ClientMenuScreen> {
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
    final url = Uri.parse("${AppConfig.baseUrl}/menu");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _menu = data;
        _quantities = {for (var item in data) item['product_id']: 0};
      });
    }
  }

  Future<void> _submitOrder() async {
    final selectedItems = _menu.where((item) => _quantities[item['product_id']]! > 0).toList();
    if (selectedItems.isEmpty) {
      setState(() => _response = "Selecciona al menos un producto.");
      return;
    }

    final items = selectedItems.map((item) {
      final qty = _quantities[item['product_id']]!;
      return {
        "product_id": item["product_id"],
        "name": item["name"],
        "quantity": qty,
        "price": item["price"]
      };
    }).toList();

    final total = items.fold<double>(0.0, (sum, item) => sum + item["quantity"] * item["price"]);

    final order = {
      "items": items,
      "total": total,
      "payment_method": _paymentMethod
    };

    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}/orders"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(order),
    );

    final data = json.decode(response.body);
    final orderId = data["order_id"];

    final paymentUrl = Uri.parse(
      _paymentMethod == "cash"
          ? "${AppConfig.baseUrl}/cashier/pay"
          : "${AppConfig.baseUrl}/terminal/pay"
    );

    final payRes = await http.post(
      paymentUrl,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"order_id": orderId}),
    );

    setState(() {
      _response = payRes.body;
      _quantities.updateAll((key, value) => 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text("Menú"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin'); // ruta hacia AdminHomeScreen
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 2,
              ),
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final item = _menu[index];
                final qty = _quantities[item['product_id']]!;
                return Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("\$${item["price"]}"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: qty > 0 ? () {
                                setState(() {
                                  _quantities[item['product_id']] = qty - 1;
                                });
                              } : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text(qty.toString()),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _quantities[item['product_id']] = qty + 1;
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _paymentMethod,
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Pagar en Caja')),
                DropdownMenuItem(value: 'card', child: Text('Pagar con Terminal')),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value!),
              decoration: const InputDecoration(labelText: 'Método de Pago'),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitOrder,
            child: const Text("Realizar Orden"),
          ),
          if (_response != null) Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_response!),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
