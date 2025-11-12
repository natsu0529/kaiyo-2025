import '../models/taken_course.dart';
import '../repo/curriculum_rules_repository.dart';
import 'mapping_normalizer.dart';

class DeficitResult {
  final int totalRequired;
  final int countedTotal;
  final int deficitTotal;
  final Map<String, int> countedByCategory;
  final Map<String, int> limitByCategory;
  final List<String> missingSpecifiedCourses;

  DeficitResult({
    required this.totalRequired,
    required this.countedTotal,
    required this.deficitTotal,
    required this.countedByCategory,
    required this.limitByCategory,
    required this.missingSpecifiedCourses,
  });
}

class ProgressionCalculator {
  DeficitResult calculate({
    required CurriculumRules rules,
    required String stageKey,
    required List<TakenCourse> courses,
  }) {
    final limits = rules.requiredLimits;
    final spec = rules.progressionRules[stageKey]!;
    final byCat = <String, int>{};
    for (final c in courses) {
      final key = MappingNormalizer.canonicalCategory(c.majorCategory, c.subCategory);
      byCat[key] = (byCat[key] ?? 0) + c.credits;
    }
    final limitByCat = <String, int>{};
    for (final e in limits.entries) {
      final parts = e.key.split(':');
      final canon = MappingNormalizer.canonicalCategory(parts.first, parts.length > 1 ? parts[1] : '');
      limitByCat[canon] = e.value;
    }
    final countedByCat = <String, int>{};
    int countedTotal = 0;
    for (final e in byCat.entries) {
      final limit = limitByCat[e.key] ?? e.value;
      final counted = e.value > limit ? limit : e.value;
      countedByCat[e.key] = counted;
      countedTotal += counted;
    }
    final deficitTotal = spec.totalRequired - countedTotal;
    final missingSpec = <String>[];
    for (final name in spec.specifiedCourses) {
      final has = courses.any((c) => _equalsName(c.courseName, name));
      if (!has) missingSpec.add(name);
    }
    return DeficitResult(
      totalRequired: spec.totalRequired,
      countedTotal: countedTotal,
      deficitTotal: deficitTotal < 0 ? 0 : deficitTotal,
      countedByCategory: countedByCat,
      limitByCategory: limitByCat,
      missingSpecifiedCourses: missingSpec,
    );
  }

  bool _equalsName(String a, String b) {
    final na = a.trim().toLowerCase();
    final nb = b.trim().toLowerCase();
    return na == nb;
  }
}
