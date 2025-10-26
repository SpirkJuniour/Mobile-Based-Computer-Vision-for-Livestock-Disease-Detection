import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_colors.dart';

/// Livestock Management Screen - Beautiful card-based UI
class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Livestock',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              context.pushNamed('search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', 12),
                _buildFilterChip('Healthy', 10),
                _buildFilterChip('At Risk', 2),
                _buildFilterChip('Cattle', 8),
                _buildFilterChip('Goats', 4),
              ],
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                    child: _buildStatCard('Total', '12', AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        'Healthy', '10', AppColors.successGreen)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        'At Risk', '2', AppColors.warningOrange)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Livestock List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 12,
              itemBuilder: (context, index) {
                return _buildLivestockCard(context, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddLivestockDialog();
        },
        icon: const Icon(Icons.add),
        label: Text('Add Animal',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Livestock tab
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('home');
              break;
            case 1:
              context.goNamed('diagnosis-history');
              break;
            case 2:
              // Already on livestock
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

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selectedColor: AppColors.primary,
        checkmarkColor: AppColors.textWhite,
        labelStyle: GoogleFonts.inter(
          color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivestockCard(BuildContext context, int index) {
    final isHealthy = index < 10;
    final animalTypes = ['Cattle', 'Goat', 'Cattle', 'Cattle', 'Goat'];
    final animalType = animalTypes[index % animalTypes.length];
    final breeds = ['Friesian', 'Ayrshire', 'Boer', 'Sahiwal', 'Toggenburg'];
    final breed = breeds[index % breeds.length];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.pushNamed('livestock-profile',
              pathParameters: {'id': '${100 + index}'});
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Animal Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? AppColors.primaryLight
                      : AppColors.warningOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  animalType == 'Cattle' ? Icons.pets : Icons.grass,
                  color:
                      isHealthy ? AppColors.primary : AppColors.warningOrange,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$animalType #${100 + index}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isHealthy
                                    ? AppColors.successGreen
                                    : AppColors.warningOrange)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isHealthy ? 'Healthy' : 'At Risk',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isHealthy
                                  ? AppColors.successGreen
                                  : AppColors.warningOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$breed • ${2 + (index % 3)} years old',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          'Last checked: ${3 + index} days ago',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Animals',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.pets, color: AppColors.primary),
                title: const Text('All Animals'),
                trailing:
                    Radio(value: true, groupValue: true, onChanged: (_) {}),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle,
                    color: AppColors.successGreen),
                title: const Text('Healthy Only'),
                trailing:
                    Radio(value: false, groupValue: true, onChanged: (_) {}),
              ),
              ListTile(
                leading:
                    const Icon(Icons.warning, color: AppColors.warningOrange),
                title: const Text('At Risk Only'),
                trailing:
                    Radio(value: false, groupValue: true, onChanged: (_) {}),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddLivestockDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Animal',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Tag/ID Number',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Animal Type',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: const [
                  DropdownMenuItem(value: 'cattle', child: Text('Cattle')),
                  DropdownMenuItem(value: 'goat', child: Text('Goat')),
                  DropdownMenuItem(value: 'sheep', child: Text('Sheep')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Animal added successfully!')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
