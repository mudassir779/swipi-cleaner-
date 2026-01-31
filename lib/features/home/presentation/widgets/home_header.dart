import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Hero(
          tag: 'app_icon',
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A9EFF), Color(0xFF2D7FE8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A9EFF).withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Swipe to Clean',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Free up space with a swipe',
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

