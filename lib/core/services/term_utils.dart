class TermUtils {
  static String currentTerm(DateTime now) {
    final m = now.month;
    if (m >= 4 && m <= 9) return 'spring';
    return 'fall';
  }
}
