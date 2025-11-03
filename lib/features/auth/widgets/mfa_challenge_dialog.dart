import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/services/mfa_service.dart';

/// Dialog for MFA challenge during login
class MFAChallengeDialog extends StatefulWidget {
  final String factorId;

  const MFAChallengeDialog({
    super.key,
    required this.factorId,
  });

  @override
  State<MFAChallengeDialog> createState() => _MFAChallengeDialogState();
}

class _MFAChallengeDialogState extends State<MFAChallengeDialog> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _challengeId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _createChallenge();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createChallenge() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final challengeId = await MFAService.instance.createChallenge(
        factorId: widget.factorId,
      );

      setState(() {
        _challengeId = challengeId;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (_challengeId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await MFAService.instance.verifyChallenge(
        factorId: widget.factorId,
        challengeId: _challengeId!,
        code: _codeController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _codeController.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing during login
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(child: Text('Two-Factor Authentication')),
          ],
        ),
        content:
            _challengeId == null ? _buildLoadingView() : _buildChallengeView(),
        actions: _challengeId == null
            ? null
            : [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textWhite,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Preparing authentication challenge...'),
      ],
    );
  }

  Widget _buildChallengeView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Text(
            'Enter the 6-digit code from your authenticator app to continue.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 24),

          // Code input
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            autofocus: true,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Verification Code',
              prefixIcon: Icon(Icons.pin),
              counterText: '',
              hintText: '000000',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the verification code';
              }
              if (value.length != 6) {
                return 'Code must be 6 digits';
              }
              return null;
            },
            onFieldSubmitted: (_) => _verifyCode(),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Help text
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Open your authenticator app and enter the current 6-digit code for Mifugo Care.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
