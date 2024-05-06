import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ChooseFolderScreen extends StatefulWidget {
  final Directory currentDirectory;
  final FileSystemEntity entity;
  final Future<void> Function(FileSystemEntity entity, Directory targetDir)
      action;
  final Icon icon;

  const ChooseFolderScreen(
      {required this.currentDirectory,
      required this.entity,
      required this.action,
      required this.icon});

  @override
  _ChooseFolderScreenState createState() => _ChooseFolderScreenState();
}

class _ChooseFolderScreenState extends State<ChooseFolderScreen> {
  late Directory currentDirectory;
  late Directory? parentDirectory;

  @override
  void initState() {
    super.initState();
    currentDirectory = widget.currentDirectory;
    _updateParentDirectory();
  }

  void _updateParentDirectory() {
    setState(() {
      parentDirectory = currentDirectory.parent;
      if (parentDirectory?.path == currentDirectory.path) {
        parentDirectory = null;
      } else {
        try {
          parentDirectory!.listSync();
        } catch (e) {
          print("No access to parent directory: ${e.toString()}");
          parentDirectory = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Directory> fileSystemEntities;
    try {
      fileSystemEntities =
          currentDirectory.listSync().whereType<Directory>().toList();
      if (parentDirectory != null) {
        fileSystemEntities.insert(0, Directory(parentDirectory!.path));
      }

      fileSystemEntities
          .removeWhere((element) => element.path == widget.entity.path);
    } catch (e) {
      return Scaffold(
          appBar: AppBar(title: const Text('File Manager')),
          body: const Center(child: Text('Unable to access this directory.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(currentDirectory.path)),
      ),
      body: ListView.builder(
        itemCount: fileSystemEntities.length,
        itemBuilder: (context, index) {
          var fileEntity = fileSystemEntities[index];
          const Icon icon = Icon(Icons.folder, color: Colors.yellow);
          String name = fileEntity.path.split('/').last;
          FileStat fileEntityStat = fileEntity.statSync();
          String formattedDate =
              DateFormat('yyyy-MM-dd – kk:mm').format(fileEntityStat.modified);

          if (parentDirectory != null &&
              name == p.basename(parentDirectory!.path)) {
            name = "..";
          }

          return ListTile(
              leading: icon,
              title: Text(name),
              subtitle: Text(formattedDate),
              onTap: () {
                setState(() {
                  currentDirectory = fileEntity;
                  _updateParentDirectory();
                });
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.action(widget.entity, currentDirectory);
          Navigator.of(context).pop();
        },
        child: widget.icon,
      ),
    );
  }
}
