// Nach lib/cloud/ kopieren. Siehe README.md im cloud_template.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moschee_app/core/data/item_repository.dart';
import 'package:moschee_app/core/models/item.dart';

/// Einträge unter `users/{uid}/items/{id}`.
///
/// - Firestore hält selbst einen Offline-Cache ([CloudSetup] aktiviert ihn);
///   Schreiben klappt offline und wird später synchronisiert.
/// - [watch] liefert Änderungen von anderen Geräten live.
/// - Gelesen wird nur die eigene Sammlung (passt zu firestore.rules).
class FirestoreItemRepository implements ItemRepository {
  FirestoreItemRepository(this.uid);

  /// Ohne Anmeldung keine Cloud: dann `null` und das [DataRepository]
  /// bleibt lokal.
  static FirestoreItemRepository? forCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? null : FirestoreItemRepository(uid);
  }

  final String uid;

  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('items');

  static List<Item> _parse(QuerySnapshot<Map<String, dynamic>> snap) => [
    for (final doc in snap.docs) Item.fromJson({...doc.data(), 'id': doc.id}),
  ];

  @override
  Future<List<Item>> load() async {
    // Erst Cache (sofort), Netz kommt über watch() nach.
    try {
      final cached = await _col.get(const GetOptions(source: Source.cache));
      if (cached.docs.isNotEmpty) return _parse(cached);
    } catch (_) {}
    return _parse(await _col.get());
  }

  @override
  Stream<List<Item>> watch() => _col.snapshots().map(_parse);

  @override
  Future<void> save(Item item) => _col.doc(item.id).set(item.toJson());

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  /// Größere Mengen in Batches (max. 500 Operationen je Batch).
  @override
  Future<void> clear() async {
    final snap = await _col.get();
    for (var i = 0; i < snap.docs.length; i += 500) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs.skip(i).take(500)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Lokale Daten beim ersten Wechsel in die Cloud übernehmen.
  /// Bilder vorher mit [CloudImageStore.upload] hochladen und die
  /// `imagePath` durch die URL ersetzen.
  Future<void> importAll(List<Item> items) async {
    for (var i = 0; i < items.length; i += 500) {
      final batch = FirebaseFirestore.instance.batch();
      for (final item in items.skip(i).take(500)) {
        batch.set(_col.doc(item.id), item.toJson());
      }
      await batch.commit();
    }
  }
}
