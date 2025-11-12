import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/department.dart';

class ProgressionSpec {
  final int totalRequired;
  final List<String> specifiedCourses;

  ProgressionSpec({
    required this.totalRequired,
    required this.specifiedCourses,
  });
}

class CurriculumRules {
  final Map<String, int> requiredLimits;
  final Map<String, ProgressionSpec> progressionRules;

  CurriculumRules({
    required this.requiredLimits,
    required this.progressionRules,
  });
}

class CurriculumRulesRepository {
  Future<CurriculumRules> loadByDepartment(Department dept) async {
    final path = switch (dept) {
      Department.ENG => 'docs/CURRICULUM_ENG_RULES.json',
      Department.LOG => 'docs/CURRICULUM_LOG_RULES.json',
      Department.CAP => 'docs/CURRICULUM_CAP_RULES.json',
    };
    final raw = await rootBundle.loadString(path);
    final data = json.decode(raw);
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final rulesArrDyn = map['curriculumRules'] ?? map['CurriculumRules'];
    final rulesArr = rulesArrDyn is List ? rulesArrDyn : const [];
    final selDyn = rulesArr.isNotEmpty ? rulesArr.first : const {};
    final selected = selDyn is Map<String, dynamic> ? selDyn : <String, dynamic>{};
    final rawLimitsDyn = selected['requiredLimits'] ?? selected['RequiredLimits'] ?? const {};
    final rawLimits = rawLimitsDyn is Map<String, dynamic> ? rawLimitsDyn : <String, dynamic>{};
    final limits = rawLimits.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    final rawProgDyn = selected['progressionRules'] ?? selected['ProgressionRules'] ?? const {};
    final rawProg = rawProgDyn is Map<String, dynamic> ? rawProgDyn : <String, dynamic>{};
    final prog = rawProg.map((k, v) {
      final key = k.toString().toLowerCase();
      final m = v as Map<String, dynamic>;
      final total = (m['totalRequiredCredits'] ?? m['totalRequired'] ?? m['TotalRequired'] ?? m['requiredTotal']) as num;
      final list2 = (m['requiredCourses'] ?? m['specifiedCourses'] ?? m['SpecifiedCourses'] ?? m['mandatoryCourses'] ?? []) as List;
      return MapEntry(
        key,
        ProgressionSpec(
          totalRequired: total.toInt(),
          specifiedCourses: list2.map((e) => e.toString()).toList(),
        ),
      );
    });
    return CurriculumRules(requiredLimits: limits, progressionRules: prog);
  }
}
