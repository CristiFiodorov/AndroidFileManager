import 'dart:convert';

import 'package:android_file_manager/file_operations.dart';
import 'package:android_file_manager/utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class TextEditorScreen extends StatefulWidget {
  final File file;

  TextEditorScreen({required this.file});

  @override
  _TextEditorScreenState createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  late TextEditingController _controller;
  bool base16 = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadText();
  }

  void _loadText() async {
    List<int> fileContent = await FileOperations.readBinaryFile(widget.file);
    if (base16) {
      _controller.text = bytesToHex(fileContent);
    } else {
      _controller.text = await bytesToAnsi(fileContent);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> convert() async {
    if (!base16) {
      _controller.text = await hexToAnsi(_controller.text);
    } else {
      _controller.text = await ansiToHex(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.file.path.split('/').last}'),
        actions: [
          Switch(
              value: base16,
              onChanged: (b) => {
                    setState(() {
                      base16 = b;
                      convert();
                    })
                  }),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Start editing...',
          ),
        ),
      ),
    );
  }

  void _saveFile() async {
    if (base16) {
      await widget.file.writeAsBytes(hexToBytes(_controller.text));
    } else {
      await widget.file.writeAsBytes(await ansiToBytes(_controller.text));
    }
    Navigator.pop(context);
  }
}
