import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestoreService.updateUserLastLogin(credential.user!.uid);
        return await _firestoreService.getUserById(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel?> createUserWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          uid: credential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestoreService.createUser(user);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        await _firestoreService.deleteUser(currentUser!.uid);
        await currentUser!.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'ລະຫັດຜ່ານອ່ອນແອເກີນໄປ';
      case 'email-already-in-use':
        return 'ອີເມລນີ້ຖືກນຳໃຊ້ແລ້ວ';
      case 'invalid-email':
        return 'ຮູບແບບອີເມລບໍ່ຖືກຕ້ອງ';
      case 'user-not-found':
        return 'ບໍ່ພົບຜູ້ໃຊ້ນີ້ໃນລະບົບ';
      case 'wrong-password':
        return 'ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ';
      case 'user-disabled':
        return 'ບັນຊີນີ້ຖືກປິດການໃຊ້ງານ';
      case 'too-many-requests':
        return 'ມີການພະຍາຍາມເຂົ້າສູ່ລະບົບຫຼາຍເກີນໄປ ກະລຸນາລອງໃໝ່ໃນພາຍຫຼັງ';
      case 'network-request-failed':
        return 'ບໍ່ສາມາດເຊື່ອມຕໍ່ອິນເຕີເນັດ';
      case 'invalid-credential':
        return 'ຂໍ້ມູນການເຂົ້າສູ່ລະບົບບໍ່ຖືກຕ້ອງ';
      default:
        return 'ເກີດຂໍ້ຜິດພາດ: ${e.message}';
    }
  }
}