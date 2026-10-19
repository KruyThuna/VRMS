import 'package:flutter/material.dart';
import 'app_language.dart';

/// Interactive 1-click dual-pill language selector.
/// Tapping 🇰🇭 instantly switches the entire app to Khmer.
/// Tapping 🇬🇧 instantly switches the entire app to English.
class LanguageSelectorWidget extends StatelessWidget {
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPill(
            lang: AppLanguage.khmer,
            flag: '🇰🇭',
            label: 'ខ្មែរ',
            isSelected: currentLanguage == AppLanguage.khmer,
          ),
          const SizedBox(width: 2),
          _buildPill(
            lang: AppLanguage.english,
            flag: '🇬🇧',
            label: 'EN',
            isSelected: currentLanguage == AppLanguage.english,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required AppLanguage lang,
    required String flag,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onLanguageChanged(lang),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE50914) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE50914).withAlpha(100),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
