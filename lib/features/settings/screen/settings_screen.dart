// lib/features/settings/screen/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/settings_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/auth_state.dart';
import 'help_feedback_screen.dart'; // ✅ ADD

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsState>(
      builder: (_, settings, __) => Scaffold(
        backgroundColor: DG.bg,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildProfile(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: _buildGroup('Habits', [
                  _SettingsItem(
                    icon: Icons.lock_rounded,
                    label: 'Daily limit',
                    value: _fmtLimit(settings.dailyLimitMinutes),
                    onTap: () => _showLimitSheet(context, settings),
                  ),
                  _SettingsItem(
                    icon: Icons.bedtime_rounded,
                    label: 'Wind-down',
                    value:
                    '${_fmtHour(settings.downtimeStart)} – ${_fmtHour(settings.downtimeEnd)}',
                    onTap: () => _showDowntimeSheet(context, settings),
                  ),
                  _SettingsItem(
                    icon: Icons.notifications_rounded,
                    label: 'Smart nudges',
                    value: settings.notificationsEnabled ? 'On' : 'Off',
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: settings.setNotifications,
                    ),
                  ),
                ]),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _buildGroup('Account', [
                  _SettingsItem(
                    icon: Icons.smartphone_rounded,
                    label: 'Strict mode',
                    trailing: Switch(
                      value: settings.strictMode,
                      onChanged: settings.setStrictMode,
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.favorite_rounded,
                    label: 'Daily goal',
                    value: _fmtLimit(settings.dailyLimitMinutes),
                  ),
                  const _SettingsItem(
                    icon: Icons.shield_rounded,
                    label: 'Privacy',
                  ),
                ]),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _buildGroup('Support', [
                  _SettingsItem(                          // ✅ removed const
                    icon: Icons.help_outline_rounded,
                    label: 'Help & feedback',
                    onTap: () => Navigator.push(          // ✅ ADD onTap
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpFeedbackScreen(),
                      ),
                    ),
                  ),
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign out',
                    danger: true,
                    onTap: () => _confirmSignOut(context),
                  ),
                ]),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'DoomGuard v1.0 · Made by VEBA',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DG.mutedFg, fontSize: 11),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => const Padding(
    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Text('Settings',
        style: TextStyle(
            color: DG.fg, fontSize: 24, fontWeight: FontWeight.w700)),
  );

  Widget _buildProfile(BuildContext context) {
    final authState = context.watch<AuthState>();
    final user = authState.appUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DG.glassBg,
          borderRadius: BorderRadius.circular(DG.r32),
          border: Border.all(color: DG.border),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: DG.violetGrad,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: DG.primary.withAlpha(0x55),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: user?.photoUrl.isNotEmpty == true
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(user!.photoUrl, fit: BoxFit.cover),
              )
                  : Center(
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'D',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'DoomGuard User',
                    style: const TextStyle(
                        color: DG.fg,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    user?.email ?? 'Mindful Scroller',
                    style:
                    const TextStyle(color: DG.mutedFg, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: DG.streak.withAlpha(0x22),
                      borderRadius: BorderRadius.circular(20),
                      border:
                      Border.all(color: DG.streak.withAlpha(0x44)),
                    ),
                    child: const Text(
                      '🔥 Active user',
                      style: TextStyle(
                          color: DG.streak,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(String label, List<_SettingsItem> items) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
                color: DG.mutedFg,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: DG.glassBg,
            borderRadius: BorderRadius.circular(DG.r24),
            border: Border.all(color: DG.border),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return Column(
                children: [
                  _buildRow(item),
                  if (i < items.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Divider(color: DG.border, height: 1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildRow(_SettingsItem item) => InkWell(
    borderRadius: BorderRadius.circular(DG.r16),
    onTap: item.onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.danger
                  ? DG.destructive.withAlpha(0x22)
                  : DG.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon,
                color: item.danger ? DG.destructive : DG.fg, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                  color: item.danger ? DG.destructive : DG.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (item.trailing != null)
            item.trailing!
          else if (item.value.isNotEmpty) ...[
            Text(item.value,
                style: const TextStyle(
                    color: DG.mutedFg,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
          ],
          if (!item.danger && item.trailing == null)
            const Icon(Icons.chevron_right_rounded,
                color: DG.mutedFg, size: 18),
        ],
      ),
    ),
  );

  void _showLimitSheet(BuildContext context, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DG.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(DG.r32)),
      ),
      builder: (_) => _LimitSheet(settings: settings),
    );
  }

  void _showDowntimeSheet(BuildContext context, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DG.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(DG.r32)),
      ),
      builder: (_) => _DowntimeSheet(settings: settings),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DG.card,
        title: const Text('Sign out?', style: TextStyle(color: DG.fg)),
        content: const Text(
          'You\'ll need to sign in again to continue.',
          style: TextStyle(color: DG.mutedFg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AuthState>().signOut();
            },
            child: const Text('Sign out',
                style: TextStyle(color: DG.destructive)),
          ),
        ],
      ),
    );
  }

  static String _fmtLimit(int m) {
    final h = m ~/ 60;
    final min = m % 60;
    if (h > 0 && min > 0) return '${h}h ${min}m';
    if (h > 0) return '${h}h';
    return '${min}m';
  }

  static String _fmtHour(int h) {
    final period = h < 12 ? 'AM' : 'PM';
    final display = h == 0 ? 12 : h > 12 ? h - 12 : h;
    return '$display $period';
  }
}

