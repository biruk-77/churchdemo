import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:church/core/constants/app_constants.dart';
import 'package:church/features/church/data/church_model.dart';
import 'package:church/features/church/data/woreda_model.dart';

final churchRepositoryProvider = Provider((ref) => ChurchRepository());

class ChurchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all dioceses
  Future<List<Map<String, dynamic>>> getDioceses() async {
    try {
      final snapshot = await _firestore.collection('dioceses').get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      return [];
    }
  }

  // Get woredas for a specific diocese
  Future<List<WoredaModel>> getWoredas(String dioceseId) async {
    try {
      final snapshot = await _firestore
          .collection('churches')
          .where('dioceseId', isEqualTo: dioceseId)
          .get();

      final woredaMap = <String, WoredaModel>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final woredaId = data['woreda'] as String?;
        final woredaName = data['woredaName'] as String?;

        if (woredaId != null && woredaName != null) {
          woredaMap[woredaId] = WoredaModel(
            id: woredaId,
            name: woredaName,
            dioceseName: data['dioceseName'] ?? '',
            dioceseId: dioceseId,
          );
        }
      }

      return woredaMap.values.toList();
    } catch (e) {
      return [];
    }
  }

  // Get churches for a specific woreda
  Future<List<ChurchModel>> getChurchesByWoreda(String dioceseId, String woredaId) async {
    try {
      final snapshot = await _firestore
          .collection('churches')
          .where('dioceseId', isEqualTo: dioceseId)
          .where('woreda', isEqualTo: woredaId)
          .get();

      return snapshot.docs
          .map((doc) => ChurchModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ChurchModel>> getChurches() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.churchesCollection).get();
      return snapshot.docs
          .map((doc) => ChurchModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<ChurchModel?> getChurchById(String id) async {
    try {
      final doc = await _firestore.collection(AppConstants.churchesCollection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return ChurchModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> incrementMemberCount(String id) async {
    try {
      await _firestore.collection(AppConstants.churchesCollection).doc(id).update({
        'memberCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }
}
