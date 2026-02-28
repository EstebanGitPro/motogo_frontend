import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/legal_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen Terms & Conditions viewer.
///
/// Displays all T&C sections using [ExpansionTile] for easy navigation.
/// Contains a footer link to MinTIC and a "He leído y acepto" button.
class TermsAndConditionsPage extends StatelessWidget {
  final Color primaryColor;

  const TermsAndConditionsPage({super.key, required this.primaryColor});

  Future<void> _openMinticLink() async {
    final uri = Uri.parse(LegalConstants.minticTermsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(LegalConstants.termsPageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDocumentHeader(context),
                  const SizedBox(height: 16),
                  ...LegalConstants.tcSections.map(_buildSection),
                  const SizedBox(height: 24),
                  _buildSensitiveDataDeclaration(context),
                  const SizedBox(height: 16),
                  _buildMinticLink(context),
                  const SizedBox(height: 16),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
          _buildAcceptButton(context),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.gavel_rounded, color: primaryColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'TÉRMINOS Y CONDICIONES DE USO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'APLICACIÓN ${LegalConstants.appName.toUpperCase()}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LegalConstants.platformDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Versión ${LegalConstants.documentVersion}  •  '
            '${LegalConstants.lastUpdated}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, String> section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        key: Key('tc_section_${section['title']}'),
        title: Text(
          section['title']!,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: primaryColor,
        collapsedIconColor: Colors.grey[400],
        children: [
          Text(
            section['content']!,
            style: const TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitiveDataDeclaration(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                LegalConstants.sensitiveDataDeclaration,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            LegalConstants.sensitiveDataConsent,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.amber[900],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinticLink(BuildContext context) {
    return InkWell(
      onTap: _openMinticLink,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.open_in_new, color: Colors.blue[700], size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                LegalConstants.viewPrivacyPolicy,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '${LegalConstants.appName}  •  ${LegalConstants.appSlogan}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            '${LegalConstants.contactPrefix}${LegalConstants.contactEmail}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            key: const Key('accept_terms_button'),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text(
              LegalConstants.readAndAccept,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ),
    );
  }
}
