import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final assetsDir = Directory('assets/knowledge_base');
  if (!await assetsDir.exists()) {
    print('Error: assets/knowledge_base directory not found.');
    return;
  }

  final manifest = await _processDirectory(assetsDir);

  final manifestFile = File('assets/asset_manifest.json');
  await manifestFile.writeAsString(json.encode(manifest));

  print('Asset manifest generated at assets/asset_manifest.json');
}

Future<List<Map<String, dynamic>>> _processDirectory(Directory dir) async {
  final orderFile = File('${dir.path}${Platform.pathSeparator}.order');
  List<String> orderedNames = [];
  if (await orderFile.exists()) {
    orderedNames = (await orderFile.readAsLines())
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  final entities = await dir.list().toList();
  final manifest = <Map<String, dynamic>>[];

  final entityMap = <String, FileSystemEntity>{};
  for (final entity in entities) {
    final name = entity.path.split(Platform.pathSeparator).last;
    entityMap[name] = entity;
  }

  for (final name in orderedNames) {
    final entity = entityMap[name];
    if (entity != null) {
      await _addEntityToManifest(entity, manifest);
      entityMap.remove(name);
    }
  }

  final remainingEntities = entityMap.values.toList();
  remainingEntities.sort((a, b) =>
      a.path.split(Platform.pathSeparator).last.compareTo(b.path.split(Platform.pathSeparator).last));

  for (final entity in remainingEntities) {
    await _addEntityToManifest(entity, manifest);
  }

  return manifest;
}

Future<void> _addEntityToManifest(
    FileSystemEntity entity, List<Map<String, dynamic>> manifest) async {
  final name = entity.path.split(Platform.pathSeparator).last;

  if (name == '.order') {
    return;
  }

  if (entity is Directory) {
    manifest.add({
      'name': name,
      'type': 'directory',
      'children': await _processDirectory(entity),
    });
  } else if (entity is File && entity.path.endsWith('.md')) {
    manifest.add({
      'name': name,
      'type': 'file',
    });
  }
}
