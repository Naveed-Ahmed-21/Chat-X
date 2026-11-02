import 'package:chatx_app/pages/group/create_group/select_members_screen.dart';
import 'package:chatx_app/main.dart';
import 'package:chatx_app/pages/screens/authentication/auth_screen.dart';
import 'package:chatx_app/pages/screens/authentication/forgot_password_screen.dart';
import 'package:chatx_app/pages/screens/authentication/verification_screen.dart';
import 'package:chatx_app/pages/screens/presentation/contactPage/contact_screen.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/home_screen.dart';
import 'package:chatx_app/pages/screens/presentation/profilePage/user_profile_screen.dart';
import 'package:chatx_app/pages/screens/splashScreen/splash_screen.dart';
import 'package:chatx_app/pages/screens/welcomepage/welcome_sreen.dart';
import 'package:get/get.dart';
import '../pages/screens/presentation/profilePage/profile_screen.dart';


var pagePath = [
  GetPage(
    name: "/authScreen",
    page: () => const AuthScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/forgotPasswordScreen",
    page: () => const ForgotPasswordScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/verificationScreen",
    page: () => const VerificationScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/homeScreen",
    page: () => HomeScreen(),
    transition: Transition.cupertino,
    binding: HomeBinding(),
  ),

  GetPage(
    name: "/profileScreen",
    page: () => ProfileScreen(),
    transition: Transition.cupertino,
  ),


  GetPage(
    name: "/userProfileScreen",
    page: () => UserProfileScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/welcomeScreen",
    page: () => WelcomeScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/splashScreen",
    page: () => SplashScreen(),
    transition: Transition.fade,
  ),
  GetPage(
    name: "/contactScreen",
    page: () => ContactScreen(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/createGroupScreen",
    page: () => const SelectMembersScreen(),
    transition: Transition.cupertino,
  ),
];
