import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:moschee_app/core/logging/app_log.dart';
import 'package:moschee_app/core/services/image_crop_service.dart';

/// Speichert Bilder effizient im App-Verzeichnis.
///
/// - Beim Auswählen schon verkleinert und komprimiert ([maxSize], JPEG).
/// - Gespeichert wird nur der **Dateiname**, nicht der absolute Pfad: Unter
///   iOS ändert sich der Container-Pfad bei Updates/Restores.
/// - [provider] dekodiert nur in Anzeigegröße (spart Arbeitsspeicher).
/// - [removeUnused] räumt verwaiste Dateien auf.
///
/// Für die Cloud: siehe cloud_template/lib/cloud_image_store.dart.
class ImageStore {
  ImageStore._();

  static const maxSize = 1080.0;
  static const quality = 82;
  static const _folder = 'images';

  static late Directory _dir;

  static Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    _dir = Directory(p.join(docs.path, _folder));
    if (!_dir.existsSync()) await _dir.create(recursive: true);
  }

  /// Bild wählen (Galerie/Kamera), optional quadratisch zuschneiden und
  /// speichern. Liefert den Dateinamen oder `null` bei Abbruch.
  static Future<String?> pick(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
    bool cropSquare = true,
    String cropTitle = '',
  }) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxSize,
      maxHeight: maxSize,
      imageQuality: quality,
    );
    if (picked == null) return null;
    var path = picked.path;
    if (cropSquare && context.mounted) {
      final cropped = await ImageCropService.cropSquareImage(
        context: context,
        sourcePath: path,
        title: cropTitle,
      );
      if (cropped == null) return null;
      path = cropped;
    }
    return save(File(path));
  }

  /// Kopiert eine Datei in den Speicher und gibt den neuen Dateinamen zurück.
  static Future<String> save(File source) async {
    final ext = p.extension(source.path).toLowerCase();
    final name = '${const Uuid().v4()}${ext.isEmpty ? '.jpg' : ext}';
    await source.copy(p.join(_dir.path, name));
    return name;
  }

  /// Absoluter Pfad zu einem gespeicherten Bild (alte absolute Pfade
  /// bleiben gültig).
  static String resolve(String nameOrPath) =>
      p.isAbsolute(nameOrPath) ? nameOrPath : p.join(_dir.path, nameOrPath);

  static Future<void> delete(String? nameOrPath) async {
    if (nameOrPath == null || !_isLocal(nameOrPath)) return;
    try {
      final file = File(resolve(nameOrPath));
      if (file.existsSync()) await file.delete();
    } catch (e) {
      AppLog.warn('ImageStore.delete', e);
    }
  }

  /// Löscht alle Bilder, die in [used] nicht mehr vorkommen.
  static Future<void> removeUnused(Iterable<String?> used) async {
    final keep = used.whereType<String>().map(p.basename).toSet();
    await for (final entity in _dir.list()) {
      if (entity is File && !keep.contains(p.basename(entity.path))) {
        await entity.delete();
      }
    }
  }

  /// Passender [ImageProvider] für Dateiname, Asset oder URL.
  static ImageProvider? provider(String? path, {int? decodeWidth}) {
    if (path == null || path.isEmpty) return null;
    final ImageProvider base;
    if (path.startsWith('http')) {
      base = NetworkImage(path); // Cloud: CachedNetworkImageProvider
    } else if (path.startsWith('assets/')) {
      base = AssetImage(path);
    } else {
      final file = File(resolve(path));
      if (!file.existsSync()) return null;
      base = FileImage(file);
    }
    return decodeWidth == null
        ? base
        : ResizeImage(base, width: decodeWidth, policy: ResizeImagePolicy.fit);
  }

  static bool _isLocal(String path) =>
      !path.startsWith('http') && !path.startsWith('assets/');
}
