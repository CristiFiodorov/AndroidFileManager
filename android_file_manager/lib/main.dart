import 'package:flutter/material.dart';
import 'file_manager_screen.dart';

void main() {
  runApp(FileManagerApp());
}

class FileManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FileManagerScreen(),
    );
  }
}
