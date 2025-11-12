import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/taken_course.dart';
import 'core/models/user_profile.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TakenCourseAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  runApp(const KaiyoApp());
}

class KaiyoApp extends StatelessWidget {
  const KaiyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tumsat履修補助2025',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066CC)),
        useMaterial3: true,
      ),
      home: _Root(),
    );
  }
}

class _Root extends StatefulWidget {

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _ready = false;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() { super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_profile == null) {
      return const OnboardingPage();
    }
    return const DashboardPage();
  }

  Future<void> _load() async {
    final box = await Hive.openBox('appBox');
    _profile = box.get('profile') as UserProfile?;
    setState(() => _ready = true);
  }
}
