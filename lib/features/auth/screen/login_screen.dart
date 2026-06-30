// lib/features/auth/screen/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    return Scaffold(
      backgroundColor: DG.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: DG.violetGrad,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: DG.primary.withAlpha(0x55),
                        blurRadius: 24,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 28),
                const Text('DoomGuard',
                    style: TextStyle(
                        color: DG.fg,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Take back your screen time',
                    style: TextStyle(color: DG.mutedFg, fontSize: 14)),
                const SizedBox(height: 48),
                if (authState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authState.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                authState.isLoading
                    ? const CircularProgressIndicator(color: DG.primary)
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.read<AuthState>().signInWithGoogle(),
                    icon: const Icon(Icons.login_rounded, size: 20),
                    label: const Text('Sign in with Google',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(DG.r16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}