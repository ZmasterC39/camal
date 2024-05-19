import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iscocongacamal/login_page.dart';

class PublicUserPage extends StatefulWidget {
  const PublicUserPage({super.key});

  @override
  _PublicUserPageState createState() => _PublicUserPageState();
}

class _PublicUserPageState extends State<PublicUserPage> {
  final _formKey = GlobalKey<FormState>();
  late String supplierName, specieAnimal;
  late String description, dni;
  String feedbackMessage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Animal"),
        actions: [
          InkWell(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.exit_to_app),
            ),
          ),
          // Add the button to navigate to MapScreen
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Go to Map'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Registrar Nuevo Animal",
                style: TextStyle(fontSize: 24),
              ),
            ),
            if (feedbackMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  feedbackMessage,
                  style: TextStyle(color: feedbackMessage.startsWith('Error') ? Colors.red : Colors.green, fontSize: 16),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildSupplierNameField(),
                    const Padding(padding: EdgeInsets.only(top: 12)),
                    buildDniField(),
                    const Padding(padding: EdgeInsets.only(top: 12)),
                    buildAnimalTypeField(),
                    const Padding(padding: EdgeInsets.only(top: 12)),
                    buildDescriptionField(),
                    const Padding(padding: EdgeInsets.only(top: 12)),
                    buildSubmitButton(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Mis Registros"),
            buildUserRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget buildSupplierNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Nombre Proveedor",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onSaved: (String? value) {
        supplierName = value!;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }
  Widget buildDniField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "DNI Proveedor",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onSaved: (String? value) {
        dni = value!;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildAnimalTypeField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Tipo de Animal",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onSaved: (String? value) {
        specieAnimal = value!;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Numero de animales",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onSaved: (String? value) {
        description = value! ;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildSubmitButton() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            await crearRegistroAnimal();
          }
        },
        child: const Text("Enviar Registro"),
      ),
    );
  }

  Future<void> crearRegistroAnimal() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('animal_records').add({
          'userId': user.uid,
          'supplierName': supplierName,
          'dni': dni,
          'specieAnimal': specieAnimal,
          'description': description,
          'status': 'pendiente',
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          feedbackMessage = "Registro enviado correctamente.";
        });
      } else {
        setState(() {
          feedbackMessage = "Error: Usuario no autenticado.";
        });
      }
    } catch (e) {
      setState(() {
        feedbackMessage = "Error al enviar el registro: $e";
      });
    }
  }

  Widget buildUserRecordsList() {
    User? user = _auth.currentUser;
    if (user == null) {
      return const Text("Error: Usuario no autenticado.");
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('animal_records')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error al cargar los registros.");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final records = snapshot.data?.docs ?? [];
        return ListView.builder(
          shrinkWrap: true,
          itemCount: records.length,
          itemBuilder: (context, index) {
            var record = records[index];
            return ListTile(
              title: Text(record['supplierName']),
              subtitle: Text(record['specieAnimal' ]),
              trailing: record['status'] == 'pendiente'
                  ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditAnimalRecordDialog(record: record),
                  );
                },
              )
                  : const Text('Aceptado'),
            );
          },
        );
      },
    );
  }
}

class EditAnimalRecordDialog extends StatefulWidget {
  final DocumentSnapshot record;

  const EditAnimalRecordDialog({super.key, required this.record});

  @override
  _EditAnimalRecordDialogState createState() => _EditAnimalRecordDialogState();
}

class _EditAnimalRecordDialogState extends State<EditAnimalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late String supplierName, specieAnimal;
  late String description, dni;

  @override
  void initState() {
    super.initState();
    supplierName = widget.record['supplierName'];
    dni = widget.record['dni'];
    specieAnimal = widget.record['specieAnimal'];
    description = widget.record['description'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Registro de Animal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: supplierName,
              decoration: const InputDecoration(labelText: 'Nombre del Proveedor'),
              onSaved: (value) => supplierName = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Este campo es obligatorio";
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: specieAnimal,
              decoration: const InputDecoration(labelText: 'Especie del Animal'),
              onSaved: (value) => specieAnimal = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Este campo es obligatorio";
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: description,
              decoration: const InputDecoration(labelText: 'Descripción'),
              onSaved: (value) => description = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Este campo es obligatorio";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await widget.record.reference.update({
                'supplierName': supplierName,
                'dni':dni,
                'specieAnimal': specieAnimal,
                'description': description,
              });
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

}
