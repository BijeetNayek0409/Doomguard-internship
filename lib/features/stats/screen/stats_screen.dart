import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/usage_state.dart';
import '../../../shared/models/timer_state.dart';
import '../../../shared/services/app_name_service.dart';
import '../../../shared/widgets/app_icon_widget.dart';
import '../../../core/theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _tab = 1; // 0=day, 1=week, 2=month

  @override
  Widget build(BuildContext context) {
    return Consumer2<UsageState, TimerState>(
      builder: (_, usage, timer, __) {
        return Scaffold(
          backgroundColor: DG.bg,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildTabs()),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildHeroStat(usage)),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildBarChart(usage)),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildInsightCard(timer)),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildAppBreakdown(usage)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(
      children: [
        const Expanded(
          child: Text('Insights',
              style: TextStyle(
                  color: DG.fg, fontSize: 24, fontWeight: FontWeight.w700)),
        ),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: DG.glassBg,
            borderRadius: BorderRadius.circular(DG.r16),
            border: Border.all(color: DG.border),
          ),
          child: const Icon(Icons.calendar_today_rounded,
              color: DG.fg, size: 16),
        ),
      ],
    ),
  );

  Widget _buildTabs() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DG.glassBg,
        borderRadius: BorderRadius.circular(DG.r16),
        border: Border.all(color: DG.border),
      ),
      child: Row(
        children: ['Day', 'Week', 'Month'].asMap().entries.map((e) {
          final i = e.key; final label = e.value;
          final sel = i == _tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: sel ? DG.violetGrad : null,
                  borderRadius: BorderRadius.circular(DG.r12),
                ),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: sel ? Colors.white : DG.mutedFg,
                      fontSize: 13, fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );

  Widget _buildHeroStat(UsageState usage) {
    final total = usage.totalUsageMinutes;
    final h = total ~/ 60; final m = total % 60;
    final str = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SCREEN TIME TODAY',
              style: TextStyle(
                  color: DG.mutedFg, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (b) => DG.violetGrad.createShader(b),
                child: Text(str,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 52,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DG.secondary.withAlpha(0x22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down_rounded,
                        color: DG.secondary, size: 14),
                    const SizedBox(width: 4),
                    Text('Today',
                        style: const TextStyle(
                            color: DG.secondary, fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const Text("Today's screen time from midnight.",
              style: TextStyle(color: DG.mutedFg, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBarChart(UsageState usage) {
    final sorted = usage.dailyUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    final maxVal = top5.isEmpty ? 1 : top5.first.value;

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
          children: [
            // Bars
            SizedBox(
              height: 120,
              child: top5.isEmpty
                  ? const Center(
                      child: Text('No data yet',
                          style: TextStyle(color: DG.mutedFg)))
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: top5.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final pct = (e.value / maxVal).clamp(0.0, 1.0);
                        final meta = AppNameService.getAppMeta(e.key);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6)),
                                  child: Container(
                                    width: double.infinity,
                                    height: 100 * pct + 4,
                                    decoration: BoxDecoration(
                                      gradient: i == 0
                                          ? DG.violetGrad
                                          : LinearGradient(
                                              colors: [
                                                Color(meta.colorHex),
                                                Color(meta.colorHex)
                                                    .withAlpha(0xBB)
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            // X-axis icons
            if (top5.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: top5.map((e) => Expanded(
                  child: Center(
                    child: AppIconWidget(packageName: e.key, size: 26),
                  ),
                )).toList(),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: DG.border),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOP APP',
                        style: TextStyle(
                            color: DG.mutedFg, fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    Text(
                      top5.isEmpty
                          ? '—'
                          : AppNameService.getFriendlyName(top5.first.key),
                      style: const TextStyle(
                          color: DG.fg, fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL APPS',
                        style: TextStyle(
                            color: DG.mutedFg, fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    ShaderMask(
                      shaderCallback: (b) => DG.mintGrad.createShader(b),
                      child: Text(
                        '${usage.dailyUsage.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(TimerState timer) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DG.glassBg,
        borderRadius: BorderRadius.circular(DG.r32),
        border: Border.all(color: DG.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: DG.violetGrad,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bedtime_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PATTERN',
                    style: TextStyle(
                        color: DG.mutedFg, fontSize: 9,
                        fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: DG.fg, fontSize: 13,
                        fontWeight: FontWeight.w600, height: 1.4),
                    children: [
                      const TextSpan(text: 'You completed '),
                      TextSpan(
                        text: '${timer.sessionsToday} focus sessions',
                        style: const TextStyle(color: DG.primary),
                      ),
                      const TextSpan(
                          text: ' today with '),
                      TextSpan(
                        text: '${timer.focusMinutesToday}m',
                        style: const TextStyle(color: DG.secondary),
                      ),
                      const TextSpan(text: ' of focused time.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildAppBreakdown(UsageState usage) {
    final sorted = usage.dailyUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final apps = sorted.where((e) => e.value >= 1).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('App breakdown',
              style: TextStyle(
                  color: DG.fg, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: DG.glassBg,
              borderRadius: BorderRadius.circular(DG.r32),
              border: Border.all(color: DG.border),
            ),
            padding: const EdgeInsets.all(8),
            child: apps.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No app usage data yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: DG.mutedFg)),
                  )
                : Column(
                    children: apps.asMap().entries.map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      final max = apps.first.value;
                      final name = AppNameService.getFriendlyName(e.key);
                      final pct = (e.value / max).clamp(0.0, 1.0);
                      final h = e.value ~/ 60; final m = e.value % 60;
                      final t = h > 0 ? '${h}h ${m}m' : '${m}m';

                      return Container(
                        margin: EdgeInsets.only(
                            bottom: i == apps.length - 1 ? 0 : 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DG.r24),
                        ),
                        child: Row(
                          children: [
                            AppIconWidget(packageName: e.key, size: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          color: DG.fg, fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: DG.muted,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              DG.primary),
                                      minHeight: 3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(t,
                                    style: const TextStyle(
                                        color: DG.fg, fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                  i == 0 ? 'Most used' : '${(pct * 100).round()}%',
                                  style: TextStyle(
                                    color: i == 0 ? DG.accent : DG.mutedFg,
                                    fontSize: 10, fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
