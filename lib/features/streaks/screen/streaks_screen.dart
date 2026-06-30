// lib/features/streaks/screen/streaks_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/streak_state.dart';
import '../../../shared/models/timer_state.dart';
import '../../../shared/models/badge_model.dart';
import '../../../core/theme/app_theme.dart';

class StreaksScreen extends StatelessWidget {
  const StreaksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<StreakState, TimerState>(
      builder: (_, streak, timer, __) {
        final badges = computeBadges(
          currentStreak: streak.currentStreak,
          longestStreak: streak.longestStreak,
          sessionsToday: timer.sessionsToday,
          focusMinutesToday: timer.focusMinutesToday,
          totalSavedHours: streak.totalSavedHours,
        );
        final earnedCount = badges.where((b) => b.earned).length;

        return Scaffold(
          backgroundColor: DG.bg,
          body: Stack(
            children: [
              Positioned(
                top: -40, right: -40,
                child: _orb(160, DG.streak.withAlpha(0x22)),
              ),
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(child: _buildXpCard(streak, timer)),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(child: _buildStatTiles(streak, timer)),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(child: _buildWeekGrid(streak)),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                        child: _buildWeeklyGoal(timer)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                        child: _buildBadges(badges, earnedCount)),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                        child: _buildMotivational(streak, timer)),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orb(double s, Color c) => Container(
    width: s, height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  Widget _buildHeader() => const Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR JOURNEY',
            style: TextStyle(
                color: DG.mutedFg, fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        SizedBox(height: 4),
        Text('Rewards',
            style: TextStyle(
                color: DG.fg, fontSize: 28,
                fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _buildXpCard(StreakState streak, TimerState timer) {
    const xpGoal = 1000;
    final xp = (streak.currentStreak * 100) + (timer.sessionsToday * 50);
    final level = (xp / xpGoal).floor() + 1;
    final xpInLevel = xp % xpGoal;
    final pct = (xpInLevel / xpGoal).clamp(0.0, 1.0);

    const titles = [
      'Mindful Scroller', 'Focus Apprentice', 'Flow Seeker',
      'Streak Hunter', 'Zen Warrior', 'Digital Monk',
    ];
    final title = titles[(level - 1).clamp(0, titles.length - 1)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: DG.violetGrad,
          borderRadius: BorderRadius.circular(DG.r36),
          boxShadow: [
            BoxShadow(
              color: DG.primary.withAlpha(0x55),
              blurRadius: 28, spreadRadius: -6,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DG.r36),
          child: Stack(
            children: [
              Positioned(
                top: -40, right: -40,
                child: Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1AFFFFFF),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEVEL $level',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10,
                            fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('$xpInLevel',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const Text(' / $xpGoal XP',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${xpGoal - xpInLevel} XP to next level',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTiles(StreakState streak, TimerState timer) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        _statTile('${streak.currentStreak}', 'Day streak',
            Icons.local_fire_department, DG.streakGrad),
        const SizedBox(width: 10),
        _statTile('${timer.sessionsToday}', 'Sessions',
            Icons.bolt, DG.mintGrad),
        const SizedBox(width: 10),
        _statTile('${streak.savedHours}h', 'Hours saved',
            Icons.emoji_events_rounded, DG.violetGrad),
      ],
    ),
  );

  Widget _statTile(String v, String l, IconData icon, LinearGradient g) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
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
                  gradient: g,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (b) => g.createShader(b),
                child: Text(v,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 2),
              Text(l,
                  style: const TextStyle(
                      color: DG.mutedFg, fontSize: 9,
                      fontWeight: FontWeight.w700, letterSpacing: 0.8)),
            ],
          ),
        ),
      );

  // ── Week activity grid ──────────────────────────────────────────────────────
  Widget _buildWeekGrid(StreakState streak) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = DateTime.now().weekday - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DG.glassBg,
          borderRadius: BorderRadius.circular(DG.r32),
          border: Border.all(color: DG.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('THIS WEEK',
                style: TextStyle(
                    color: DG.mutedFg, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final active = streak.weekActivity[i];
                final isToday = i == todayIndex;
                final isPast = i < todayIndex;

                Color bgColor;
                Color textColor;
                Border? border;

                if (active) {
                  bgColor = DG.primary;
                  textColor = Colors.white;
                } else if (isToday) {
                  bgColor = DG.primary.withAlpha(0x22);
                  textColor = DG.primary;
                  border = Border.all(color: DG.primary, width: 1.5);
                } else if (isPast) {
                  bgColor = DG.muted;
                  textColor = DG.mutedFg;
                } else {
                  bgColor = DG.muted.withAlpha(0x55);
                  textColor = DG.mutedFg.withAlpha(0x88);
                }

                return Column(
                  children: [
                    Text(days[i],
                        style: TextStyle(
                            color: DG.mutedFg, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: border,
                        boxShadow: active
                            ? [
                          BoxShadow(
                            color: DG.primary.withAlpha(0x55),
                            blurRadius: 8,
                            spreadRadius: -2,
                          )
                        ]
                            : null,
                      ),
                      child: Center(
                        child: active
                            ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                            : Text(
                          isToday ? '●' : '',
                          style: TextStyle(
                              color: textColor, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoal(TimerState timer) {
    const goalMins = 360;
    final actual = (timer.focusMinutesToday * 7).clamp(0, goalMins);
    final pct = (actual / goalMins).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DG.glassBg,
          borderRadius: BorderRadius.circular(DG.r32),
          border: Border.all(color: DG.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WEEKLY GOAL',
                        style: TextStyle(
                            color: DG.mutedFg, fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    SizedBox(height: 4),
                    Text('Save 6 hours',
                        style: TextStyle(
                            color: DG.fg, fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                ShaderMask(
                  shaderCallback: (b) => DG.mintGrad.createShader(b),
                  child: Text('${(pct * 100).round()}%',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 28,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: DG.muted,
                valueColor: AlwaysStoppedAnimation(DG.secondary),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: DG.streak, size: 14),
                const SizedBox(width: 6),
                Text(
                  pct >= 1.0
                      ? 'Goal achieved! 🎉'
                      : '${goalMins - actual} minutes to your reward',
                  style: const TextStyle(color: DG.mutedFg, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Badges ──────────────────────────────────────────────────────────────────
  Widget _buildBadges(List<BadgeModel> badges, int earnedCount) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Badges',
                style: TextStyle(
                    color: DG.fg, fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DG.primary.withAlpha(0x22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DG.primary.withAlpha(0x44)),
              ),
              child: Text('$earnedCount / ${badges.length}',
                  style: const TextStyle(
                      color: DG.primary, fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.72,
          ),
          itemCount: badges.length,
          itemBuilder: (_, i) => _badgeCell(badges[i]),
        ),
      ],
    ),
  );

  Widget _badgeCell(BadgeModel badge) {
    return AnimatedOpacity(
      opacity: badge.earned ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: DG.glassBg,
          borderRadius: BorderRadius.circular(DG.r24),
          border: Border.all(
            color: badge.earned
                ? DG.primary.withAlpha(0x66)
                : DG.border,
            width: badge.earned ? 1.5 : 1,
          ),
          boxShadow: badge.earned
              ? [
            BoxShadow(
              color: DG.primary.withAlpha(0x22),
              blurRadius: 12,
              spreadRadius: -2,
            )
          ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(badge.emoji,
                        style: const TextStyle(fontSize: 30)),
                    const SizedBox(height: 4),
                    Text(badge.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: DG.fg, fontSize: 10,
                            fontWeight: FontWeight.w700, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(badge.requirement,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: DG.mutedFg, fontSize: 9, height: 1.1)),
                  ],
                ),
              ),
            ),
            if (badge.earned)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    gradient: DG.violetGrad,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 11),
                ),
              )
            else
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: DG.muted,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: DG.mutedFg, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivational(StreakState streak, TimerState timer) {
    String msg;
    if (streak.currentStreak >= 7) {
      msg = '"You\'ve saved ${streak.savedHours} hours this week."';
    } else if (timer.sessionsToday > 0) {
      msg =
      '"Great work completing ${timer.sessionsToday} session${timer.sessionsToday == 1 ? '' : 's'} today."';
    } else {
      msg = '"Every moment of focus is a step toward freedom."';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: DG.mintGrad,
          borderRadius: BorderRadius.circular(DG.r32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg,
                style: const TextStyle(
                    color: Color(0xFF0D0D1A), fontSize: 20,
                    fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 8),
            const Text(
              'That\'s a whole movie marathon. Or a great nap. 🌿',
              style: TextStyle(
                  color: Color(0xBF0D0D1A), fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}