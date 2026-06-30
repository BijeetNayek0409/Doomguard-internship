// lib/features/survey/survey_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/auth_state.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  final List<String> _allApps = [
    'Instagram', 'YouTube', 'Twitter / X', 'Reddit',
    'TikTok', 'Snapchat', 'WhatsApp', 'Facebook', 'Other',
  ];
  final Set<String> _selectedApps = {};

  String? _dailyHours;
  final List<String> _hourOptions = [
    'Less than 1 hour', '1–2 hours', '2–4 hours',
    '4–6 hours', 'More than 6 hours',
  ];

  String? _goal;
  final List<String> _goalOptions = [
    'Reduce overall screen time',
    'Sleep better',
    'Be more productive',
    'Improve mental health',
    'Break the doomscrolling habit',
    'Other',
  ];

  String? _ageRange;
  final List<String> _ageOptions = [
    'Under 18', '18–24', '25–34', '35–44', '45+',
  ];

  bool get _canProceed {
    switch (_currentPage) {
      case 0: return _selectedApps.isNotEmpty;
      case 1: return _dailyHours != null;
      case 2: return _goal != null;
      case 3: return _ageRange != null;
      default: return false;
    }
  }

  void _next() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  // ✅ Fixed: passes a Map instead of named params
  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final authState = context.read<AuthState>();
    try {
      await authState.saveSurvey({
        'apps': _selectedApps.toList(),
        'dailyHours': _dailyHours!,
        'goal': _goal!,
        'ageRange': _ageRange!,
      });
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DG.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildAppsPage(),
                  _buildHoursPage(),
                  _buildGoalPage(),
                  _buildAgePage(),
                ],
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Which apps do you\ndoomscroll most?',
      'How much time do you\nspend on your phone daily?',
      'What\'s your main goal\nwith DoomGuard?',
      'How old are you?',
    ];
    final subtitles = [
      'Select all that apply',
      'Be honest — no judgment here',
      'We\'ll personalise your experience',
      'Helps us tailor recommendations',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_currentPage + 1} of 4',
              style: TextStyle(
                  color: DG.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(titles[_currentPage],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.25)),
          const SizedBox(height: 8),
          Text(subtitles[_currentPage],
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _currentPage ? DG.primary : Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAppsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _allApps.map((app) {
          final selected = _selectedApps.contains(app);
          return GestureDetector(
            onTap: () => setState(() =>
            selected ? _selectedApps.remove(app) : _selectedApps.add(app)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? DG.primary.withOpacity(0.15)
                    : Colors.white.withOpacity(0.07),
                border: Border.all(
                    color: selected ? DG.primary : Colors.white24,
                    width: 1.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(app,
                  style: TextStyle(
                      color: selected ? DG.primary : Colors.white70,
                      fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRadioPage(
      List<String> options, String? selected, ValueChanged<String> onSelect) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final opt = options[i];
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? DG.primary.withOpacity(0.15)
                  : Colors.white.withOpacity(0.07),
              border: Border.all(
                  color: isSelected ? DG.primary : Colors.white24,
                  width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(opt,
                      style: TextStyle(
                          color: isSelected ? DG.primary : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 15)),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded,
                      color: DG.primary, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoursPage() => _buildRadioPage(
      _hourOptions, _dailyHours, (v) => setState(() => _dailyHours = v));

  Widget _buildGoalPage() =>
      _buildRadioPage(_goalOptions, _goal, (v) => setState(() => _goal = v));

  Widget _buildAgePage() => _buildRadioPage(
      _ageOptions, _ageRange, (v) => setState(() => _ageRange = v));

  Widget _buildNextButton() {
    final isLast = _currentPage == 3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _canProceed && !_isSubmitting ? _next : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: DG.primary,
            disabledBackgroundColor: Colors.white12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isSubmitting
              ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Text(isLast ? 'Get started' : 'Continue',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
      ),
    );
  }
}