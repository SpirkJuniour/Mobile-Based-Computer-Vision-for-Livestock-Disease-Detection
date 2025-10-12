import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_colors.dart';

/// Health Tips Screen - Beautiful informative cards
class HealthTipsScreen extends StatelessWidget {
  const HealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Livestock Health Tips',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            icon: Icons.vaccines,
            title: 'Regular Vaccination',
            description:
                'Keep your livestock protected with timely vaccinations',
            tips: [
              'Vaccinate against Lumpy Skin Disease every 6 months',
              'Annual ECF vaccination for cattle in endemic areas',
              'FMD vaccination twice yearly',
              'Keep vaccination records up to date',
            ],
            color: AppColors.successGreen,
          ),
          _buildTipCard(
            icon: Icons.water_drop,
            title: 'Proper Hygiene',
            description: 'Maintain clean environment to prevent disease spread',
            tips: [
              'Clean water troughs daily',
              'Disinfect equipment regularly',
              'Remove manure from living areas',
              'Provide adequate ventilation',
            ],
            color: AppColors.info,
          ),
          _buildTipCard(
            icon: Icons.restaurant,
            title: 'Balanced Nutrition',
            description: 'Healthy diet strengthens immune system',
            tips: [
              'Provide mineral supplements',
              'Ensure access to quality pasture or fodder',
              'Add protein supplements for lactating animals',
              'Monitor body condition score regularly',
            ],
            color: AppColors.warningOrange,
          ),
          _buildTipCard(
            icon: Icons.bug_report,
            title: 'Parasite Control',
            description: 'Regular deworming and tick control',
            tips: [
              'Dip or spray for ticks weekly',
              'Deworm every 3 months',
              'Rotate pastures to break parasite cycle',
              'Inspect animals daily for external parasites',
            ],
            color: AppColors.alertRed,
          ),
          _buildTipCard(
            icon: Icons.visibility,
            title: 'Early Detection',
            description: 'Monitor livestock for early signs of disease',
            tips: [
              'Check for changes in behavior daily',
              'Monitor appetite and water intake',
              'Look for skin lesions or abnormalities',
              'Use MifugoCare app for quick diagnosis',
            ],
            color: AppColors.primary,
          ),
          _buildTipCard(
            icon: Icons.group_add,
            title: 'Quarantine New Animals',
            description: 'Prevent disease introduction to your herd',
            tips: [
              'Isolate new animals for 14-21 days',
              'Test for common diseases before mixing',
              'Monitor closely for symptoms',
              'Vaccinate before introducing to main herd',
            ],
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> tips,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.textWhite, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tips List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
