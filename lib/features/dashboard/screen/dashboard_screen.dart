import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/usage_state.dart';
import '../../../shared/models/settings_state.dart';
import '../../../shared/models/streak_state.dart';
import '../../../shared/services/app_name_service.dart';
import '../../../shared/widgets/app_icon_widget.dart';
import '../../../shared/widgets/secure_section_guard.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UsageState, SettingsState, StreakState>(
      builder: (_, usage, settings, streak, __) {
        return Scaffold(
          backgroundColor: DG.bg,
          body: Stack(
            children: [
              // Aurora background blobs
              Positioned(top: -60, right: -60,
                  child: _blob(200, DG.primary.withAlpha(0x33))),
              Positioned(bottom: 100, left: -40,
                  child: _blob(160, DG.secondary.withAlpha(0x22))),

              SafeArea(
                child: RefreshIndicator(
                  color: DG.primary,
                  backgroundColor: DG.card,
                  onRefresh: () => usage.loadUsage(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(streak)),
                      SliverToBoxAdapter(child: const SizedBox(height: 20)),
                      SliverToBoxAdapter(
                        child: _buildHeroCard(context, usage, settings, streak),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 16)),
                      SliverToBoxAdapter(child: _buildQuickActions(context)),
                      SliverToBoxAdapter(child: const SizedBox(height: 20)),
                      SliverToBoxAdapter(
                        // NOTE: locked reads settings.strictMode — adjust
                        // this getter name if your SettingsState calls it
                        // something else.
                        child: SecureSectionGuard(
                          locked: settings.strictMode,
                          title: 'Top Offenders',
                          reason: 'Authenticate to view Top Offenders',
                          childBuilder: (_) =>
                              _buildTopOffenders(context, usage, settings),
                        ),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 20)),
                      SliverToBoxAdapter(
                          child: _buildInsightCard(usage)),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _buildHeader(StreakState streak) {
    final h = DateTime.now().hour;
    final greeting = h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
    final now = DateTime.now();
    final dayStr = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'][now.weekday - 1];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '$dayStr, ${months[now.month-1]} ${now.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        color: DG.mutedFg, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('$greeting 👋',
                    style: const TextStyle(
                        color: DG.fg, fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _glassButton(
            child: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: DG.fg, size: 20),
                if (streak.currentStreak > 0)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                          color: DG.accent, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({required Widget child}) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: DG.glassBg,
      borderRadius: BorderRadius.circular(DG.r16),
      border: Border.all(color: DG.border),
    ),
    child: Center(child: child),
  );

  Widget _buildHeroCard(BuildContext context, UsageState usage, SettingsState settings, StreakState streak) {
    final total = usage.totalUsageMinutes;
    final limit = settings.dailyLimitMinutes;
    final progress = (total / limit).clamp(0.0, 1.0);
    final remaining = (limit - total).clamp(0, limit);
    final overLimit = total >= limit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: DG.glassBg,
          borderRadius: BorderRadius.circular(DG.r36),
          border: Border.all(color: overLimit ? DG.destructive.withAlpha(0x55) : DG.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DG.r36),
          child: Stack(
            children: [
              Positioned(top: -40, right: -40,
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        DG.primary.withAlpha(0x44), Colors.transparent,
                      ]),
                    ),
                  )),
              Positioned(bottom: -50, left: -30,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        DG.secondary.withAlpha(0x33), Colors.transparent,
                      ]),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Progress ring
                        SizedBox(
                          width: 130, height: 130,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(130, 130),
                                painter: _RingPainter(progress: progress, overLimit: overLimit),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('TODAY',
                                      style: TextStyle(
                                          color: DG.mutedFg, fontSize: 9,
                                          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                                  const SizedBox(height: 2),
                                  ShaderMask(
                                    shaderCallback: (b) => DG.violetGrad.createShader(b),
                                    child: Text(
                                      _fmtMin(total),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 26,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Text('of ${_fmtMin(limit)}',
                                      style: const TextStyle(
                                          color: DG.mutedFg, fontSize: 10,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _heroStat('Remaining',
                                  overLimit ? 'Over limit' : _fmtMin(remaining),
                                  color: overLimit ? DG.destructive : DG.secondary),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(color: DG.border, height: 1),
                              ),
                              _heroStat('Best streak',
                                  '${streak.longestStreak} days',
                                  color: DG.secondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Streak chip
                    GestureDetector(
                      onTap: () => context.go('/streaks'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: DG.streak.withAlpha(0x1A),
                          borderRadius: BorderRadius.circular(DG.r16),
                          border: Border.all(color: DG.streak.withAlpha(0x44)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                gradient: DG.streakGrad,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.local_fire_department,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (b) => DG.streakGrad.createShader(b),
                                    child: Text(
                                      streak.currentStreak > 0
                                          ? '${streak.currentStreak} day streak 🔥'
                                          : 'Start your streak today!',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text(
                                    streak.currentStreak > 0
                                        ? 'Keep it going — you\'re doing great.'
                                        : 'Complete a focus session to begin.',
                                    style: const TextStyle(
                                        color: DG.mutedFg, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: DG.mutedFg, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value, {required Color color}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(),
          style: const TextStyle(
              color: DG.mutedFg, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w700)),
    ],
  );

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      ('Focus', Icons.timer_rounded, DG.violetGrad, '/timer'),
      ('Stats', Icons.bar_chart_rounded, DG.mintGrad, '/stats'),
      ('Limits', Icons.lock_rounded, DG.coralGrad, '/settings'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: actions.map((a) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: a.$1 == 'Limits' ? 0 : 10),
              child: GestureDetector(
                onTap: () {
                  if (a.$1 == 'Limits') {
                    // Go to Settings and flag that Daily Limit should be
                    // opened/scrolled-to once there.
                    context.go('/settings', extra: {'scrollTo': 'dailyLimit'});
                  } else {
                    context.go(a.$4);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DG.glassBg,
                    borderRadius: BorderRadius.circular(DG.r24),
                    border: Border.all(color: DG.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          gradient: a.$3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(a.$2, color: Colors.white, size: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(a.$1,
                          style: const TextStyle(
                              color: DG.fg, fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopOffenders(BuildContext context, UsageState usage, SettingsState settings) {
    if (usage.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: CircularProgressIndicator(color: DG.primary)),
      );
    }

    if (usage.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _PermissionCard(onGrant: () => usage.requestPermission()),
      );
    }

    final sorted = usage.dailyUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.where((e) => e.value >= 1).take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top offenders',
                  style: TextStyle(
                      color: DG.fg, fontSize: 18, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => context.go('/stats', extra: {'tab': 'appBreakdown'}),
                child: Text('See all',
                    style: TextStyle(
                        color: DG.mutedFg, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: DG.glassBg,
              borderRadius: BorderRadius.circular(DG.r32),
              border: Border.all(color: DG.border),
            ),
            padding: const EdgeInsets.all(8),
            child: top3.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No significant usage yet today.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DG.mutedFg),
              ),
            )
                : Column(
              children: top3.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final max = top3.first.value;
                return _AppRow(
                  packageName: e.key,
                  minutes: e.value,
                  maxMinutes: max,
                  isLast: i == top3.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(UsageState usage) {
    final total = usage.totalUsageMinutes;
    String msg;
    if (total == 0) {
      msg = 'Open the app and use your phone to start tracking. 📱';
    } else if (total > 180) {
      msg = 'You\'ve been on your phone for ${_fmtMin(total)} today. '
          'Consider a focus session to wind down. 🧘';
    } else {
      msg = 'Only ${_fmtMin(total)} of screen time today — you\'re on track! Keep it up. 🌿';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: DG.glassBg,
          borderRadius: BorderRadius.circular(DG.r32),
          border: Border.all(color: DG.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DG.r32),
          child: Stack(
            children: [
              Positioned(top: -20, right: -20,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [DG.accent.withAlpha(0x44), Colors.transparent]),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: DG.coralGrad,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TODAY'S INSIGHT",
                              style: TextStyle(
                                  color: DG.mutedFg, fontSize: 9,
                                  fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                          const SizedBox(height: 6),
                          Text(msg,
                              style: const TextStyle(
                                  color: DG.fg, fontSize: 13,
                                  fontWeight: FontWeight.w600, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtMin(int m) {
    final h = m ~/ 60; final min = m % 60;
    if (h > 0 && min > 0) return '${h}h ${min}m';
    if (h > 0) return '${h}h';
    return '${min}m';
  }
}

// ── Permission card ──────────────────────────────────────────────────────────
class _PermissionCard extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionCard({required this.onGrant});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: DG.glassBg,
      borderRadius: BorderRadius.circular(DG.r32),
      border: Border.all(color: DG.border),
    ),
    child: Column(
      children: [
        const Icon(Icons.lock_outline, color: DG.primary, size: 48),
        const SizedBox(height: 16),
        const Text('Usage Access Required',
            style: TextStyle(color: DG.fg, fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Grant permission to see your real screen time data.',
            style: TextStyle(color: DG.mutedFg, fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onGrant,
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('Grant Permission'),
        ),
      ],
    ),
  );
}

// ── App row widget ────────────────────────────────────────────────────────────
class _AppRow extends StatelessWidget {
  final String packageName;
  final int minutes;
  final int maxMinutes;
  final bool isLast;
  const _AppRow({required this.packageName, required this.minutes,
    required this.maxMinutes, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final name = AppNameService.getFriendlyName(packageName);
    final meta = AppNameService.getAppMeta(packageName);
    final pct = (minutes / maxMinutes).clamp(0.0, 1.0);
    final hrs = minutes ~/ 60; final mins = minutes % 60;
    final timeStr = hrs > 0 ? '${hrs}h ${mins}m' : '${mins}m';

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DG.r24),
      ),
      child: Row(
        children: [
          AppIconWidget(packageName: packageName, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(name,
                          style: const TextStyle(
                              color: DG.fg, fontSize: 14,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(timeStr,
                        style: const TextStyle(
                            color: DG.mutedFg, fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: DG.muted,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(meta.colorHex)),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ring painter ──────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final bool overLimit;
  const _RingPainter({required this.progress, required this.overLimit});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const startAngle = -math.pi / 2;
    const stroke = 8.0;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = DG.muted
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final shader = (overLimit ? DG.coralGrad : DG.violetGrad)
          .createShader(rect);
      canvas.drawArc(
        rect, startAngle, 2 * math.pi * progress, false,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.overLimit != overLimit;
}