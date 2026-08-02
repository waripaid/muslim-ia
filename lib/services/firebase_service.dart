import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  bool get isAuthenticated => _auth.currentUser != null;

  // ── USER PROFILE ──────────────────────────────────────────

  Future<void> saveUserData(Map<String, dynamic> data) async {
    final uid = userId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = userId;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── LEARNING PROGRESS ─────────────────────────────────────

  Future<void> saveProgress(Map<String, dynamic> progress) async {
    final uid = userId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).collection('progress').doc('learning').set({
      ...progress,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProgress() async {
    final uid = userId;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).collection('progress').doc('learning').get();
    return doc.data();
  }

  // ── VOCABULARY ────────────────────────────────────────────

  Future<void> saveVocabulary(List<Map<String, dynamic>> words) async {
    final uid = userId;
    if (uid == null) return;
    final batch = _firestore.batch();
    final col = _firestore.collection('users').doc(uid).collection('vocabulary');
    for (final w in words) {
      batch.set(col.doc(w['arabic']), { ...w, 'updatedAt': FieldValue.serverTimestamp() }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getVocabulary() async {
    final uid = userId;
    if (uid == null) return [];
    final snapshot = await _firestore.collection('users').doc(uid).collection('vocabulary').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // ── MEMORIZATION ──────────────────────────────────────────

  Future<void> saveMemorization(List<Map<String, dynamic>> verses) async {
    final uid = userId;
    if (uid == null) return;
    final batch = _firestore.batch();
    final col = _firestore.collection('users').doc(uid).collection('memorization');
    for (final v in verses) {
      batch.set(col.doc(v['reference']), { ...v, 'updatedAt': FieldValue.serverTimestamp() }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getMemorization() async {
    final uid = userId;
    if (uid == null) return [];
    final snapshot = await _firestore.collection('users').doc(uid).collection('memorization').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // ── FAVORITES ─────────────────────────────────────────────

  Future<void> addFavorite(Map<String, dynamic> favorite) async {
    final uid = userId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).collection('favorites').add({
      ...favorite,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final uid = userId;
    if (uid == null) return [];
    final snapshot = await _firestore.collection('users').doc(uid).collection('favorites')
        .orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((d) => { 'id': d.id, ...d.data() }).toList();
  }

  Future<void> removeFavorite(String id) async {
    final uid = userId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).collection('favorites').doc(id).delete();
  }

  // ── ACHIEVEMENTS ──────────────────────────────────────────

  Future<void> saveAchievements(List<Map<String, dynamic>> achievements) async {
    final uid = userId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'achievements': achievements,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── CHAT HISTORY ──────────────────────────────────────────

  Future<void> saveChatMessage(Map<String, dynamic> message) async {
    final uid = userId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).collection('chats').add({
      ...message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getChatHistory({int limit = 50}) async {
    final uid = userId;
    if (uid == null) return [];
    final snapshot = await _firestore.collection('users').doc(uid).collection('chats')
        .orderBy('createdAt', descending: true).limit(limit).get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // ── COMPLETE SYNC ─────────────────────────────────────────

  Future<void> syncAll({
    Map<String, dynamic>? userData,
    Map<String, dynamic>? progress,
    List<Map<String, dynamic>>? vocabulary,
    List<Map<String, dynamic>>? memorization,
    List<Map<String, dynamic>>? achievements,
  }) async {
    if (userId == null) return;
    if (userData != null) await saveUserData(userData);
    if (progress != null) await saveProgress(progress);
    if (vocabulary != null) await saveVocabulary(vocabulary);
    if (memorization != null) await saveMemorization(memorization);
    if (achievements != null) await saveAchievements(achievements);
  }
}
