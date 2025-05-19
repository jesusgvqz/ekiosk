import 'package:ekiosk/core/theme_config.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/themed_scaffold.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  Color _backgroundColor = Colors.black;
  Color _textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      body: Container(
        color: _backgroundColor,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Personaliza la apariencia de la app", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Color de fondo: "),
                const SizedBox(width: 10),
                _buildColorSelector(Colors.black),
                _buildColorSelector(Colors.white),
                _buildColorSelector(Colors.blueGrey),
                _buildColorSelector(Colors.deepPurple),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Color de texto: "),
                const SizedBox(width: 10),
                _buildColorSelector(Colors.white, isText: true),
                _buildColorSelector(Colors.black, isText: true),
                _buildColorSelector(Colors.amber, isText: true),
                _buildColorSelector(Colors.tealAccent, isText: true),
              ],
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ThemeConfig.backgroundColor = _backgroundColor;
                ThemeConfig.textColor = _textColor;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tema aplicado")),
                );
              },
              child: const Text("Aplicar tema"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(Color color, {bool isText = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isText) {
            _textColor = color;
          } else {
            _backgroundColor = color;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.grey),
        ),
      ),
    );
  }
}
