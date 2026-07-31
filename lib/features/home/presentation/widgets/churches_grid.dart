import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/app/theme.dart';

class ChurchesGrid extends StatelessWidget {
  const ChurchesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dioceses')
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, diocesesSnapshot) {
        if (diocesesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!diocesesSnapshot.hasData || diocesesSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('ምንም ሀገረ ስብከት አልተገኘም'));
        }

        final dioceses = diocesesSnapshot.data!.docs;

        return Column(
          children: dioceses.map((dioceseDoc) {
            final dioceseName = dioceseDoc['name'] as String? ?? 'Unknown';
            final dioceseId = dioceseDoc.id;

            return _DioceseSection(dioceseName: dioceseName, dioceseId: dioceseId);
          }).toList(),
        );
      },
    );
  }
}

class _DioceseSection extends StatelessWidget {
  final String dioceseName;
  final String dioceseId;

  const _DioceseSection({
    required this.dioceseName,
    required this.dioceseId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('woredas')
          .where('dioceseId', isEqualTo: dioceseId)
          .snapshots(),
      builder: (context, woredasSnapshot) {
        if (!woredasSnapshot.hasData || woredasSnapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final woredas = woredasSnapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 24, bottom: 12),
              child: Text(
                dioceseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalEmerald,
                ),
              ),
            ),
            ...woredas.map((woredaDoc) {
              final woredaName = woredaDoc['name'] as String? ?? 'Unknown';
              final woredaId = woredaDoc.id;
              return _WoredaSection(
                woredaName: woredaName,
                woredaId: woredaId,
                dioceseId: dioceseId,
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class _WoredaSection extends StatelessWidget {
  final String woredaName;
  final String woredaId;
  final String dioceseId;

  const _WoredaSection({
    required this.woredaName,
    required this.woredaId,
    required this.dioceseId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('churches')
          .where('woredaId', isEqualTo: woredaId)
          .snapshots(),
      builder: (context, churchesSnapshot) {
        if (!churchesSnapshot.hasData || churchesSnapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final churches = churchesSnapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
              child: Text(
                woredaName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: churches.length,
              itemBuilder: (context, index) {
                final churchDoc = churches[index];
                final churchName = churchDoc['name'] as String? ?? 'Unknown';
                final churchType = churchDoc['type'] as String? ?? 'church';
                final clergy = churchDoc['clergy'] as String? ?? 'N/A';

                return _ChurchCard(
                  name: churchName,
                  type: churchType,
                  clergy: clergy,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ChurchCard extends StatelessWidget {
  final String name;
  final String type;
  final String clergy;

  const _ChurchCard({
    required this.name,
    required this.type,
    required this.clergy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.royalEmerald.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            type == 'monastery' ? Icons.temple_buddhist_rounded : Icons.church_rounded,
            color: AppTheme.royalEmerald,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.royalEmerald,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            clergy,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black38,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
