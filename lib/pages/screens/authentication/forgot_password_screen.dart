import 'package:chatx_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final authController = Get.find<AuthController>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.lock_reset_outlined, size: 72),
            const SizedBox(height: 24),
            Text(
              'Reset your password',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your account email and Firebase will send a secure reset link.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: () {
                        final email = emailController.text.trim();
                        if (email.isEmpty) {
                          Get.snackbar(
                            'Email required',
                            'Enter your account email.',
                          );
                          return;
                        }
                        authController.sendPasswordResetEmail(email);
                      },
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Send reset link'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
