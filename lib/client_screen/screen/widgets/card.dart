import 'package:attendance_app/client_screen/model/model.dart';
import 'package:attendance_app/client_screen/screen/update_client.dart';
import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: client.profilePicture.startsWith('http')
              ? NetworkImage(client.profilePicture)
              : null,
          backgroundColor: Colors.grey[200],
          child: client.profilePicture.startsWith('http')
              ? null
              : const Icon(Icons.person, size: 32, color: Colors.grey),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(client.phone),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
        onTap: () {
          // Navigate to client details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientDetailsScreen(client: client),
            ),
          );
        },
      ),
    );
  }
}