import 'package:flutter/material.dart';
import '../services/device_auth_service.dart';
import '../../core/theme/app_theme.dart';

/// Gates [childBuilder] behind device authentication.
///
/// Usage:
/// ```dart
/// SecureSectionGuard(
///   locked: context.watch<SettingsState>().strictMode,
///   title: 'Top Offenders',
///   reason: 'Authenticate to view Top Offenders',
///   childBuilder: (context) => _buildTopOffenders(context, usage, settings),
/// )
/// ```
///
/// Behavior:
/// - If [locked] is false, [childBuilder] is called immediately — no
///   authentication needed. This is the Strict-Mode-OFF case.
/// - If [locked] is true, [childBuilder] is NOT called at all until
///   authentication succeeds — the sensitive widget tree (and the data
///   it displays) is never built, not merely hidden behind an overlay.
/// - Authentication is required again every time this widget is freshly
///   mounted (e.g. navigating away and back re-locks it).
/// - The guard also re-locks automatically if the app leaves the
///   foreground, or if Strict Mode is switched ON while the section is
///   already open — so there's no window where cached state, a
///   backgrounded app, or a stale widget tree exposes the content.
class SecureSectionGuard extends StatefulWidget {
  final bool locked;
  final String title;
  final String reason;
  final WidgetBuilder childBuilder;

  const SecureSectionGuard({
    super.key,
    required this.locked,
    required this.childBuilder,
    this.title = 'Protected content',
    this.reason = 'Authenticate to view this section',
  });

  @override
  State<SecureSectionGuard> createState() => _SecureSectionGuardState();
}

class _SecureSectionGuardState extends State<SecureSectionGuard>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _authenticating = false;
  bool _lastAttemptFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _unlocked = !widget.locked;
  }

  @override
  void didUpdateWidget(covariant SecureSectionGuard old) {
    super.didUpdateWidget(old);
    // Strict Mode was just turned ON while this section was visible —
    // re-lock immediately instead of trusting the prior unlocked state.
    if (widget.locked && !old.locked) {
      setState(() => _unlocked = false);
    }
    // Strict Mode was turned OFF — nothing left to gate.
    if (!widget.locked && old.locked) {
      setState(() => _unlocked = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding the app (task switcher, lock screen, etc.) re-locks
    // any currently-open protected section.
    if (widget.locked && state != AppLifecycleState.resumed) {
      if (mounted) setState(() => _unlocked = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _tryUnlock() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _lastAttemptFailed = false;
    });

    final ok = await DeviceAuthService.instance.authenticate(
      reason: widget.reason,
    );

    if (!mounted) return;
    setState(() {
      _authenticating = false;
      _unlocked = ok;
      _lastAttemptFailed = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sensitive child is only ever constructed on this branch — if
    // locked and not yet unlocked, childBuilder is never invoked.
    if (!widget.locked || _unlocked) {
      return widget.childBuilder(context);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DG.glassBg,
        borderRadius: BorderRadius.circular(DG.r32),
        border: Border.all(color: DG.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_rounded, color: DG.mutedFg, size: 32),
          const SizedBox(height: 12),
          Text(widget.title,
              style: const TextStyle(
                  color: DG.fg, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            _lastAttemptFailed
                ? 'Authentication required to view this.'
                : 'Protected by Strict Mode.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: DG.mutedFg, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _authenticating ? null : _tryUnlock,
            icon: _authenticating
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.fingerprint, size: 16),
            label: Text(_authenticating ? 'Verifying…' : 'Unlock'),
          ),
        ],
      ),
    );
  }
}