import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminCreateRecordPage extends StatefulWidget {
  const AdminCreateRecordPage({super.key});

  @override
  _AdminCreateRecordPageState createState() => _AdminCreateRecordPageState();
}

class _AdminCreateRecordPageState extends State<AdminCreateRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late String supplierName, specieAnimal;
  late String description, dni;
  String feedbackMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Registro de Animal"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Crear Nuevo Registro",
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
                    builsupplierNameField(),
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
          ],
        ),
      ),
    );
  }

  Widget builsupplierNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Nombre proveedor",
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
        labelText: "DNI proveedor",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onSaved: (String? value) {
        dni = value! ;
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
        labelText: "Especie Animal",
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
        labelText: "Descripción",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onSaved: (String? value) {
        description = value!;
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
        child: const Text("Crear Registro"),
      ),
    );
  }

  Future<void> crearRegistroAnimal() async {
    try {
      await FirebaseFirestore.instance.collection('animal_records').add({
        'supplierName': supplierName,
        'dni': dni,
        'SpecieAnimal': specieAnimal,
        'description': description,
        'status': 'aceptado',
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        feedbackMessage = "Registro creado correctamente.";
      });
    } catch (e) {
      setState(() {
        feedbackMessage = "Error al crear el registro: $e";
      });
    }
  }
}
