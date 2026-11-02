import 'package:chatx_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final email = authController.auth.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 72),
              const SizedBox(height: 24),
              Text(
                'Check $email',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'We sent a verification link to your email. Open it, then return here to continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: authController.refreshVerificationStatus,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('I verified my email'),
              ),
              TextButton(
                onPressed: authController.resendVerificationEmail,
                child: const Text('Resend verification email'),
              ),
              TextButton(
                onPressed: authController.logoutUser,
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
