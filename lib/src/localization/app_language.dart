enum AppLanguage {
  english('en', 'English', '🇬🇧'),
  khmer('km', 'ភាសាខ្មែរ', '🇰🇭');

  final String code;
  final String label;
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);

  static AppLanguage fromCode(String? code) {
    if (code == 'km') return AppLanguage.khmer;
    return AppLanguage.english;
  }
}

