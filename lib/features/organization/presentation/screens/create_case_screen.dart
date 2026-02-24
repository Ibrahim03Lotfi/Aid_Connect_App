import 'package:flutter/material.dart';

class CreateCaseScreen extends StatelessWidget {
  const CreateCaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حالة جديدة'),
      ),
      body: const Center(
        child: Text('شاشة إنشاء حالة - قيد التطوير'),
      ),
    );
  }
}
