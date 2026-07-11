import 'package:chatx_app/pages/screens/authentication/auth_screen.dart';
import 'package:chatx_app/pages/screens/presentation/contactPage/contact_screen.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/home_screen.dart';
import 'package:chatx_app/pages/screens/presentation/profilePage/user_profile_screen.dart';
import 'package:chatx_app/pages/screens/presentation/profilePage/updateProfile_screen.dart';
import 'package:chatx_app/pages/screens/splashScreen/splash_screen.dart';
import 'package:chatx_app/pages/screens/welcomepage/welcome_sreen.dart';
import 'package:get/get.dart';

import '../pages/screens/presentation/profilePage/profile_screen.dart';
import '../widgets/home_bindings.dart';

var pagePath = [
  GetPage(
    name: "/authScreen",
    page: () => AuthScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/homeScreen",
    page: () => HomeScreen(),
    transition: Transition.rightToLeft,
    binding: HomeBinding(),
  ),

  // GetPage(
  //     name: "/chatScreen",
  //     page: () => ChatScreen(),
  //     transition: Transition.rightToLeft
  // ),

  GetPage(
    name: "/profileScreen",
    page: () => ProfileScreen(),
    transition: Transition.rightToLeft,
  ),

  // GetPage(
  //     name: "/updateProfileScreen",
  //     page: () => UpdateProfileScreen(),
  //     transition: Transition.rightToLeft
  // ),

  GetPage(
    name: "/userProfileScreen",
    page: () => UserProfileScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/welcomeScreen",
    page: () => WelcomeScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/splashScreen",
    page: () => SplashScreen(),
    transition: Transition.rightToLeft,
  ),
  GetPage(
    name: "/contactScreen",
    page: () => ContactScreen(),
    transition: Transition.rightToLeft,
  ),
];
