import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/tensorflow_service.dart';
import '../../domain/entities/diagnosis_result.dart';

class DiagnosisPage extends StatefulWidget {
  final String? imagePath;
  
  const DiagnosisPage({
    super.key,
    this.imagePath,
  });

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  final TensorFlowService _tensorFlowService = TensorFlowService();
  DiagnosisResult? _diagnosisResult;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndAnalyze();
  }

  Future<void> _initializeAndAnalyze() async {
    if (widget.imagePath == null) {
      setState(() {
        _errorMessage = 'No image provided for analysis';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      // Initialize TensorFlow service
      await _tensorFlowService.initialize();
      
      // Analyze the image
      final result = await _tensorFlowService.predictDisease(widget.imagePath!);
      
      setState(() {
        _diagnosisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to analyze image: $e';
        _isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _tensorFlowService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Diagnosis'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isAnalyzing) {
      return _buildAnalyzingView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_diagnosisResult != null) {
      return _buildResultView();
    }

    return const Center(
      child: Text('No data to display'),
    );
  }

  Widget _buildAnalyzingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 4,
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing Image...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we process the image',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          if (widget.imagePath != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Analysis Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeAndAnalyze,
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_diagnosisResult == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          if (widget.imagePath != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Diagnosis result card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getSeverityIcon(_diagnosisResult!.severity),
                        color: _getSeverityColor(_diagnosisResult!.severity),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _diagnosisResult!.diseaseName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Confidence: ${(_diagnosisResult!.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Severity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(_diagnosisResult!.severity)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getSeverityColor(_diagnosisResult!.severity),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Severity: ${_diagnosisResult!.severity}',
                      style: TextStyle(
                        color: _getSeverityColor(_diagnosisResult!.severity),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Symptoms
          _buildInfoCard(
            'Symptoms',
            Icons.medical_services,
            _diagnosisResult!.symptoms,
          ),
          const SizedBox(height: 16),

          // Treatment
          _buildInfoCard(
            'Treatment',
            Icons.healing,
            _diagnosisResult!.treatment,
          ),
          const SizedBox(height: 16),

          // Prevention
          _buildInfoCard(
            'Prevention',
            Icons.shield,
            _diagnosisResult!.prevention,
          ),
          const SizedBox(height: 16),

          // Additional info
          if (_diagnosisResult!.contagious)
            _buildInfoCard(
              'Contagious',
              Icons.warning,
              'This disease is contagious. Isolate affected animals immediately.',
            ),
          
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Save diagnosis to database
                    _saveDiagnosis();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Diagnosis'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home/camera'),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('New Scan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.dangerous;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _saveDiagnosis() {
    // TODO: Implement saving diagnosis to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnosis saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
