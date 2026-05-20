import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gold_data.dart';

class FirestoreService {
  static const String _collection = 'preise';
  static const String _docId = 'n6SFfgb2zkKYG6LswSqf';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<GoldData> fetchGold21k() async {
    final doc = await _db.collection(_collection).doc(_docId).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Kein Firebase-Dokument gefunden.');
    }
    return GoldData.fromMap(doc.data()!);
  }

  Future<void> updateGold21k(double value) async {
    await _db.collection(_collection).doc(_docId).update({'gold_21k': value});
  }

  /// Writes a timestamp to Firebase whenever the refresh button is pressed.
  Future<void> logRefreshPressed() async {
    await _db.collection(_collection).doc(_docId).update({
      'refresh_zuletzt_gedrueckt': FieldValue.serverTimestamp(),
    });
  }
}
