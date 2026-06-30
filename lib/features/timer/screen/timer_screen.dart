import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/timer_state.dart';
import '../../../shared/models/streak_state.dart';
import '../../../core/theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPreset = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Presets matching Lovable FocusScreen
  static const _presets = [
    (25, 'Pomodoro', Icons.coffee_rounded),
    (50, 'Deep work', Icons.work_rounded),
    (90, 'Flow', Icons.menu_book_rounded),
    (15, 'Quick', Icons.bedtime_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerState, StreakState>(
      builder: (_, timer, streak, __) {
        // Sync pulse with running state
        if (timer.isRunning && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        } else if (!timer.isRunning && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.value = 0;
        }

        final progress = timer.progress;
        final mm = (timer.secondsLeft ~/ 60).toString().padLeft(2, '0');
        final ss = (timer.secondsLeft % 60).toString().padLeft(2, '0');
        final isBreak = timer.isBreak;

        return Scaffold(
          backgroundColor: DG.bg,
          body: Stack(
            children: [
              // Ambient orbs
              Positioned(top: 80, left: -30,
                child: _orb(160, DG.primary.withAlpha(0x33))),
              Positioned(bottom: 100, right: -30,
                child: _orb(180, DG.accent.withAlpha(0x22))),

              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(timer),
                    const SizedBox(height: 24),

                    // ── Timer ring ──
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => Transform.scale(
                            scale: timer.isRunning ? _pulseAnim.value : 1.0,
                            child: SizedBox(
                              width: 280, height: 280,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow ring (when running)
                                  if (timer.isRunning)
                                    Container(
                                      width: 280, height: 280,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: DG.primary.withAlpha(0x22),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  CustomPaint(
                                    size: const Size(260, 260),
                                    painter: _TimerRingPainter(
                                        progress: progress,
                                        isBreak: isBreak),
                                  ),
                                  // Center text
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        timer.isRunning ? 'REMAINING' : 'SESSION',
                                        style: const TextStyle(
                                            color: DG.mutedFg, fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 2),
                                      ),
                                      const SizedBox(height: 4),
                                      ShaderMask(
                                        shaderCallback: (b) =>
                                            (isBreak ? DG.mintGrad : DG.violetGrad)
                                                .createShader(b),
                                        child: Text(
                                          '$mm:$ss',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 62,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -2),
                                        ),
                                      ),
                                      Text(
                                        timer.isRunning
                                            ? isBreak ? '☕ Break time' : '🔒 Focus mode'
                                            : 'Tap a preset below',
                                        style: const TextStyle(
                                            color: DG.mutedFg, fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Presets or controls ──
                    if (!timer.isRunning) ...[
                      _buildPresets(timer),
                      const SizedBox(height: 16),
                      _buildStartButton(timer, streak),
                    ] else
                      _buildRunningControls(timer, streak),

                    const SizedBox(height: 24),

                    // Sessions info
                    _buildSessionsInfo(timer),
                    const SizedBox(height: 90),
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

  Widget _buildHeader(TimerState timer) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FOCUS',
                style: TextStyle(
                    color: DG.mutedFg, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 2)),
            Text(
              timer.isRunning ? 'In flow ✨' : 'Ready when you are',
              style: const TextStyle(
                  color: DG.fg, fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildPresets(TimerState timer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 2.6,
        ),
        itemCount: _presets.length,
        itemBuilder: (_, i) {
          final (mins, label, icon) = _presets[i];
          final selected = i == _selectedPreset;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPreset = i);
              timer.setDuration(mins);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected ? DG.primary.withAlpha(0x22) : DG.glassBg,
                borderRadius: BorderRadius.circular(DG.r24),
                border: Border.all(
                  color: selected ? DG.primary : DG.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: selected ? DG.violetGrad : null,
                      color: selected ? null : DG.muted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon,
                        color: selected ? Colors.white : DG.mutedFg, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${mins}m',
                          style: TextStyle(
                              color: selected ? DG.fg : DG.fg,
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(label,
                          style: const TextStyle(
                              color: DG.mutedFg, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton(TimerState timer, StreakState streak) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GestureDetector(
      onTap: () => timer.startTimer(),
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: DG.violetGrad,
          borderRadius: BorderRadius.circular(DG.r16),
          boxShadow: [
            BoxShadow(
              color: DG.primary.withAlpha(0x55),
              blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('Start focus',
                style: TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ),
  );

  Widget _buildRunningControls(TimerState timer, StreakState streak) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => timer.pauseTimer(),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: DG.glassBg,
                borderRadius: BorderRadius.circular(DG.r16),
                border: Border.all(color: DG.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pause_rounded, color: DG.fg),
                  SizedBox(width: 6),
                  Text('Pause',
                      style: TextStyle(
                          color: DG.fg, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => timer.resetTimer(),
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: DG.destructive.withAlpha(0x22),
              borderRadius: BorderRadius.circular(DG.r16),
              border: Border.all(color: DG.destructive.withAlpha(0x44)),
            ),
            child: const Icon(Icons.stop_rounded,
                color: DG.destructive, size: 22),
          ),
        ),
      ],
    ),
  );

  Widget _buildSessionsInfo(TimerState timer) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: DG.glassBg,
        borderRadius: BorderRadius.circular(DG.r24),
        border: Border.all(color: DG.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoStat(timer.sessionsToday.toString(), 'Sessions', DG.violetGrad),
          _vDivider(),
          _infoStat('${timer.focusMinutesToday}m', 'Focus time', DG.mintGrad),
          _vDivider(),
          _infoStat(
              timer.sessionsToday >= 4 ? 'Long' : 'Short',
              'Next break', DG.streakGrad),
        ],
      ),
    ),
  );

  Widget _vDivider() =>
      Container(height: 28, width: 1, color: DG.border);

  Widget _infoStat(String v, String l, LinearGradient g) => Column(
    children: [
      ShaderMask(
        shaderCallback: (b) => g.createShader(b),
        child: Text(v,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 2),
      Text(l,
          style: const TextStyle(
              color: DG.mutedFg, fontSize: 10, fontWeight: FontWeight.w600)),
    ],
  );
}

// ── Timer ring painter ────────────────────────────────────────────────────────
class _TimerRingPainter extends CustomPainter {
  final double progress;
  final bool isBreak;
  const _TimerRingPainter({required this.progress, required this.isBreak});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const stroke = 6.0;

    canvas.drawCircle(center, radius,
        Paint()
          ..color = DG.muted
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final grad = isBreak ? DG.mintGrad : DG.violetGrad;
      canvas.drawArc(
        rect, -math.pi / 2, 2 * math.pi * (1 - progress), false,
        Paint()
          ..shader = grad.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerRingPainter old) =>
      old.progress != progress || old.isBreak != isBreak;
}
