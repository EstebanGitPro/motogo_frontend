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
            const SizedBox(height: 8),
            const Text(
              LegalConstants.sectionTermsAndConditions,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...LegalConstants.tcSections.map(
              (section) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ExpansionTile(
                  title: Text(
                    section['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Text(
                      section['content']!,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
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
