import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iscocongacamal/login_page.dart';


class AdminCreateRecordPage extends StatefulWidget {
  const AdminCreateRecordPage({super.key});

  @override
  _AdminCreateRecordPageState createState() => _AdminCreateRecordPageState();
}

class _AdminCreateRecordPageState extends State<AdminCreateRecordPage> {
  final _formKey = GlobalKey<FormState>();
  String supplierName = '', specieAnimal = '', description = '', dni = '';
  String feedbackMessage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _animalTypes = ['Bovino', 'Caprino', 'Porcino', 'Otros'];

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
          ],
        ),
      ),
    );
  }

  Future<List<String>> getSupplierNames() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('animal_records').get();
    List<String> supplierNames = [];
    for (var doc in querySnapshot.docs) {
      if (doc['supplierName'] != null) {
        supplierNames.add(doc['supplierName']);
      }
    }
    return supplierNames;
  }

  Widget buildSupplierNameField() {
    return FutureBuilder<List<String>>(
      future: getSupplierNames(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return snapshot.data!.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              setState(() {
                supplierName = selection;
              });
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: "Nombre del Proveedor",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    supplierName = value;
                  });
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Text('Error al cargar los nombres de los proveedores.');
        } else {
          return const CircularProgressIndicator();
        }
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
        dni = value ?? '';
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
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Tipo de Animal",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      items: _animalTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue == 'Otros') {
          _showOtherAnimalDialog();
        } else {
          setState(() {
            specieAnimal = newValue!;
          });
        }
      },
      onSaved: (String? value) {
        specieAnimal = value!;
      },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  void _showOtherAnimalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String otherAnimal = '';
        return AlertDialog(
          title: const Text('Especificar Tipo de Animal'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Especificar otro tipo de animal',
            ),
            onChanged: (value) {
              otherAnimal = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  specieAnimal = otherAnimal;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
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
        child: const Text("Enviar Registro"),
      ),
    );
  }

  Future<void> crearRegistroAnimal() async {
    try {
      await FirebaseFirestore.instance.collection('animal_records').add({
        'supplierName': supplierName,
        'dni': dni,
        'specieAnimal': specieAnimal,
        'description': description,
        'status': 'pendiente',  // Cambiado a "pendiente"
        'createdAt': FieldValue.serverTimestamp(),
        'sentAt': FieldValue.serverTimestamp(),
        'userEmail': FirebaseAuth.instance.currentUser?.email,
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
