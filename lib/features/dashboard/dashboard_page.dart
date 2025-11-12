import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/taken_course.dart';
import '../../core/models/difficulty.dart';
import '../../core/models/user_profile.dart';
import '../../core/repo/courses_master_repository.dart';
import '../../core/repo/curriculum_rules_repository.dart';
import '../../core/services/progression_calculator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  UserProfile? _profile;
  List<TakenCourse> _courses = [];
  late final CoursesMasterRepository _masterRepo;
  late final CurriculumRulesRepository _rulesRepo;
  CurriculumRules? _rules;
  String _stageKey = 'grade2';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _masterRepo = CoursesMasterRepository();
    _rulesRepo = CurriculumRulesRepository();
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final box = await Hive.openBox('appBox');
    _profile = box.get('profile') as UserProfile?;
    final list = (box.get('takenCourses') as List?)?.cast<TakenCourse>() ?? [];
    _courses = List<TakenCourse>.from(list);
    if (_profile != null) {
      _rules = await _rulesRepo.loadByDepartment(_profile!.department);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('履修補助'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '不足単位'),
            Tab(text: '修得済み'),
          ],
        ),
        actions: [
          IconButton(onPressed: _addCourse, icon: const Icon(Icons.add)),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeficitView(),
          _buildAcquiredView(),
        ],
      ),
    );
  }

  Widget _buildDeficitView() {
    if (_rules == null) return const Center(child: Text('設定が未完了'));
    final calc = ProgressionCalculator();
    final res = calc.calculate(rules: _rules!, stageKey: _stageKey, courses: _courses);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('進級条件'),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _stageKey,
                items: const [
                  DropdownMenuItem(value: 'grade2', child: Text('2年')),
                  DropdownMenuItem(value: 'grade3', child: Text('3年')),
                  DropdownMenuItem(value: 'grade4', child: Text('4年')),
                  DropdownMenuItem(value: 'graduate', child: Text('卒業')),
                ],
                onChanged: (v) => setState(() => _stageKey = v ?? 'grade2'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('必要合計: ${res.totalRequired}'),
          Text('算入合計: ${res.countedTotal}'),
          Text('不足合計: ${res.deficitTotal}'),
          const SizedBox(height: 12),
          const Text('区分別算入'),
          Expanded(
            child: ListView(
              children: res.countedByCategory.entries.map((e) {
                final limit = res.limitByCategory[e.key] ?? e.value;
                return ListTile(
                  title: Text(e.key),
                  subtitle: Text('算入 ${e.value} / 上限 $limit'),
                  trailing: Text('不足 ${limit - e.value < 0 ? 0 : limit - e.value}'),
                );
              }).toList(),
            ),
          ),
          if (res.missingSpecifiedCourses.isNotEmpty) const Text('指定科目未修得'),
          ...res.missingSpecifiedCourses.map((c) => Text(c)),
        ],
      ),
    );
  }

  Widget _buildAcquiredView() {
    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, i) {
        final c = _courses[i];
        return ListTile(
          title: Text(c.courseName),
          subtitle: Text('${c.majorCategory} / ${c.subCategory} / ${c.difficulty.name}'),
          trailing: Text('${c.credits}'),
        );
      },
    );
  }

  Future<void> _addCourse() async {
    if (_profile == null) return;
    final items = await _masterRepo.loadByDepartment(_profile!.department);
    if (!mounted) return;
    final selected = await showModalBottomSheet<CourseMasterItem>(
      context: context,
      builder: (context) {
        return _CoursePicker(items: items);
      },
    );
    if (selected == null) return;
    final diff = await showDialog<Difficulty>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('難易度選択'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: Difficulty.values
                .map((d) => ListTile(
                      title: Text(d.name),
                      onTap: () => Navigator.pop(context, d),
                    ))
                .toList(),
          ),
        );
      },
    );
    if (diff == null) return;
    final tc = TakenCourse(
      courseName: selected.courseName,
      credits: selected.credits,
      difficulty: diff,
      majorCategory: selected.majorCategory,
      subCategory: selected.subCategory,
    );
    final box = await Hive.openBox('appBox');
    _courses.add(tc);
    await box.put('takenCourses', _courses);
    if (mounted) setState(() {});
  }
}

class _CoursePicker extends StatefulWidget {
  final List<CourseMasterItem> items;
  const _CoursePicker({required this.items});
  @override
  State<_CoursePicker> createState() => _CoursePickerState();
}

class _CoursePickerState extends State<_CoursePicker> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((e) => e.courseName.toLowerCase().contains(_q.toLowerCase()))
        .toList();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(hintText: '科目検索'),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final it = filtered[i];
                return ListTile(
                  title: Text(it.courseName),
                  subtitle: Text('${it.majorCategory}/${it.subCategory}'),
                  trailing: Text('${it.credits}'),
                  onTap: () => Navigator.pop(context, it),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
