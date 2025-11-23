import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_theme.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  final List<String> _testResults = [];
  bool _isTesting = false;

  Future<void> _runTests() async {
    setState(() {
      _isTesting = true;
      _testResults.clear();
    });

    final client = Supabase.instance.client;

    // Test 1: Connection
    _addResult('🔌 Testing Supabase connection...');
    try {
      await client.from('users').select().limit(1);
      _addResult('✅ Database connection successful!');
    } catch (e) {
      _addResult('❌ Database connection failed: $e');
    }

    // Test 2: Tables
    _addResult('\n📋 Checking tables...');
    final tables = ['users', 'livestock', 'diagnoses', 'vet_cases', 'notifications'];
    for (final table in tables) {
      try {
        await client.from(table).select().limit(0);
        _addResult('   ✅ Table "$table" exists');
      } catch (e) {
        _addResult('   ❌ Table "$table": $e');
      }
    }

    // Test 3: Storage
    _addResult('\n🗂️  Checking storage buckets...');
    try {
      final buckets = await client.storage.listBuckets();
      final bucketNames = buckets.map((b) => b.name).toList();
      
      if (bucketNames.contains('livestock_images')) {
        _addResult('   ✅ "livestock_images" bucket exists');
      } else {
        _addResult('   ⚠️  "livestock_images" bucket not found');
      }
      
      if (bucketNames.contains('diagnosis_images')) {
        _addResult('   ✅ "diagnosis_images" bucket exists');
      } else {
        _addResult('   ⚠️  "diagnosis_images" bucket not found');
      }
    } catch (e) {
      _addResult('   ❌ Storage check failed: $e');
    }

    // Test 4: Auth
    _addResult('\n🔐 Checking authentication...');
    try {
      final user = client.auth.currentUser;
      if (user != null) {
        _addResult('   ✅ User authenticated: ${user.email}');
      } else {
        _addResult('   ℹ️  No user authenticated (normal)');
      }
    } catch (e) {
      _addResult('   ❌ Auth check failed: $e');
    }

    _addResult('\n✨ Test completed!');
    setState(() {
      _isTesting = false;
    });
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isTesting ? null : _runTests,
              child: _isTesting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Run Connection Tests'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _testResults.isEmpty
                    ? const Center(
                        child: Text(
                          'Click "Run Connection Tests" to begin',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView(
                        children: _testResults.map((result) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              result,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: result.startsWith('✅')
                                    ? AppTheme.successColor
                                    : result.startsWith('❌')
                                        ? AppTheme.errorColor
                                        : result.startsWith('⚠️')
                                            ? AppTheme.warningColor
                                            : Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

