import 'package:flutter/material.dart';
import 'metaball_switch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Wrap with MaterialApp
      title: 'Toggle Switch Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Toggle Switch Example'),
        ),
        body: const Center(
          child: MetaballSwitch(),
        ),
      ),
    );
  }
}
