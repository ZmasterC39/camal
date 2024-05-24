import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('animal_records').where('status', isEqualTo: 'pendiente').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data!.docs;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text(record['supplierName']),
                subtitle: Text(record['specieAnimal']),
                trailing: Text(record['description']),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RecordDetailsPage(recordId: record.id)));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class RecordDetailsPage extends StatelessWidget {
  final String recordId;

  const RecordDetailsPage({required this.recordId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Registro"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('animal_records').doc(recordId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final record = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre del proveedor: ${record['supplierName']}', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Especie: ${record['specieAnimal']}', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Numero de animales: ${record['description']}', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Estado: ${record['status']}', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await actualizarEstadoRegistro(recordId, 'aceptado');
                        Navigator.pop(context);
                      },
                      child: const Text("Aceptar"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await actualizarEstadoRegistro(recordId, 'rechazado');
                        Navigator.pop(context);
                      },
                      child: const Text("Rechazar"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> actualizarEstadoRegistro(String recordId, String status) async {
    await FirebaseFirestore.instance.collection('animal_records').doc(recordId).update({'status': status});
  }



  Future<void> eliminarRegistro(String recordId) async {
    await FirebaseFirestore.instance.collection('animal_records').doc(recordId).delete();
  }
}
