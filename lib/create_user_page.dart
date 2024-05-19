import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State createState() {
    return _CreateUserState();
  }
}

class _CreateUserState extends State<CreateUserPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = '';
  String selectedRole = 'user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutorial Firebase"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Crear Usuario",
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          butonCrearUsuario(),
        ],
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildRoleSelector(),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Correo",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Contraseña",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
        hintText: "Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número",
      ),
      obscureText: true,
      validator: (String? value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        if (!isValidPassword(value)) {
          return "La contraseña no cumple con los requisitos de seguridad";
        }
        return null;
      },
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$");
    return passwordRegex.hasMatch(password);
  }

  Widget buildRoleSelector() {
    return DropdownButton<String>(
      value: selectedRole,
      items: <String>['admin', 'user'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedRole = newValue!;
        });
      },
    );
  }

  Widget butonCrearUsuario() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            UserCredential? credenciales = await crear(email, password, selectedRole);
            if (credenciales != null && credenciales.user != null) {
              await credenciales.user!.sendEmailVerification();
              Navigator.of(context).pop();
            }
          }
        },
        child: const Text("Registrarse"),
      ),
    );
  }

  Future<UserCredential?> crear(String email, String password, String role) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'role': role,
        'email': email,
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          error = "El correo electrónico ya se encuentra en uso.";
        } else if (e.code == 'weak-password') {
          error = "La contraseña es demasiado débil. Por favor, elija una contraseña más segura.";
        } else {
          error = "Error al crear el usuario: ${e.message}";
        }
      });
      return null;
    }
  }
}
