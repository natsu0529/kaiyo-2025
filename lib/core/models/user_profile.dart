import 'package:hive/hive.dart';
import 'department.dart';

class UserProfile {
  final int enrollmentYear;
  final int currentGrade;
  final Department department;

  UserProfile({
    required this.enrollmentYear,
    required this.currentGrade,
    required this.department,
  });
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return UserProfile(
      enrollmentYear: map['enrollmentYear'] as int,
      currentGrade: map['currentGrade'] as int,
      department: Department.values[map['department'] as int],
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeMap({
      'enrollmentYear': obj.enrollmentYear,
      'currentGrade': obj.currentGrade,
      'department': obj.department.index,
    });
  }
}
