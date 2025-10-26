import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_colors.dart';

/// Diagnosis History Screen - Beautiful timeline-based UI
class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Diagnosis History',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting diagnosis history...')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Diseased'),
            Tab(text: 'Healthy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiagnosisList('all'),
          _buildDiagnosisList('diseased'),
          _buildDiagnosisList('healthy'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // History tab
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('home');
              break;
            case 1:
              // Already on history
              break;
            case 2:
              context.goNamed('livestock');
              break;
            case 3:
              context.goNamed('settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Livestock'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDiagnosisList(String filter) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filter == 'all' ? 15 : (filter == 'diseased' ? 5 : 10),
      itemBuilder: (context, index) {
        return _buildDiagnosisCard(context, index, filter);
      },
    );
  }

  Widget _buildDiagnosisCard(BuildContext context, int index, String filter) {
    final diseases = [
      'Healthy - No Disease Detected',
      'Lumpy Skin Disease',
      'East Coast Fever (ECF)',
      'Healthy - No Disease Detected',
      'Mastitis',
      'Healthy - No Disease Detected',
      'Tick Infestation',
      'Healthy - No Disease Detected',
      'Healthy - No Disease Detected',
      'Foot and Mouth Disease (FMD)',
    ];

    final disease = diseases[index % diseases.length];
    final isHealthy = disease.contains('Healthy');
    final confidence = 85.0 + (index % 10);
    final daysAgo = index + 1;

    // Skip based on filter
    if (filter == 'diseased' && isHealthy) return const SizedBox.shrink();
    if (filter == 'healthy' && !isHealthy) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to diagnosis detail
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tap to view full diagnosis details')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isHealthy
                              ? AppColors.successGreen
                              : AppColors.alertRed)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isHealthy
                          ? Icons.check_circle
                          : Icons.warning_amber_rounded,
                      color: isHealthy
                          ? AppColors.successGreen
                          : AppColors.alertRed,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Disease Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          disease,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.analytics,
                                size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              '${confidence.toStringAsFixed(1)}% confidence',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu
                  PopupMenuButton(
                    icon:
                        const Icon(Icons.more_vert, color: AppColors.textLight),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 12),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 12),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                size: 20, color: AppColors.alertRed),
                            SizedBox(width: 12),
                            Text('Delete',
                                style: TextStyle(color: AppColors.alertRed)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Additional Info Row
              Row(
                children: [
                  const Icon(Icons.pets, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    'Cow #${100 + (index % 12)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    '$daysAgo ${daysAgo == 1 ? "day" : "days"} ago',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Progress Bar (Confidence)
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: confidence / 100,
                        backgroundColor: AppColors.backgroundLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHealthy
                              ? AppColors.successGreen
                              : AppColors.alertRed,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
