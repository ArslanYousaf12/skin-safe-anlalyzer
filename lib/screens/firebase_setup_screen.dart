import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/firebase_config_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseConfig = Provider.of<FirebaseConfigService>(context);
    final instructions = firebaseConfig.getSetupInstructions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup Required'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text('Skip for now'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: Colors.orange,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Firebase Configuration Missing',
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'Your app is missing the Firebase configuration files needed for cloud features.',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Setup Instructions',
                          style: AppTheme.subheadingStyle.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.content_copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: instructions));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Instructions copied to clipboard'),
                              ),
                            );
                          },
                          tooltip: 'Copy instructions',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                      child: Text(
                        instructions,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Features affected section
            Text(
              'Limited Functionality',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            _buildFeatureItem(
              icon: Icons.history,
              title: 'History Storage',
              description:
                  'Your product analysis history will only be stored locally',
              isAvailable: false,
            ),
            _buildFeatureItem(
              icon: Icons.cloud_sync,
              title: 'Cross-device Sync',
              description: 'Your data won\'t sync across your devices',
              isAvailable: false,
            ),
            _buildFeatureItem(
              icon: Icons.person,
              title: 'User Accounts',
              description: 'User account features are unavailable',
              isAvailable: false,
            ),
            _buildFeatureItem(
              icon: Icons.science,
              title: 'Product Analysis',
              description: 'Local ingredient analysis still works',
              isAvailable: true,
            ),
            _buildFeatureItem(
              icon: Icons.camera_alt,
              title: 'OCR Scanning',
              description: 'Ingredient scanning still works',
              isAvailable: true,
            ),

            const SizedBox(height: AppConstants.largePadding),

            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue with Limited Features'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isAvailable,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAvailable
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isAvailable ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.captionStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
