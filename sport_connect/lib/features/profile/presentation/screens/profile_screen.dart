import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Perfil — TASK-031')),
    );
  }
}
