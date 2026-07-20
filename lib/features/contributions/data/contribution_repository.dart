import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/core/constants/app_constants.dart';
import 'package:church/features/contributions/data/contribution_model.dart';

class ContributionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createContribution(ContributionModel contribution) async {
    await _firestore
        .collection(AppConstants.contributionsCollection)
        .doc(contribution.id)
        .set(contribution.toMap());
  }

  Future<List<ContributionModel>> getContributionsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.contributionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => ContributionModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateContributionStatus(String id, String status) async {
    await _firestore
        .collection(AppConstants.contributionsCollection)
        .doc(id)
        .update({'status': status});
  }
}
