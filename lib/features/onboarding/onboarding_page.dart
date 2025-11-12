import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/department.dart';
import '../../core/models/user_profile.dart';
import '../dashboard/dashboard_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _yearCtrl = TextEditingController();
  int? _gradeSel;
  Department? _dept;

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('初回設定')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Department>(
              initialValue: _dept,
              items: Department.values
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                  .toList(),
              onChanged: (d) => setState(() => _dept = d),
              decoration: const InputDecoration(labelText: '学科'),
            ),
            DropdownButtonFormField<int>(
              initialValue: _gradeSel,
              items: const [1, 2, 3, 4]
                  .map((g) => DropdownMenuItem(value: g, child: Text('$g年')))
                  .toList(),
              onChanged: (g) => setState(() => _gradeSel = g),
              decoration: const InputDecoration(labelText: '現在の学年'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('保存して開始'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_dept == null) return;
    final year = DateTime.now().year;
    final grade = _gradeSel ?? 1;
    final profile = UserProfile(
      enrollmentYear: year,
      currentGrade: grade,
      department: _dept!,
    );
    final box = await Hive.openBox('appBox');
    await box.put('profile', profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }
}