// ── Settings item data ────────────────────────────────────────────────────────
class _SettingsItem {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value = '',
    this.trailing,
    this.onTap,
    this.danger = false,
  });
}

// ── Limit sheet ───────────────────────────────────────────────────────────────
class _LimitSheet extends StatefulWidget {
  final SettingsState settings;
  const _LimitSheet({required this.settings});
  @override
  State<_LimitSheet> createState() => _LimitSheetState();
}

class _LimitSheetState extends State<_LimitSheet> {
  late double _val;

  @override
  void initState() {
    super.initState();
    _val = widget.settings.dailyLimitMinutes.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final h = _val.toInt() ~/ 60;
    final m = _val.toInt() % 60;
    final str =
    h > 0 && m > 0 ? '${h}h ${m}m' : h > 0 ? '${h}h' : '${m}m';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: DG.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Daily Limit',
              style: TextStyle(
                  color: DG.fg,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Center(
            child: ShaderMask(
              shaderCallback: (b) => DG.violetGrad.createShader(b),
              child: Text(str,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: DG.primary,
              thumbColor: DG.primary,
              inactiveTrackColor: DG.muted,
              trackHeight: 4,
            ),
            child: Slider(
              value: _val,
              min: 30,
              max: 480,
              divisions: 45,
              onChanged: (v) => setState(() => _val = v),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.settings.setDailyLimit(_val.toInt());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DG.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DG.r16)),
            ),
            child: const Text('Save limit',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Downtime sheet ────────────────────────────────────────────────────────────
class _DowntimeSheet extends StatefulWidget {
  final SettingsState settings;
  const _DowntimeSheet({required this.settings});
  @override
  State<_DowntimeSheet> createState() => _DowntimeSheetState();
}

class _DowntimeSheetState extends State<_DowntimeSheet> {
  late double _start, _end;

  @override
  void initState() {
    super.initState();
    _start = widget.settings.downtimeStart.toDouble();
    _end = widget.settings.downtimeEnd.toDouble();
  }

  String _h(double v) {
    final h = v.toInt();
    final p = h < 12 ? 'AM' : 'PM';
    final d = h == 0 ? 12 : h > 12 ? h - 12 : h;
    return '$d $p';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: DG.border,
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Wind-down Schedule',
            style: TextStyle(
                color: DG.fg,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 24),
        _sliderRow('Start', _start, (v) => setState(() => _start = v)),
        const SizedBox(height: 16),
        _sliderRow('End', _end, (v) => setState(() => _end = v)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            widget.settings.setDowntime(_start.toInt(), _end.toInt());
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DG.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DG.r16)),
          ),
          child: const Text('Save schedule',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  Widget _sliderRow(
      String label, double val, ValueChanged<double> onChange) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: DG.mutedFg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text(_h(val),
                  style: const TextStyle(
                      color: DG.fg,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: DG.primary,
              thumbColor: DG.primary,
              inactiveTrackColor: DG.muted,
              trackHeight: 4,
            ),
            child: Slider(
              value: val,
              min: 0,
              max: 23,
              divisions: 23,
              onChanged: onChange,
            ),
          ),
        ],
      );
}