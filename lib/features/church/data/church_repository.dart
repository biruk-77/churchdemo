import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/core/constants/app_constants.dart';
import 'package:church/features/church/data/church_model.dart';

class ChurchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock list of prominent churches for demonstration or if Firestore is empty
  static final List<ChurchModel> _mockChurches = [
    ChurchModel(
      id: 'bole_medhanealem',
      name: 'Bole Medhane Alem (ቦሌ መድኃኔዓለም)',
      location: 'Addis Ababa, Bole',
      diocese: 'Addis Ababa (አዲስ አበባ)',
      memberCount: 14500,
    ),
    ChurchModel(
      id: 'holy_trinity',
      name: 'Holy Trinity Cathedral (ቅድስት ሥላሴ ካቴድራል)',
      location: 'Addis Ababa, Arat Kilo',
      diocese: 'Addis Ababa (አዲስ አበባ)',
      memberCount: 8900,
    ),
    ChurchModel(
      id: 'debre_libanos',
      name: 'Debre Libanos Monastery (ደብረ ሊባኖስ ገዳም)',
      location: 'North Shewa',
      diocese: 'Shewa Diocese (ሸዋ ሀገረ ስብከት)',
      memberCount: 3500,
      isMonastery: true,
    ),
    ChurchModel(
      id: 'axum_tsion',
      name: 'Axum Tsion (አክሱም ጽዮን ማርያም)',
      location: 'Axum',
      diocese: 'Tigray Diocese (ትግራይ ሀገረ ስብከት)',
      memberCount: 12000,
    ),
    ChurchModel(
      id: 'gishen_maryam',
      name: 'Debre Kerbe Gishen Maryam (ደብረ ከርቤ ግሸን ማርያም)',
      location: 'Wollo, Ambassel',
      diocese: 'Wollo Diocese (ወሎ ሀገረ ስብከት)',
      memberCount: 4200,
      isMonastery: true,
    ),
    ChurchModel(
      id: 'lalibela_giyorgis',
      name: 'Bet Giyorgis Lalibela (ቤተ ጊዮርጊስ ላሊበላ)',
      location: 'Lasta, Lalibela',
      diocese: 'Lasta Diocese (ላስታ ሀገረ ስብከት)',
      memberCount: 5600,
    ),
  ];

  Future<List<ChurchModel>> getChurches() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.churchesCollection).get();
      if (snapshot.docs.isEmpty) {
        // Return mock list if Firestore has no records
        return _mockChurches;
      }
      return snapshot.docs.map((doc) => ChurchModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      // Fallback
      return _mockChurches;
    }
  }

  Future<ChurchModel?> getChurchById(String id) async {
    try {
      final doc = await _firestore.collection(AppConstants.churchesCollection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return ChurchModel.fromMap(doc.data()!, doc.id);
      }
      return _mockChurches.firstWhere((c) => c.id == id);
    } catch (e) {
      try {
        return _mockChurches.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
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
