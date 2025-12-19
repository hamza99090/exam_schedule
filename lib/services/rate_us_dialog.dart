import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateUsDialog extends StatelessWidget {
  const RateUsDialog({super.key});

  static const String _lastPromptDateKey = 'last_rate_prompt_date';
  static const String _dismissedPromptKey = 'dismissed_rate_prompt';

  Future<void> _onRateNow(BuildContext context) async {
    Navigator.pop(context);

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final review = InAppReview.instance;

    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await review.openStoreListing();
    }

    // Save user action
    await prefs.setBool(_dismissedPromptKey, true);
    await prefs.setString(_lastPromptDateKey, now.toIso8601String());
  }

  Future<void> _onMaybeLater(BuildContext context) async {
    Navigator.pop(context);

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await prefs.setBool(_dismissedPromptKey, true);
    await prefs.setString(_lastPromptDateKey, now.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          SizedBox(width: 8),
          Text('Rate Date Sheet Generator', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: const Text(
        'Would you like to rate the app?',
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          onPressed: () => _onMaybeLater(context),
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _onRateNow(context),
          child: const Text('Rate Now'),
        ),
      ],
    );
  }
}
