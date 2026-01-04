// .../register/presentation/widgets/representative_info_box.dart
import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';

class RepresentativeInfoBox extends StatelessWidget {
  const RepresentativeInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange[700],
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Text(
              getTranslateText(context: context, key: 'representative_info'),
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
