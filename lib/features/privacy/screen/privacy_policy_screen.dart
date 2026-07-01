import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/privacy_state.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_hasScrolledToEnd &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 24) {
      setState(() => _hasScrolledToEnd = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleAgree() async {
    setState(() => _isAccepting = true);
    await context.read<PrivacyState>().accept();
    // No need to navigate manually — GoRouter's redirect will
    // pick up the change via refreshListenable and move on.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DG.bg,
      appBar: AppBar(
        backgroundColor: DG.bg,
        elevation: 0,
        title: const Text('Privacy Policy'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: const _PrivacyPolicyContent(),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_hasScrolledToEnd)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Please scroll to the end to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: DG.mutedFg,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_hasScrolledToEnd && !_isAccepting)
                            ? _handleAgree
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DG.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          DG.primary.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isAccepting
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'I Agree & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 14.5, height: 1.5);
    const headingStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: DG.primary,
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: headingStyle),
    );

    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text('•  $text', style: bodyStyle),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Privacy Policy for Doom Guard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Effective Date: July 1, 2026',
          style: bodyStyle.copyWith(color: DG.mutedFg),
        ),
        const SizedBox(height: 12),
        const Text(
          'At Doom Guard, your privacy is important to us. This Privacy '
              'Policy explains how we collect, use, and protect your '
              'information when you use our application.',
          style: bodyStyle,
        ),

        heading('1. Information We Collect'),
        Text('Google Sign-In', style: bodyStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text(
          'To access Doom Guard, users can sign in using their Google '
              'account. This authentication is provided securely by Google. '
              'We may receive basic profile information such as:',
          style: bodyStyle,
        ),
        bullet('Your name'),
        bullet('Email address'),
        bullet('Google account identifier'),
        const SizedBox(height: 8),
        const Text(
          'This information is used only to authenticate your account and '
              'provide access to the application. We do not sell or share '
              'this information with third parties for marketing purposes.',
          style: bodyStyle,
        ),
        const SizedBox(height: 12),
        Text('Survey Responses', style: bodyStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text(
          'If you choose to complete surveys within the app, we collect '
              'the responses you voluntarily provide. These responses help '
              'us improve the app and understand user preferences.',
          style: bodyStyle,
        ),
        const SizedBox(height: 12),
        Text('Feedback', style: bodyStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text(
          'If you submit feedback through the app, we collect the '
              'information you provide so that we can improve Doom Guard and '
              'address user concerns.',
          style: bodyStyle,
        ),

        heading('2. Screen Time Data'),
        const Text(
          'Doom Guard helps users monitor their screen time. Your screen '
              'time information is processed only for providing app '
              'functionality and is not collected, stored, or transmitted to '
              'our servers. We do not maintain a database of your personal '
              'screen usage.',
          style: bodyStyle,
        ),

        heading('3. How We Use Your Information'),
        const Text('We use the information we collect to:', style: bodyStyle),
        bullet('Authenticate users through Google Sign-In'),
        bullet("Improve the application's features and user experience"),
        bullet('Analyze anonymous survey responses'),
        bullet('Review and respond to user feedback'),
        bullet('Maintain the security and reliability of the application'),

        heading('4. Data Security'),
        const Text(
          'We take appropriate technical and organizational measures to '
              'protect your information. Authentication is handled securely '
              "through Google's authentication services. Any information "
              'stored by Doom Guard is protected using industry-standard '
              'security practices to prevent unauthorized access.',
          style: bodyStyle,
        ),

        heading('5. Data Sharing'),
        const Text('We do not:', style: bodyStyle),
        bullet('Sell your personal information'),
        bullet('Rent your personal information'),
        bullet('Share your information with advertisers'),
        const SizedBox(height: 8),
        const Text(
          'We may disclose information only if required by applicable '
              'law or to protect the security and integrity of our services.',
          style: bodyStyle,
        ),

        heading('6. Third-Party Services'),
        const Text('Doom Guard uses trusted third-party services including:', style: bodyStyle),
        bullet('Google Sign-In for secure authentication'),
        bullet('Cloud database services (if applicable) to securely store survey and feedback data'),
        const SizedBox(height: 8),
        const Text(
          'These providers maintain their own privacy policies governing '
              'the information they process.',
          style: bodyStyle,
        ),

        heading('7. Your Choices'),
        const Text('You may:', style: bodyStyle),
        bullet('Choose whether or not to submit surveys'),
        bullet('Choose whether or not to provide feedback'),
        bullet('Stop using the application at any time'),
        bullet("Remove Doom Guard's access to your Google account through your Google Account settings"),

        heading("8. Children's Privacy"),
        const Text(
          'Doom Guard is not intended for children under the age of 13. '
              'We do not knowingly collect personal information from children.',
          style: bodyStyle,
        ),

        heading('9. Changes to This Privacy Policy'),
        const Text(
          'We may update this Privacy Policy from time to time. Any '
              'changes will be reflected by updating the Effective Date. '
              'Continued use of the application after changes become '
              'effective constitutes acceptance of the revised policy.',
          style: bodyStyle,
        ),

        heading('10. Contact Us'),
        const Text(
          'If you have any questions or concerns regarding this Privacy '
              'Policy, please contact us at:',
          style: bodyStyle,
        ),
        const SizedBox(height: 4),
        Text(
          'Email: bijeet.nayek110906@gmail.com',
          style: bodyStyle.copyWith(fontWeight: FontWeight.w600, color: DG.primary),
        ),

        const SizedBox(height: 24),
        Text(
          'By using Doom Guard, you acknowledge that you have read and '
              'understood this Privacy Policy and agree to its terms.',
          style: bodyStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: DG.mutedFg,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}