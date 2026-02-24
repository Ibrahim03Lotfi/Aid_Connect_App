import 'package:flutter/material.dart';

class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المتطوع'),
      ),
      body: const Center(
        child: Text('لوحة تحكم المتطوع - قيد التطوير'),
      ),
    );
  }
}
