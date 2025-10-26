import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_colors.dart';
import '../../core/services/auth_service.dart';

/// Password Reset Screen
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.sendPasswordResetEmail(_emailController.text.trim());
      
      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset,
            size: 80,
            color: AppColors.primary,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textWhite,
                    ),
                  )
                : const Text('Send Reset Link'),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.mark_email_read,
          size: 100,
          color: AppColors.success,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Email Sent!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.success,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'We\'ve sent password reset instructions to:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _emailController.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        ElevatedButton(
          onPressed: () {
            context.goNamed('login');
          },
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}

