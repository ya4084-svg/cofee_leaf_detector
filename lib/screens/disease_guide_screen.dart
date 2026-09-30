import 'package:flutter/material.dart';
import '../models/disease_data.dart';
import '../services/language_service.dart';

class DiseaseGuideScreen extends StatelessWidget {
  const DiseaseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final list = CoffeeDiseaseDatabase.diseases.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final info = list[index];
        final name = info.getName(lang.currentLanguage);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
          child: ExpansionTile(
            leading: Icon(
              info.key == 'Healthy' ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: info.key == 'Healthy' ? Colors.green.shade700 : Colors.amber.shade800,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(info.key, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(lang.t('symptoms'), Icons.visibility_outlined),
                    Text(info.getSymptoms(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),

                    _header(lang.t('causes'), Icons.info_outline),
                    Text(info.getCauses(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),

                    _header(lang.t('organic_care'), Icons.eco_outlined),
                    Text(info.getOrganicCare(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 10),

                    _header(lang.t('chemical_treatment'), Icons.science_outlined),
                    Text(info.getChemicalTreatment(lang.currentLanguage), style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF1E5E3A)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E5E3A)),
          ),
        ],
      ),
    );
  }
}
