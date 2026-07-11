import 'package:chatx_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
class DBController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;
  RxList<UserModel> userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getUserLists();
  }

  Future<void> getUserLists() async {
    isLoading.value = true;
    try{
      await db
          .collection("users")
          .get()
          .then(
            (value) => {
          userList.value = value.docs
              .map((e) => UserModel.fromJson(e.data()))
              .toList(),
        },
      );
    }
    catch(err){
      print(err);
    }
    isLoading.value = false;
  }
}
