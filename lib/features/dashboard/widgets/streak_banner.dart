// lib/features/dashboard/widgets/streak_banner.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/streak_state.dart';
import '../../../shared/models/timer_state.dart';
import '../../../core/theme/app_theme.dart';

class StreakBanner extends StatelessWidget {
  const StreakBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<StreakState, TimerState>(
      builder: (_, streak, timer, __) {
        final current = streak.currentStreak;
        final sessions = timer.sessionsToday;

        // Pick message based on state
        String message;
        Color accentColor;
        LinearGradient grad;
        String emoji;

        if (current >= 7) {
          message = '$current-day streak! You\'re unstoppable 🚀';
          accentColor = DG.streak;
          grad = DG.streakGrad;
          emoji = '🔥';
        } else if (current > 0) {
          message = '$current-day streak — keep it alive today!';
          accentColor = DG.primary;
          grad = DG.violetGrad;
          emoji = '⚡';
        } else if (sessions > 0) {
          message = '$sessions session${sessions == 1 ? '' : 's'} done — start your streak!';
          accentColor = DG.secondary;
          grad = DG.mintGrad;
          emoji = '🌱';
        } else {
          message = 'Start a focus session to begin your streak';
          accentColor = DG.mutedFg;
          grad = DG.violetGrad;
          emoji = '💤';
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(0x15),
            borderRadius: BorderRadius.circular(DG.r24),
            border: Border.all(color: accentColor.withAlpha(0x44)),
          ),
          child: Row(
            children: [
              // Flame / emoji with gradient bg
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: grad,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message,
                        style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    // Mini week dots
                    Row(
                      children: List.generate(7, (i) {
                        final active = streak.weekActivity[i];
                        final today = DateTime.now().weekday - 1;
                        final isToday = i == today;
                        return Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? accentColor
                                : isToday
                                ? accentColor.withAlpha(0x44)
                                : DG.muted,
                            border: isToday
                                ? Border.all(color: accentColor, width: 1.5)
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Streak count badge
              if (current > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: grad,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$current',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ),
            ],
          ),
        );
      },
    );
  }
}