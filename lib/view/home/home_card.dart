import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final Gradient gradient;
  final VoidCallback? onTap;

  const HomeCard({
    super.key,
    required this.title,
    this.gradient = AppColors.primaryGradient, 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[AppColors.cardShadow],
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.subtitleMedium(),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}