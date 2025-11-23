import 'package:flutter/material.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF00A86B),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'User Agreement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Terms of Service',
                      'By using BinSync, you agree to comply with and be bound by the following terms and conditions of use. Please review these terms carefully.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '1. Acceptance of Terms',
                      'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '2. Use License',
                      'Permission is granted to use BinSync for personal, non-commercial purposes. This license shall automatically terminate if you violate any of these restrictions.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '3. User Responsibilities',
                      'Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account. You agree to provide accurate and complete information when using the application.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '4. Data Collection',
                      'BinSync collects location data to provide garbage tracking services. This data is used solely for the purpose of optimizing waste collection routes and reporting trash locations. We do not share your personal information with third parties.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '5. Location Services',
                      'The application requires access to your device\'s location services to function properly. You can revoke this permission at any time through your device settings, though this may limit functionality.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '6. Reporting and Content',
                      'Users agree to report accurate information regarding trash locations and issues. False or misleading reports may result in account suspension or termination.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '7. Privacy',
                      'Your privacy is important to us. We collect only necessary information to provide our services. User data is stored securely and is not sold to third parties.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '8. Disclaimer',
                      'BinSync is provided "as is" without warranty of any kind. We do not guarantee the accuracy, completeness, or reliability of any information provided through the application.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '9. Limitation of Liability',
                      'BinSync and its developers shall not be liable for any damages arising from the use or inability to use this application.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '10. Changes to Terms',
                      'We reserve the right to modify these terms at any time. Continued use of the application after changes constitutes acceptance of the modified terms.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '11. Contact',
                      'For questions about these terms, please contact us through the bug report feature in the application.',
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Last Updated: November 24, 2025',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'I Understand',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A86B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
