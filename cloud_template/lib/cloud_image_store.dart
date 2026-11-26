// Nach lib/cloud/ kopieren. Siehe README.md im cloud_template.
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:moschee_app/core/logging/app_log.dart';
import 'package:moschee_app/core/services/image_store.dart';

/// Bilder in Firebase Storage unter `users/{uid}/images/{name}`.
///
/// - Hochgeladen wird die schon verkleinerte Datei aus [ImageStore]
///   (max. 1080 px, JPEG ~82 %) – spart Speicher und Datenvolumen.
/// - Lange Cache-Dauer: Dateinamen sind eindeutig (UUID), ein geändertes
///   Bild bekommt einen neuen Namen, alte URLs ändern sich also nie.
/// - Anzeige über [CachedNetworkImageProvider]: Bilder liegen nach dem
///   ersten Laden auf dem Gerät. In `ImageStore.provider` `NetworkImage`
///   durch [CachedNetworkImageProvider] ersetzen.
abstract final class CloudImageStore {
  static Reference _ref(String name) => FirebaseStorage.instance.ref(
    'users/${FirebaseAuth.instance.currentUser!.uid}/images/$name',
  );

  /// Lädt ein lokal gespeichertes Bild hoch und gibt die Download-URL zurück.
  static Future<String> upload(String localName) async {
    final ref = _ref(localName.split('/').last);
    await ref.putFile(
      File(ImageStore.resolve(localName)),
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000, immutable',
      ),
    );
    return ref.getDownloadURL();
  }

  static Future<void> delete(String? url) async {
    if (url == null || !url.startsWith('http')) return;
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      AppLog.warn('CloudImageStore.delete', e);
    }
  }

  static ImageProvider provider(String url, {int? decodeWidth}) =>
      CachedNetworkImageProvider(url, maxWidth: decodeWidth);
}
