// lib/features/settings/screen/help_feedback_screen.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_theme.dart';

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late WebViewController _webController;
  bool _formLoading = true;

  static const _formUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSdMTrYcvAv3cXrp7ZWv_X7F0MFeSS18TFKj5KSZvGuU1MCcfg/viewform';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(DG.bg)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _formLoading = false),
      ))
      ..loadRequest(Uri.parse(_formUrl));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DG.bg,
      appBar: AppBar(
        backgroundColor: DG.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: DG.fg),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Feedback',
            style: TextStyle(
                color: DG.fg, fontSize: 18, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DG.primary,
          indicatorWeight: 3,
          labelColor: DG.primary,
          unselectedLabelColor: DG.mutedFg,
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: '📖  User Guide'),
            Tab(text: '💬  Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHelpTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }

  // ── HELP TAB ───────────────────────────────────────────────────────────────
  Widget _buildHelpTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        _welcomeCard(),
        const SizedBox(height: 20),
        _sectionTitle('🚀 Getting Started'),
        const SizedBox(height: 12),
        _stepCard('1', 'Sign in with Google',
            'Tap "Sign in with Google" on the login screen. DoomGuard uses your Google account to save your progress securely.'),
        _stepCard('2', 'Complete the survey',
            'Answer 4 quick questions about your screen habits. This helps DoomGuard personalise your experience.'),
        _stepCard('3', 'Start your first session',
            'Go to the Timer tab and pick a preset — Pomodoro (25 min) is a great start. Hit "Start focus" and put your phone down.'),
        _stepCard('4', 'Build your streak',
            'Complete at least one focus session every day to keep your streak alive. Check the Rewards tab to track your progress.'),
        const SizedBox(height: 20),
        _sectionTitle('✨ Features'),
        const SizedBox(height: 12),
        _featureCard(Icons.timer_rounded, DG.violetGrad, 'Focus Timer',
            'Four presets: Pomodoro (25 min), Deep Work (50 min), Flow (90 min), and Quick (15 min). The timer auto-switches to a break when done.'),
        _featureCard(Icons.local_fire_department_rounded, DG.streakGrad,
            'Streak Tracking',
            'Complete a focus session every day to build your streak. Missing a day resets it — so stay consistent!'),
        _featureCard(Icons.emoji_events_rounded, DG.mintGrad, 'Badges',
            'Earn 8 unique badges by hitting milestones — like a 7-day streak, 60 focus minutes in a day, or saving 10 hours total.'),
        _featureCard(Icons.bar_chart_rounded, DG.coralGrad, 'Stats',
            'Track your daily screen time, top apps, and how much time you\'ve reclaimed. Updated in real time.'),
        _featureCard(Icons.settings_rounded,
            const LinearGradient(colors: [DG.muted, DG.muted]),
            'Settings',
            'Set a daily screen time limit, configure wind-down hours, and toggle smart nudges to stay on track.'),
        const SizedBox(height: 20),
        _sectionTitle('🏅 Badges Guide'),
        const SizedBox(height: 12),
        _badgeRow('🌱', 'First Step', 'Complete 1 focus session'),
        _badgeRow('🔥', '7-Day Streak', 'Maintain a 7-day streak'),
        _badgeRow('⚡', 'Focus Master', 'Reach 60 focus minutes in one day'),
        _badgeRow('🌙', 'Night Owl Tamed', 'Achieve a 3-day streak'),
        _badgeRow('🧘', 'Zen Mode', 'Reach a 14-day streak'),
        _badgeRow('💎', 'Deep Worker', 'Complete 4 sessions in one day'),
        _badgeRow('⏰', 'Time Saver', 'Save 10+ hours total'),
        _badgeRow('🏆', '30-Day Legend', 'Maintain a 30-day streak'),
        const SizedBox(height: 20),
        _sectionTitle('💡 Tips for Success'),
        const SizedBox(height: 12),
        _tipCard('Start small',
            'Even one 15-minute session a day is enough to build the habit. Don\'t aim for perfection from day one.'),
        _tipCard('Use wind-down mode',
            'Set your wind-down hours in Settings to get a gentle nudge before bed — one of the most effective changes you can make.'),
        _tipCard('Check your stats weekly',
            'The Stats screen shows which apps steal your time. Knowing is half the battle.'),
        _tipCard('Protect your streak',
            'If you know you\'ll have a busy day, do a quick 15-minute session early. Streaks are powerful motivators.'),
        const SizedBox(height: 20),
        _sectionTitle('❓ FAQ'),
        const SizedBox(height: 12),
        _faqCard('Does DoomGuard block apps?',
            'Not yet — DoomGuard is currently a tracker and focus tool. App blocking is coming in a future update.'),
        _faqCard('Will my streak reset if I uninstall?',
            'Yes — data is stored locally. We\'re working on cloud sync so your progress follows you across devices.'),
        _faqCard('How is "hours saved" calculated?',
            'Every focus session you complete counts as time you were not doomscrolling. It adds up over time.'),
        _faqCard('Can I change my survey answers?',
            'Not yet, but you can sign out and sign back in to retake the survey as a new user.'),
      ],
    );
  }

  Widget _welcomeCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: DG.violetGrad,
      borderRadius: BorderRadius.circular(DG.r32),
      boxShadow: [
        BoxShadow(
          color: DG.primary.withAlpha(0x44),
          blurRadius: 20, spreadRadius: -4,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('👋 Welcome to DoomGuard',
            style: TextStyle(
                color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.w700)),
        SizedBox(height: 8),
        Text(
          'DoomGuard helps you take back control of your screen time through focus sessions, streak tracking, and mindful nudges.',
          style: TextStyle(
              color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _Pill('⏱ Timer'),
            SizedBox(width: 8),
            _Pill('🔥 Streaks'),
            SizedBox(width: 8),
            _Pill('🏅 Badges'),
          ],
        ),
      ],
    ),
  );

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          color: DG.fg, fontSize: 16, fontWeight: FontWeight.w700));

  Widget _stepCard(String num, String title, String body) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DG.glassBg,
      borderRadius: BorderRadius.circular(DG.r24),
      border: Border.all(color: DG.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: DG.violetGrad,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(num,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: DG.fg, fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(body,
                  style: const TextStyle(
                      color: DG.mutedFg, fontSize: 12,
                      height: 1.5)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _featureCard(IconData icon, LinearGradient grad, String title,
      String body) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DG.glassBg,
          borderRadius: BorderRadius.circular(DG.r24),
          border: Border.all(color: DG.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: grad,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: DG.fg, fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(
                          color: DG.mutedFg, fontSize: 12,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _badgeRow(String emoji, String name, String req) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: DG.glassBg,
      borderRadius: BorderRadius.circular(DG.r16),
      border: Border.all(color: DG.border),
    ),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: DG.fg, fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Text(req,
                  style: const TextStyle(
                      color: DG.mutedFg, fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: DG.primary.withAlpha(0x22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DG.primary.withAlpha(0x44)),
          ),
          child: const Text('Earn it',
              style: TextStyle(
                  color: DG.primary, fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  Widget _tipCard(String title, String body) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DG.secondary.withAlpha(0x15),
      borderRadius: BorderRadius.circular(DG.r24),
      border: Border.all(color: DG.secondary.withAlpha(0x33)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('💡', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: DG.secondary, fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(body,
                  style: const TextStyle(
                      color: DG.mutedFg, fontSize: 12,
                      height: 1.5)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _faqCard(String q, String a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DG.glassBg,
      borderRadius: BorderRadius.circular(DG.r24),
      border: Border.all(color: DG.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Q  ', style: TextStyle(
                color: DG.primary, fontSize: 13,
                fontWeight: FontWeight.w800)),
            Expanded(
              child: Text(q,
                  style: const TextStyle(
                      color: DG.fg, fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(a,
            style: const TextStyle(
                color: DG.mutedFg, fontSize: 12, height: 1.5)),
      ],
    ),
  );

  // ── FEEDBACK TAB ───────────────────────────────────────────────────────────
  Widget _buildFeedbackTab() {
    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DG.streak.withAlpha(0x15),
            borderRadius: BorderRadius.circular(DG.r24),
            border: Border.all(color: DG.streak.withAlpha(0x33)),
          ),
          child: const Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Share your thoughts',
                        style: TextStyle(
                            color: DG.streak, fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text(
                      'Your feedback shapes the next version of DoomGuard.',
                      style: TextStyle(color: DG.mutedFg, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // WebView with Google Form
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _webController),
              if (_formLoading)
                Container(
                  color: DG.bg,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: DG.primary),
                        SizedBox(height: 16),
                        Text('Loading form...',
                            style: TextStyle(
                                color: DG.mutedFg, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Small pill widget ─────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(0x22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}