import 'package:chatx_app/config/imgepaths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child:Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.appLogo,
                        width: 150,
                        height: 150,
                      ),
                    ]
                  ),
                Text(
                    "Chat X",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Color(0xffc5bdbb)),
                ),

                SizedBox(height: 70,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.male,
                      height: 100,
                      width: 100,
                    ),

                    SizedBox(width: 10,),

                    Icon(
                      Icons.connect_without_contact_outlined,
                      size: 35,
                    ),

                    SizedBox(width:10,),

                    Image.asset(
                      AppImages.female,
                      height: 100,
                      width: 100,
                    )
                  ],
                ),

                SizedBox(height: 40,),

                Text(
                  "Welcome to Chat X",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Connect ",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Color(0xff0057FF)),
                    ),
                    Text(
                      ".",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.amberAccent),
                    ),
                    Text(
                      " Chat ",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Color(0xffc5bdbb)),
                    ),
                    Text(
                      ".",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.amberAccent),
                    ),
                    Text(
                      " Anytime ",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.deepPurpleAccent),
                    ),
                    Text(
                      ".",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.amberAccent),
                    ),
                  ],
                ),

                SizedBox(height: 30,),

                Text(
                  "Connect instantly with friends and family through secure, fast, and real-time messaging.",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 60,),

                SlideAction(
                  onSubmit: (){
                    Get.offAllNamed("/authScreen");
                    return null;
                  },
                  innerColor: Color(0xffc5bdbb),
                  outerColor: Theme.of(context).colorScheme.primaryContainer,
                  text: "Slide to Start",
                  textStyle:Theme.of(context).textTheme.headlineSmall ,
                  sliderButtonIcon: Icon(
                    Icons.connect_without_contact_outlined,
                    color: Colors.black87,
                  ),
                  sliderRotate: false,
                  submittedIcon: Icon(
                    Icons.connect_without_contact_outlined,
                    color:Color(0xffc5bdbb) ,
                  ),
                  animationDuration: Duration(seconds: 1),
                ),
              ],
            ),
          )
      ),
    );
  }
}
