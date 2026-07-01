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

  // ── Age options — split out 'Under 13' so we can trigger the
  //    guardian-email step distinctly from general teen/adult users.
  String? _ageRange;
  final List<String> _ageOptions = [
    'Under 13', '13–17', '18–24', '25–34', '35–44', '45+',
  ];

  // ── Guardian email — only collected/required when ageRange == 'Under 13'
  final TextEditingController _guardianEmailController =
  TextEditingController();
  String? _guardianEmailError;

  bool get _isChild => _ageRange == 'Under 13';

  /// Total steps depends on whether the guardian-email step is needed.
  int get _totalPages => _isChild ? 5 : 4;

  bool get _isLastPage => _currentPage == _totalPages - 1;

  static final RegExp _emailRegex =
  RegExp(r'^[\w\.\-\+]+@[\w\-]+\.[a-zA-Z]{2,}$');

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _selectedApps.isNotEmpty;
      case 1:
        return _dailyHours != null;
      case 2:
        return _goal != null;
      case 3:
        return _ageRange != null;
      case 4:
      // Only reachable when _isChild is true
        return _emailRegex.hasMatch(_guardianEmailController.text.trim());
      default:
        return false;
    }
  }

  void _next() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final authState = context.read<AuthState>();
    try {
      await authState.saveSurvey({
        'apps': _selectedApps.toList(),
        'dailyHours': _dailyHours!,
        'goal': _goal!,
        'ageRange': _ageRange!,
        'isChild': _isChild,
        if (_isChild) 'guardianEmail': _guardianEmailController.text.trim(),
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
    _guardianEmailController.dispose();
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
                  if (_isChild) _buildGuardianEmailPage(),
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
      'A parent or guardian\nshould keep an eye on this',
    ];
    final subtitles = [
      'Select all that apply',
      'Be honest — no judgment here',
      'We\'ll personalise your experience',
      'Helps us tailor recommendations',
      'They\'ll get a daily usage summary by email',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_currentPage + 1} of $_totalPages',
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
        children: List.generate(_totalPages, (i) {
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
      _ageOptions,
      _ageRange,
          (v) => setState(() {
        _ageRange = v;
        // Clear any stale guardian-email error if the user flips
        // back and forth between age brackets.
        _guardianEmailError = null;
      }));

  Widget _buildGuardianEmailPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DG.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DG.primary.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.family_restroom_rounded,
                    color: DG.primary, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Since you\'re under 13, DoomGuard sends a daily '
                        'screen-time summary to a parent or guardian.',
                    style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Guardian\'s email address',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: _guardianEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            onChanged: (_) => setState(() => _guardianEmailError = null),
            decoration: InputDecoration(
              hintText: 'parent@example.com',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white24, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white24, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: DG.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: DG.destructive, width: 1.5),
              ),
              errorText: _guardianEmailError,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We\'ll only use this to send daily usage reports — never for marketing.',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
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
              : Text(_isLastPage ? 'Get started' : 'Continue',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
      ),
    );
  }
}