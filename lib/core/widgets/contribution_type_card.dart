import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ContributionTypeCard extends StatelessWidget {
  const ContributionTypeCard({
    super.key,
    required this.type,
    required this.onTap,
    this.isSelected = false,
    this.useAmharic = false,
  });

  final ContributionType type;
  final VoidCallback onTap;
  final bool isSelected;
  final bool useAmharic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryGold.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              size: 28,
              color: isSelected ? Colors.white : AppColors.orthodoxBlue,
            ),
            const SizedBox(height: 8),
            Text(
              useAmharic ? type.displayNameAm : type.displayNameEn,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
