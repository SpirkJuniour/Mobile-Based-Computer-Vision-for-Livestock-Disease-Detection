import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _diagnoses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'date';

  final List<String> _filterOptions = ['All', 'Critical', 'High', 'Medium', 'Low', 'Healthy'];
  final List<String> _sortOptions = ['date', 'confidence', 'disease'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDiagnoses();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _loadDiagnoses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await DatabaseHelper.database;
      final List<Map<String, dynamic>> results = await db.query(
        'diagnoses',
        orderBy: 'diagnosisDate DESC',
      );

      setState(() {
        _diagnoses = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load diagnosis history');
    }
  }

  List<Map<String, dynamic>> get _filteredDiagnoses {
    List<Map<String, dynamic>> filtered = List.from(_diagnoses);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((diagnosis) {
        final diseaseName = diagnosis['diagnosisResult'] ?? '';
        return diseaseName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply severity filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((diagnosis) {
        final result = diagnosis['diagnosisResult'] ?? '';
        return result.toLowerCase().contains(_selectedFilter.toLowerCase());
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'confidence':
          return (b['confidence'] ?? 0.0).compareTo(a['confidence'] ?? 0.0);
        case 'disease':
          final aName = a['diagnosisResult'] ?? '';
          final bName = b['diagnosisResult'] ?? '';
          return aName.compareTo(bName);
        case 'date':
        default:
          return (b['diagnosisDate'] ?? 0).compareTo(a['diagnosisDate'] ?? 0);
      }
    });

    return filtered;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Diagnosis History'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textOnPrimary,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Search and filter bar
                  _buildSearchAndFilterBar(),
                  
                  // Content
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingView()
                        : _diagnoses.isEmpty
                            ? _buildEmptyView()
                            : _buildDiagnosesList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search diagnoses...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? filter : 'All';
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading diagnosis history...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Diagnosis History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by capturing an image to diagnose livestock diseases',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home/camera'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Start Diagnosis'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosesList() {
    final filteredDiagnoses = _filteredDiagnoses;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDiagnoses.length,
      itemBuilder: (context, index) {
        final diagnosis = filteredDiagnoses[index];
        return _buildDiagnosisCard(diagnosis);
      },
    );
  }

  Widget _buildDiagnosisCard(Map<String, dynamic> diagnosis) {
    final diagnosisDate = DateTime.fromMillisecondsSinceEpoch(
      diagnosis['diagnosisDate'] ?? 0,
    );
    final diseaseName = diagnosis['diagnosisResult'] ?? 'Unknown';
    final confidence = diagnosis['confidence'] ?? 0.0;
    final imagePath = diagnosis['imagePath'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDiagnosisDetails(diagnosis),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagePath.isNotEmpty
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image,
                              color: AppTheme.textSecondary,
                            );
                          },
                        )
                      : const Icon(
                          Icons.image,
                          color: AppTheme.textSecondary,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Diagnosis info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(diagnosisDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(diseaseName).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getSeverityColor(diseaseName),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getSeverityLabel(diseaseName),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getSeverityColor(diseaseName),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDiagnosisDetails(Map<String, dynamic> diagnosis) {
    final diagnosisDate = DateTime.fromMillisecondsSinceEpoch(
      diagnosis['diagnosisDate'] ?? 0,
    );
    final diseaseName = diagnosis['diagnosisResult'] ?? 'Unknown';
    final confidence = diagnosis['confidence'] ?? 0.0;
    final imagePath = diagnosis['imagePath'] ?? '';
    final notes = diagnosis['notes'] ?? '';
    final veterinarianNotes = diagnosis['veterinarianNotes'] ?? '';
    final treatmentPrescribed = diagnosis['treatmentPrescribed'] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: AppTheme.textOnPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Diagnosis Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (imagePath.isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: AppTheme.textSecondary,
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // Disease info
                      _buildDetailRow('Disease', diseaseName),
                      _buildDetailRow('Confidence', '${(confidence * 100).toStringAsFixed(1)}%'),
                      _buildDetailRow('Date', _formatDate(diagnosisDate)),
                      
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('Notes', notes),
                      ],
                      
                      if (veterinarianNotes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('Veterinarian Notes', veterinarianNotes),
                      ],
                      
                      if (treatmentPrescribed.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('Treatment Prescribed', treatmentPrescribed),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort & Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sort options
            const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._sortOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option.toUpperCase()),
                value: option,
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getSeverityColor(String diseaseName) {
    final name = diseaseName.toLowerCase();
    if (name.contains('critical') || name.contains('anthrax') || name.contains('blackleg')) {
      return AppTheme.errorColor;
    } else if (name.contains('high') || name.contains('foot and mouth') || name.contains('lumpy skin')) {
      return AppTheme.warningColor;
    } else if (name.contains('medium') || name.contains('mastitis') || name.contains('pneumonia')) {
      return AppTheme.infoColor;
    } else if (name.contains('low') || name.contains('mange') || name.contains('ringworm')) {
      return AppTheme.successColor;
    } else if (name.contains('healthy')) {
      return AppTheme.successColor;
    } else {
      return AppTheme.textSecondary;
    }
  }

  String _getSeverityLabel(String diseaseName) {
    final name = diseaseName.toLowerCase();
    if (name.contains('critical') || name.contains('anthrax') || name.contains('blackleg')) {
      return 'Critical';
    } else if (name.contains('high') || name.contains('foot and mouth') || name.contains('lumpy skin')) {
      return 'High';
    } else if (name.contains('medium') || name.contains('mastitis') || name.contains('pneumonia')) {
      return 'Medium';
    } else if (name.contains('low') || name.contains('mange') || name.contains('ringworm')) {
      return 'Low';
    } else if (name.contains('healthy')) {
      return 'Healthy';
    } else {
      return 'Unknown';
    }
  }
}
