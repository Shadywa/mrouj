import 'package:attendance_app/client_screen/model/model.dart';
import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person, size: 32, color: Colors.grey),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(client.phone),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
      ),
    );
  }
}