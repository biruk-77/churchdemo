import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:church/features/contributions/data/contribution_repository.dart';

class ActiveContribution {
  final String type;
  final double amount;
  final String? note;

  const ActiveContribution({
    required this.type,
    required this.amount,
    this.note,
  });

  ActiveContribution copyWith({String? type, double? amount, String? note}) {
    return ActiveContribution(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}

final contributionRepositoryProvider = Provider<ContributionRepository>((ref) {
  return ContributionRepository();
});

final activeContributionProvider =
    NotifierProvider<ActiveContributionNotifier, ActiveContribution?>(
  ActiveContributionNotifier.new,
);

class ActiveContributionNotifier extends Notifier<ActiveContribution?> {
  @override
  ActiveContribution? build() => null;

  void set(ActiveContribution? contribution) => state = contribution;

  void updateAmount(double amount) {
    final current = state;
    if (current != null) state = current.copyWith(amount: amount);
  }

  void updateNote(String? note) {
    final current = state;
    if (current != null) state = current.copyWith(note: note);
  }

  void clear() => state = null;
}
