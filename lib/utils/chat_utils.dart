class ChatUtils {
  static String getRoomId(String uid1, String uid2) {
    final users = [uid1, uid2]..sort();
    return users.join("_");
  }
}