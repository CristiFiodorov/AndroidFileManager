import 'package:android_file_manager/choose_folder_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'file_operations.dart';
import 'text_editor_screen.dart';
import 'package:path/path.dart' as p;

class FileManagerScreen extends StatefulWidget {
  @override
  _FileManagerScreenState createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  late Directory currentDirectory;
  late Directory? parentDirectory;

  void refreshUI() {
    setState(() {
      // Refresh the UI to show the new state
    });
  }

  @override
  void initState() {
    super.initState();
    _initDirectory();
  }

  _initDirectory() async {
    currentDirectory = Directory('/storage/emulated/0');
    _updateParentDirectory();
  }

  void _updateCurrentDirectory(Directory directory) {
    setState(() {
      try {
        directory.listSync();
        currentDirectory = directory;
      } catch (e) {
        print("No access to directory: ${e.toString()}");
      }
    });
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

  bool isDirectoryAccesible(Directory directory) {
    try {
      directory.listSync();
      return true;
    } catch (e) {
      return false;
    }
  }

  void showAddFileDialog() {
    TextEditingController fileNameController = TextEditingController();
    String fileType = "File";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Add New File"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fileNameController,
                      decoration:
                          const InputDecoration(hintText: "Enter file name"),
                    ),
                    DropdownButton<String>(
                      value: fileType,
                      onChanged: (String? newValue) {
                        setState(() {
                          fileType = newValue!;
                        });
                      },
                      items: <String>['File', 'Folder']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      FileOperations.createNewEntity(currentDirectory,
                              fileNameController.text, fileType)
                          .then((_) {
                        refreshUI();
                      });
                    },
                    child: const Text("Create"),
                  ),
                ],
              );
            },
          );
        });
  }

  void deleteEntity(FileSystemEntity entity) {
    String entityType =
        entity is Directory ? "folder and all its contents" : "file";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete $entityType"),
          content: Text(
              "Are you sure you want to delete this $entityType? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FileOperations.deleteEntity(entity);
                setState(() {});
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void showRenameDialog(FileSystemEntity entity) {
    String initialName = entity.path.split('/').last;

    TextEditingController newNameController =
        TextEditingController(text: initialName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rename ${entity is File ? 'File' : 'Folder'}"),
          content: TextField(
            controller: newNameController,
            decoration: const InputDecoration(hintText: "Enter new name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                String newName = newNameController.text;
                FileOperations.renameEntity(entity, newName);
                setState(() {});
              },
              child: const Text("Rename"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void showActionsDialog(FileSystemEntity entity) {
    String initialName = entity.path.split('/').last;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('File Actions: $initialName'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showRenameDialog(entity);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteEntity(entity);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChooseFolderScreen(
                              currentDirectory: currentDirectory,
                              entity: entity,
                              action: FileOperations.copyEntity,
                              icon: const Icon(Icons.copy))),
                    ).then((_) => setState(() {}));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.drive_file_move),
                  title: const Text('Move'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChooseFolderScreen(
                              currentDirectory: currentDirectory,
                              entity: entity,
                              action: FileOperations.moveEntity,
                              icon: const Icon(Icons.drive_file_move))),
                    ).then((_) => setState(() {}));
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      var fileSystemEntities = currentDirectory.listSync().where((element) {
        if (element is Directory) {
          return isDirectoryAccesible(element);
        }
        return true;
      }).toList();
      if (parentDirectory != null) {
        fileSystemEntities.insert(0, Directory(parentDirectory!.path));
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(p.basename(currentDirectory.path)),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                onPressed: showAddFileDialog,
                tooltip: 'Add File',
                icon: const Icon(Icons.insert_drive_file),
              ),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: fileSystemEntities.length,
          itemBuilder: (context, index) {
            var fileEntity = fileSystemEntities[index];
            Icon icon;
            String name = fileEntity.path.split('/').last;
            FileStat fileEntityStat = fileEntity.statSync();
            String formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                .format(fileEntityStat.modified);

            if (fileEntity is File) {
              icon = const Icon(Icons.description, color: Colors.blue);
              if (!name.endsWith('.txt')) {
                icon = const Icon(Icons.description);
              }
            } else if (fileEntity is Directory) {
              if (parentDirectory != null &&
                  name == p.basename(parentDirectory!.path)) {
                name = "..";
              }
              icon = const Icon(Icons.folder, color: Colors.yellow);
            } else {
              icon = const Icon(Icons.device_unknown, color: Colors.grey);
            }

            return ListTile(
              leading: icon,
              title: Text(name),
              subtitle: Text(formattedDate),
              trailing: name != ".."
                  ? IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: () => showActionsDialog(fileEntity),
                    )
                  : null,
              onTap: () async {
                if (fileEntity is File) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TextEditorScreen(file: fileEntity)),
                  ).then((_) => setState(() {}));
                } else if (fileEntity is Directory) {
                  setState(() {
                    _updateCurrentDirectory(fileEntity);
                    _updateParentDirectory();
                  });
                }
              },
            );
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: showAddFileDialog,
        //   tooltip: 'Add File',
        //   child: const Icon(Icons.add),
        // ),
      );
    } catch (e) {
      return Scaffold(
          appBar: AppBar(title: const Text('File Manager')),
          body: const Center(child: Text('Unable to access this directory.')));
    }
  }
}
