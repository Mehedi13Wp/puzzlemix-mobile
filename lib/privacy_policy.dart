import 'package:flutter/material.dart';
import 'ads/ad_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const body = '''
PuzzleMix Privacy Policy

Last updated: 13 November 2026

PuzzleMix is a casual puzzle game developed and published by Mehedi Ahamed.

Data collection
PuzzleMix uses Google AdMob to display ads. Before requesting production ads, the app checks privacy requirements with Google's User Messaging Platform and presents a consent message when required. Google Mobile Ads may collect and share IP address (used to estimate approximate location), device and account identifiers such as advertising ID and app set ID, ad/app interactions, and diagnostic information for advertising, analytics and fraud prevention. Google encrypts SDK data in transit. See https://policies.google.com/privacy and https://developers.google.com/admob/android/privacy/play-data-disclosure. Coins, stars, unlocked levels and saved game progress remain on your device and are not sent to the developer.

Local game data
PuzzleMix stores game progress such as coins, stars, completed levels, tutorial status, and sound preferences locally on your device. This information is used only to provide game functionality and is not sent to the developer.

Audio
The game plays bundled sound effects and background music from local app assets. Audio playback does not require access to your microphone or media library.

Children and families
PuzzleMix is intended for a non-child-directed audience. The developer has configured its intended audience in Google Play Console.

Data retention and deletion
Because the current version stores game progress locally and does not maintain developer-controlled user accounts or servers, you can delete the app's locally stored data by clearing the app's storage or uninstalling PuzzleMix.

Security
PuzzleMix keeps game progress on-device. Google handles advertising SDK data under its own privacy policy.

Changes
Privacy choices can be changed through Ad privacy choices on the in-app Privacy Policy screen when this option is required. Android advertising-ID controls are available in device settings. This policy may be updated when app functionality or data practices change.

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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListenableBuilder(
                  listenable: AdService.instance,
                  builder: (context, _) {
                    final ads = AdService.instance;
                    if (!ads.privacyOptionsRequired)
                      return const SizedBox.shrink();
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.privacy_tip_outlined),
                          label: const Text('Ad privacy choices'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white),
                          onPressed: ads.privacyOptionsBusy
                              ? null
                              : () async {
                                  final success =
                                      await ads.showPrivacyOptions();
                                  if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Privacy choices are temporarily unavailable. Please try again.')));
                                  }
                                },
                        ));
                  }),
              const SelectableText(body,
                  style: TextStyle(
                      color: Color(0xFFDDF3E2), height: 1.55, fontSize: 14)),
            ]),
          ),
        ),
      ),
    );
  }
}
