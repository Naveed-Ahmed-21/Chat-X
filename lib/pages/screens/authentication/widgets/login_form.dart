import 'package:chatx_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  AuthController authController = Get.put(AuthController());
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60,),


        TextField(
          controller: email,
          decoration: InputDecoration(
            labelText: "Email",
            hintText: "Email",
            prefixIcon: Icon(Icons.email_outlined),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            )
          ),
        ),

        SizedBox(height: 30,),

        TextField(
          controller: password,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: "Password",
            hintText: "Password",
              prefixIcon: Icon(Icons.password_outlined),
              fillColor: Theme.of(context).colorScheme.surface,
              suffixIcon: IconButton(
                  onPressed: (){
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                  icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility
                  ),
              ),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
              )
          ),
        ),

        SizedBox(height: 40,),

        Obx(() {
          return authController.isLoading.value
              ? CircularProgressIndicator()
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: (){
                  if(email.text.trim().isEmpty || password.text.isEmpty){
                    Get.snackbar("Error", "Please fill all fields");
                    return;
                  }
                  authController.login(
                      email.text.trim(),
                      password.text
                  );

                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_outlined,
                        color: Color(0xffFFFFFF) ,
                      ),

                      SizedBox(width: 5,),

                      Text(
                        "Login",
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
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
