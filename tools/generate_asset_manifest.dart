import 'dart:io';
import 'dart:convert';

void main() async {
  final assetsDir = Directory('assets/knowledge_base');
  if (!await assetsDir.exists()) {
    print('Error: assets/knowledge_base directory not found.');
    return;
  }

  final manifest = <String, dynamic>{};
  await for (final entity in assetsDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.md')) {
      final pathParts = entity.path.split(Platform.pathSeparator).sublist(2);
      _addPathToManifest(manifest, pathParts);
    }
  }

  final manifestFile = File('assets/asset_manifest.json');
  await manifestFile.writeAsString(json.encode(manifest));

  print('Asset manifest generated at assets/asset_manifest.json');
}

void _addPathToManifest(Map<String, dynamic> manifest, List<String> pathParts) {
  if (pathParts.length == 1) {
    manifest[pathParts.first] = 'file';
  } else {
    final directory = pathParts.first;
    if (!manifest.containsKey(directory)) {
      manifest[directory] = <String, dynamic>{};
    }
    _addPathToManifest(manifest[directory], pathParts.sublist(1));
  }
}
