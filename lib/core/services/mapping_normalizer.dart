class MappingNormalizer {
  static String normalize(String s) {
    final t = s.toLowerCase();
    final r = t.replaceAll(RegExp(r"[\s_\-()（）・]"), "");
    return r;
  }

  static String canonicalCategory(String major, String sub) {
    final m = normalize(major);
    final s = normalize(sub);
    return '$m:$s';
  }
}
