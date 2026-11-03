import 'package:chatx_app/pages/screens/authentication/widgets/login_form.dart';
import 'package:chatx_app/pages/screens/authentication/widgets/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  RxBool isLogin = true.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo/app_logo.png',
                            width: 150,
                            height: 150,
                          ),
                        ]
                    ),
                    Text(
                      "Chat X",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: const Color(0xffc5bdbb)),
                    ),
              
                    const SizedBox(height: 30,),
              
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Obx(() => Row(
                                  children: [
                                    // Login
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          isLogin.value = true;
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              "Login",
                                              style: isLogin.value
                                                  ? Theme.of(context).textTheme.bodyLarge
                                                  : Theme.of(context).textTheme.labelLarge,
                                            ),
                                            const SizedBox(height: 5),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              width: isLogin.value ? 80 : 0,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),

                                    // SignUp
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          isLogin.value = false;
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              "SignUp",
                                              style: isLogin.value
                                                  ? Theme.of(context).textTheme.labelLarge
                                                  : Theme.of(context).textTheme.bodyLarge,
                                            ),
                                            const SizedBox(height: 5),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              width: isLogin.value ? 0 : 80,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )),

                                Obx(
                                        () => isLogin.value ? LoginForm() : SignupForm(),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                )
              ),
            ),
          )
      ),
    );
  }
}
