import 'package:flutter/material.dart';

class OverlayReminder extends StatelessWidget {
  const OverlayReminder({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => const OverlayReminder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1927), // surface
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x33FF5C7A)), // danger with alpha
      ),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5C7A)),
          SizedBox(width: 8),
          Flexible(
            child: Text('Usage Limit Reached',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      content: const Text(
        'You have exceeded 80% of your daily limit. It is time to take a break.',
        style: TextStyle(color: Color(0xB3FFFFFF)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss', style: TextStyle(color: Color(0x8AFFFFFF))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5C7A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            // "Take a Break" logic could be added here
            Navigator.of(context).pop();
          },
          child: const Text('Take a Break'),
        ),
      ],
    );
  }
}
