import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:church/app/theme.dart';

class ChurchHierarchyTree extends ConsumerStatefulWidget {
  const ChurchHierarchyTree({super.key});

  @override
  ConsumerState<ChurchHierarchyTree> createState() => _ChurchHierarchyTreeState();
}

class _ChurchHierarchyTreeState extends ConsumerState<ChurchHierarchyTree> {
  final Map<String, bool> _expandedDioceses = {};
  final Map<String, bool> _expandedWoredas = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dioceses').snapshots(),
      builder: (context, diocesesSnapshot) {
        if (diocesesSnapshot.connectionState == ConnectionState.waiting) {
          return const _HierarchySkeleton();
        }

        if (!diocesesSnapshot.hasData || diocesesSnapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final dioceses = diocesesSnapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Church Network',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalEmerald,
                    ),
                  ),
                  Text(
                    '${dioceses.length} dioceses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dioceses.length,
                itemBuilder: (context, dioceseIndex) {
                  final dioceseData = dioceses[dioceseIndex].data() as Map<String, dynamic>;
                  final dioceseId = dioceses[dioceseIndex].id;
                  final dioceseName = dioceseData['name'] ?? 'Unknown Diocese';

                  _expandedDioceses.putIfAbsent(dioceseId, () => false);

                  return _DioceseNode(
                    dioceseId: dioceseId,
                    dioceseName: dioceseName,
                    isExpanded: _expandedDioceses[dioceseId]!,
                    onExpand: () {
                      setState(() {
                        _expandedDioceses[dioceseId] = !_expandedDioceses[dioceseId]!;
                      });
                    },
                    expandedWoredas: _expandedWoredas,
                    onWoredaExpand: (woredaId) {
                      setState(() {
                        _expandedWoredas[woredaId] = !(_expandedWoredas[woredaId] ?? false);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DioceseNode extends StatelessWidget {
  final String dioceseId;
  final String dioceseName;
  final bool isExpanded;
  final VoidCallback onExpand;
  final Map<String, bool> expandedWoredas;
  final Function(String) onWoredaExpand;

  const _DioceseNode({
    required this.dioceseId,
    required this.dioceseName,
    required this.isExpanded,
    required this.onExpand,
    required this.expandedWoredas,
    required this.onWoredaExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diocese header
        GestureDetector(
          onTap: onExpand,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.royalEmerald.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.royalEmerald.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppTheme.royalEmerald,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.location_city_rounded,
                  color: AppTheme.royalEmerald,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dioceseName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.royalEmerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Woredas list (expanded)
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('woredas')
                  .where('dioceseId', isEqualTo: dioceseId)
                  .snapshots(),
              builder: (context, woredaSnapshot) {
                if (woredaSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (!woredaSnapshot.hasData || woredaSnapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No woredas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  );
                }

                final woredas = woredaSnapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    woredas.length,
                    (woredaIndex) {
                      final woredaData = woredas[woredaIndex].data() as Map<String, dynamic>;
                      final woredaId = woredas[woredaIndex].id;
                      final woredaName = woredaData['name'] ?? 'Unknown Woreda';
                      final isWoredaExpanded = expandedWoredas[woredaId] ?? false;

                      return _WoredaNode(
                        woredaId: woredaId,
                        woredaName: woredaName,
                        isExpanded: isWoredaExpanded,
                        onExpand: () => onWoredaExpand(woredaId),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _WoredaNode extends StatelessWidget {
  final String woredaId;
  final String woredaName;
  final bool isExpanded;
  final VoidCallback onExpand;

  const _WoredaNode({
    required this.woredaId,
    required this.woredaName,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Woreda header
        GestureDetector(
          onTap: onExpand,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.imperialGold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.imperialGold.withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppTheme.imperialGold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.map_rounded,
                  color: AppTheme.imperialGold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    woredaName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.imperialGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Churches list (expanded)
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('churches')
                  .where('woredaId', isEqualTo: woredaId)
                  .snapshots(),
              builder: (context, churchSnapshot) {
                if (churchSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (!churchSnapshot.hasData || churchSnapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'No churches',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }

                final churches = churchSnapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    churches.length,
                    (churchIndex) {
                      final churchData = churches[churchIndex].data() as Map<String, dynamic>;
                      final churchName = churchData['name'] ?? 'Unknown Church';
                      final churchType = churchData['type'] ?? 'church';

                      return Padding(
                        padding: EdgeInsets.only(bottom: churchIndex < churches.length - 1 ? 6 : 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                churchType == 'monastery'
                                    ? Icons.temple_buddhist_rounded
                                    : Icons.church_rounded,
                                color: AppTheme.royalEmerald,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  churchName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _HierarchySkeleton extends StatelessWidget {
  const _HierarchySkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
