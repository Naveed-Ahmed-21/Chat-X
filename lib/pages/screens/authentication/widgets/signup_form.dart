import 'package:chatx_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();
  AuthController authController = Get.put(AuthController());
  bool obscurePass = true;
  bool obscureRePass = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),

        TextField(
          controller: name,
          decoration: InputDecoration(
            labelText: "Name",
            hintText: "Enter Name",
            prefixIcon: const Icon(Icons.person),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: email,
          decoration: InputDecoration(
            labelText: "Email",
            hintText: "Email",
            prefixIcon: const Icon(Icons.email_outlined),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: password,
          obscureText: obscurePass,
          decoration: InputDecoration(
            labelText: "Password",
            hintText: "Password",
            prefixIcon: const Icon(Icons.password_outlined),
            fillColor: Theme.of(context).colorScheme.surface,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscurePass = !obscurePass;
                });
              },
              icon: Icon(
                obscurePass ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: rePassword,
          obscureText: obscureRePass,
          decoration: InputDecoration(
            labelText: "Re-Password",
            hintText: "Re-Password",
            prefixIcon: const Icon(Icons.password_outlined),
            fillColor: Theme.of(context).colorScheme.surface,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureRePass = !obscureRePass;
                });
              },
              icon: Icon(obscurePass ? Icons.visibility_off : Icons.visibility),
            ),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        const SizedBox(height: 30),

        Obx((){
          return authController.isLoading.value
              ? CircularProgressIndicator()
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  if (name.text.trim().isEmpty ||
                      email.text.trim().isEmpty ||
                      password.text.isEmpty ||
                      rePassword.text.isEmpty) {
                    Get.snackbar("Error", "Please fill all fields");
                    return;
                  }

                  if (password.text != rePassword.text) {
                    Get.snackbar("Error", "Passwords do not match");
                    return;
                  }

                  authController.createUser(
                    name.text.trim(),
                    email.text.trim(),
                    password.text.trim(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.login_outlined,
                        color: Color(0xffFFFFFF),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        "SignUp",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        })
      ],
    );
  }
}
