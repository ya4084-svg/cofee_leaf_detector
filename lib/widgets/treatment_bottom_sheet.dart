import 'package:flutter/material.dart';
import '../models/disease_data.dart';
import '../services/language_service.dart';

class TreatmentBottomSheet extends StatelessWidget {
  final DiseaseInfo info;
  const TreatmentBottomSheet({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final name = info.getName(lang.currentLanguage);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E5E3A),
                          ),
                        ),
                        Text(info.key, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              _card(lang.t('symptoms'), info.getSymptoms(lang.currentLanguage), Icons.visibility_outlined, Colors.blue.shade800),
              _card(lang.t('causes'), info.getCauses(lang.currentLanguage), Icons.help_outline_rounded, Colors.purple.shade800),
              _card(lang.t('organic_care'), info.getOrganicCare(lang.currentLanguage), Icons.eco_rounded, Colors.green.shade800),
              _card(lang.t('chemical_treatment'), info.getChemicalTreatment(lang.currentLanguage), Icons.science_rounded, Colors.deepOrange.shade800),
              _card(lang.t('prevention'), info.getPrevention(lang.currentLanguage), Icons.shield_outlined, Colors.teal.shade800),
            ],
          ),
        );
      },
    );
  }

  Widget _card(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF2D3748))),
        ],
      ),
    );
  }
}
