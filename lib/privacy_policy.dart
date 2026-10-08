import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const body = '''
PuzzleMix Privacy Policy

Last updated: 8 October 2026

PuzzleMix is a casual puzzle game developed and published by Mehedi Ahamed.

Data collection
PuzzleMix does not collect, transmit, sell, rent, or share personal information. The current version does not use advertising SDKs, analytics SDKs, account systems, location services, contacts, camera, microphone, or other sensitive device permissions.

Local game data
PuzzleMix stores game progress such as coins, stars, completed levels, tutorial status, and sound preferences locally on your device. This information is used only to provide game functionality and is not sent to the developer.

Audio
The game plays bundled sound effects and background music from local app assets. Audio playback does not require access to your microphone or media library.

Children and families
PuzzleMix is a general-audience puzzle game. The app does not knowingly collect personal data from children or any other users.

Data retention and deletion
Because the current version stores game progress locally and does not maintain developer-controlled user accounts or servers, you can delete the app's locally stored data by clearing the app's storage or uninstalling PuzzleMix.

Security
PuzzleMix is designed to minimize data exposure by keeping game progress on-device and avoiding unnecessary permissions and network-based tracking.

Changes
If PuzzleMix later adds services such as ads, analytics, cloud saves, accounts, or online features, this privacy policy and the Google Play Data safety declaration will be updated before those features are released.

Privacy inquiries
For privacy or support inquiries, use the public project support channel:
github.com/Mehedi13Wp/puzzlemix-mobile/issues
''';

    return Scaffold(
      backgroundColor: const Color(0xFF041F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF073B21),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A3E24),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: .08),
              ),
            ),
            child: const SelectableText(
              body,
              style: TextStyle(
                color: Color(0xFFDDF3E2),
                height: 1.55,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
