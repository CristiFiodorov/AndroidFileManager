import 'dart:io';
import 'package:path/path.dart' as p;

class FileOperations {
  static void deleteEntity(FileSystemEntity entity) {
    if (entity is Directory) {
      entity.deleteSync(recursive: true);
    } else if (entity is File) {
      entity.deleteSync();
    }
  }

  static void renameEntity(FileSystemEntity entity, String newName) {
    String newPath = '${entity.parent.path}/$newName';
    entity.renameSync(newPath);
  }

  static Future<String> readTextFile(File file) async {
    try {
      String name = file.path.split('/').last;
      if (name.endsWith(".txt")) {
        return await file.readAsString();
      } else {
        return 'Error: File is not a text file.';
      }
    } catch (e) {
      return 'Error: Could not read file - ${e.toString()}';
    }
  }

  static Future<List<int>> readBinaryFile(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      return [];
    }
  }

  static Future<void> createNewEntity(
      Directory currentDirectory, String entityName, String entityType) async {
    if (entityType == "File") {
      String filePath = "${currentDirectory.path}/$entityName";
      File file = File(filePath);
      if (!await file.exists()) {
        await file.create();
      }
    } else if (entityType == "Folder") {
      String folderPath = "${currentDirectory.path}/$entityName";
      Directory directory = Directory(folderPath);
      if (!await directory.exists()) {
        await directory.create();
      }
    }
  }

  static Future<void> copyEntity(
      FileSystemEntity entity, Directory targetDir) async {
    if (entity is Directory) {
      _copyDirectory(entity, targetDir);
    } else if (entity is File) {
      _copyFile(entity, targetDir);
    }
  }

  static Future<void> _copyFile(
      File sourceFile, Directory targetDirectory) async {
    try {
      File targetFile =
          File('${targetDirectory.path}/${p.basename(sourceFile.path)}');
      await sourceFile.copy(targetFile.path);
    } catch (e) {
      print('Failed to copy file: $e');
    }
  }

  static Future<void> _copyDirectory(
      Directory sourceDir, Directory targetDir) async {
    try {
      await Directory('${targetDir.path}/${p.basename(sourceDir.path)}')
          .create(recursive: true);
      await for (var entity in sourceDir.list()) {
        if (entity is File) {
          await _copyFile(entity,
              Directory('${targetDir.path}/${p.basename(sourceDir.path)}'));
        } else if (entity is Directory) {
          await _copyDirectory(entity,
              Directory('${targetDir.path}/${p.basename(sourceDir.path)}'));
        }
      }
    } catch (e) {
      print('Failed to copy directory: $e');
    }
  }

  static Future<void> moveEntity(
      FileSystemEntity entity, Directory targetDir) async {
    if (entity is Directory) {
      _moveDirectory(entity, targetDir);
    } else if (entity is File) {
      _moveFile(entity, targetDir);
    }
  }

  static Future<void> _moveFile(
      File sourceFile, Directory targetDirectory) async {
    try {
      File targetFile =
          File('${targetDirectory.path}/${p.basename(sourceFile.path)}');
      await sourceFile.rename(targetFile.path);
    } catch (e) {
      print('Failed to move file: $e');
    }
  }

  static Future<void> _moveDirectory(
      Directory sourceDir, Directory targetDir) async {
    try {
      await sourceDir.rename('${targetDir.path}/${p.basename(sourceDir.path)}');
    } catch (e) {
      print('Failed to move directory: $e');
    }
  }
}
