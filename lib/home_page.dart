import 'package:flutter/material.dart';
import 'public_user_page.dart';
import 'notificaciones_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página Principal"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PublicUserPage()));
              },
              child: const Text("Registrar Animal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificacionesPage()));
              },
              child: const Text("Notificaciones"),
            ),
          ],
        ),
      ),
    );
  }
}
