import 'package:flutter/material.dart';

void main() {
  runApp(const Cnetrally());
}

class Cnetrally extends StatelessWidget {
  const Cnetrally({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cnetrally',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(body: Center(child: Text('Hello, Cnetrally!'))),
    );
  }
}
