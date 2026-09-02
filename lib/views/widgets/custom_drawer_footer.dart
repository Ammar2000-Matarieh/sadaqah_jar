import 'package:flutter/material.dart';

class DrawerFooter extends StatelessWidget {
  const DrawerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'الإصدار 1.0.0',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
    );
  }
}
