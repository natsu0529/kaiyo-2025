import 'package:hive/hive.dart';
import 'difficulty.dart';

class TakenCourse {
  final String courseName;
  final int credits;
  final Difficulty difficulty;
  final String majorCategory;
  final String subCategory;
  final bool isOverCredit;

  TakenCourse({
    required this.courseName,
    required this.credits,
    required this.difficulty,
    required this.majorCategory,
    required this.subCategory,
    this.isOverCredit = false,
  });
}

class TakenCourseAdapter extends TypeAdapter<TakenCourse> {
  @override
  final int typeId = 1;

  @override
  TakenCourse read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return TakenCourse(
      courseName: map['courseName'] as String,
      credits: map['credits'] as int,
      difficulty: Difficulty.values[map['difficulty'] as int],
      majorCategory: map['majorCategory'] as String,
      subCategory: map['subCategory'] as String,
      isOverCredit: map['isOverCredit'] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TakenCourse obj) {
    writer.writeMap({
      'courseName': obj.courseName,
      'credits': obj.credits,
      'difficulty': obj.difficulty.index,
      'majorCategory': obj.majorCategory,
      'subCategory': obj.subCategory,
      'isOverCredit': obj.isOverCredit,
    });
  }
}
