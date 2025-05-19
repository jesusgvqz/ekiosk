import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config.dart';
import '../../../core/theme_config.dart';
import '../../../core/widgets/themed_scaffold.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  List<dynamic> _orders = [];
  int _orderCount = 0;
  Timer? _autoRefresh;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) => _fetchOrders());
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final url = Uri.parse("${AppConfig.baseUrl}/orders/kitchen");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _orders = data;
        _orderCount = data.length;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    final url = Uri.parse("${AppConfig.baseUrl}/orders/$orderId/status");
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": newStatus}),
    );

    if (response.statusCode == 200) {
      _fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar estado: ${response.body}")),
      );
    }
  }

  Color _getStatusColor() {
    if (_orderCount >= 6) return Colors.red;
    if (_orderCount >= 3) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text("Cocina - Órdenes activas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _getStatusColor(),
            child: Text(
              "Órdenes activas: $_orderCount",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? const Center(child: Text("No hay órdenes activas"))
                : ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final items = order["items"] as List<dynamic>;
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Orden: ${order["order_id"]}",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...items.map((item) =>
                                  Text("- ${item["quantity"]}x ${item["name"]}")),
                              const SizedBox(height: 10),
                              Text("Estado: ${order["status"]}"),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (order["status"] == "pending")
                                    ElevatedButton(
                                      onPressed: () =>
                                          _updateStatus(order["order_id"], "preparing"),
                                      child: const Text("Preparando"),
                                    ),
                                  const SizedBox(width: 10),
                                  if (order["status"] != "ready")
                                    ElevatedButton(
                                      onPressed: () =>
                                          _updateStatus(order["order_id"], "ready"),
                                      child: const Text("Listo"),
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
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../../core/config.dart';
// import '../../../core/widgets/themed_scaffold.dart';
// import 'dart:async';

// class KitchenScreen extends StatefulWidget {
//   const KitchenScreen({super.key});

//   @override
//   State<KitchenScreen> createState() => _KitchenScreenState();
// }

// class _KitchenScreenState extends State<KitchenScreen> {
//   List<dynamic> _orders = [];

//   Future<void> _fetchOrders() async {
//     final url = Uri.parse("${AppConfig.baseUrl}/orders/kitchen");
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       setState(() {
//         _orders = json.decode(response.body);
//       });
//     } else {
//       setState(() {
//         _orders = [];
//       });
//     }
    
//     ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text("Órdenes actualizadas"), duration: Duration(milliseconds: 600)),
//     );
//   }

//   Future<void> _updateStatus(String orderId, String newStatus) async {
//     final url = Uri.parse("${AppConfig.baseUrl}/orders/$orderId/status");
//     await http.patch(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({"status": newStatus}),
//     );
//     _fetchOrders(); // Recargar lista
//   }

//   Timer? _autoRefresh;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOrders();

//     // 🔄 Refresca automáticamente cada 30 segundos
//     _autoRefresh = Timer.periodic(const Duration(seconds: 30), (timer) {
//       _fetchOrders();
//     });
//   }

//   @override
//   void dispose() {
//     _autoRefresh?.cancel(); // ✨ Importante: cancelar el timer cuando se destruye la pantalla
//     super.dispose();
//   }


//   @override
//   Widget build(BuildContext context) {
//     return ThemedScaffold(
//       appBar: AppBar(
//         title: const Text("Cocina - Órdenes activas"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchOrders,
//           )
//         ],
//       ),
//       body: _orders.isEmpty
//           ? const Center(child: Text("No hay órdenes activas"))
//           : ListView.builder(
//               itemCount: _orders.length,
//               itemBuilder: (context, index) {
//                 final order = _orders[index];
//                 final items = order["items"] as List<dynamic>;
//                 return Card(
//                   margin: const EdgeInsets.all(8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Orden: ${order["order_id"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 8),
//                         ...items.map((item) => Text("- ${item["quantity"]}x ${item["name"]}")),
//                         const SizedBox(height: 10),
//                         Text("Estado: ${order["status"]}"),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             if (order["status"] == "pending")
//                               ElevatedButton(
//                                 onPressed: () => _updateStatus(order["order_id"], "preparing"),
//                                 child: const Text("Preparando"),
//                               ),
//                             const SizedBox(width: 8),
//                             if (order["status"] != "ready")
//                               ElevatedButton(
//                                 onPressed: () => _updateStatus(order["order_id"], "ready"),
//                                 child: const Text("Listo"),
//                               ),
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
