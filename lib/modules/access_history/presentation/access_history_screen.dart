import 'package:flutter/material.dart';

class AccessHistoryScreen extends StatelessWidget {
  const AccessHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange[100],
      child: const Center(
        child: Text('Access History Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
