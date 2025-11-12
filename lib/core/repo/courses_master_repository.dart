import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/department.dart';

class CourseMasterItem {
  final String courseName;
  final int credits;
  final String majorCategory;
  final String subCategory;
  final int? offeringGrade;

  CourseMasterItem({
    required this.courseName,
    required this.credits,
    required this.majorCategory,
    required this.subCategory,
    this.offeringGrade,
  });
}

class CoursesMasterRepository {
  Future<List<CourseMasterItem>> loadByDepartment(Department dept) async {
    final path = switch (dept) {
      Department.ENG => 'docs/COURSES_MASTER_ENG.json',
      Department.LOG => 'docs/COURSES_MASTER_LOG.json',
      Department.CAP => 'docs/COURSES_MASTER_CAP.json',
    };
    final raw = await rootBundle.loadString(path);
    final data = json.decode(raw);
    final list = (data as List).map((e) => _fromJson(e)).toList();
    return list;
  }

  CourseMasterItem _fromJson(dynamic e) {
    final m = e as Map<String, dynamic>;
    return CourseMasterItem(
      courseName: m['courseName'] as String,
      credits: (m['credits'] as num).toInt(),
      majorCategory: m['majorCategory'] as String,
      subCategory: m['subCategory'] as String,
      offeringGrade: m['offeringGrade'] == null ? null : (m['offeringGrade'] as num).toInt(),
    );
  }
}
