import 'package:flutter/material.dart';

class OrgDashboardScreen extends StatelessWidget {
  const OrgDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المنظمة'),
      ),
      body: const Center(
        child: Text('لوحة تحكم المنظمة - قيد التطوير'),
      ),
    );
  }
}
