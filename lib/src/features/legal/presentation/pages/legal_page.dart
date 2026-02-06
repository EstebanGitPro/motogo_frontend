import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/legal_constants.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(LegalConstants.pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: LegalConstants.sectionAbout,
              body: LegalConstants.aboutBody,
            ),
            _buildSection(
              title: LegalConstants.sectionTermsAndConditions,
              body: LegalConstants.termsBody,
            ),
            _buildSection(
              title: LegalConstants.sectionPrivacyPolicy,
              body: LegalConstants.privacyBody,
            ),
            _buildSection(
              title: LegalConstants.sectionDataTreatment,
              body: LegalConstants.dataBody,
            ),
            _buildSection(
              title: LegalConstants.sectionSecurity,
              body: LegalConstants.securityBody,
            ),
            _buildSection(
              title: LegalConstants.sectionLicenses,
              body: LegalConstants.licensesBody,
            ),
            const SizedBox(height: 16),
            Text(LegalConstants.lastUpdated, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
