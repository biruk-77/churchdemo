import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:church/app/theme.dart';

class ContributionTypesScreen extends StatefulWidget {
  const ContributionTypesScreen({super.key});

  @override
  State<ContributionTypesScreen> createState() => _ContributionTypesScreenState();
}

class _ContributionTypesScreenState extends State<ContributionTypesScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የመዋጮ ዓይነት ይምረጡ'),
        elevation: 0,
        backgroundColor: AppTheme.royalEmerald,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contributionTypes')
            .where('status', isEqualTo: 'active')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ምንም የመዋጮ ዓይነት አልተገኘም'));
          }

          final types = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final typeDoc = types[index];
              final typeName = typeDoc['name'] as String? ?? 'Unknown';
              final icon = typeDoc['icon'] as String? ?? '💰';

              return GestureDetector(
                onTap: () {
                  context.push('/payment/method', extra: {
                    'type': typeName,
                    'typeId': typeDoc.id,
                    'icon': icon,
                    'amount': 0.0,
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.royalEmerald.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.royalEmerald.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.royalEmerald.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        typeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.royalEmerald,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
