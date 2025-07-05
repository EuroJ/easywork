import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCreationService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สร้าง users ทั้งหมดพร้อมกัน
  static Future<void> createAllDemoUsers() async {
    final users = [
      {
        'email': 'admin@easywork.com',
        'password': 'admin123',
        'firstName': 'ທ້າວ',
        'lastName': 'ແອດມິນ',
        'role': 'admin',
      },
      {
        'email': 'john@easywork.com', 
        'password': 'user123',
        'firstName': 'ທ້າວ',
        'lastName': 'ຈອນ',
        'role': 'employee',
      },
      {
        'email': 'mary@easywork.com',
        'password': 'user123', 
        'firstName': 'ນາງ',
        'lastName': 'ແມຣີ',
        'role': 'employee',
      },
      {
        'email': 'david@easywork.com',
        'password': 'user123',
        'firstName': 'ທ້າວ', 
        'lastName': 'ເດວິດ',
        'role': 'employee',
      },
      {
        'email': 'sarah@easywork.com',
        'password': 'user123',
        'firstName': 'ນາງ',
        'lastName': 'ຊາຣາ', 
        'role': 'employee',
      },
    ];

    for (var userData in users) {
      try {
        await createUser(
          email: userData['email']!,
          password: userData['password']!,
          firstName: userData['firstName']!,
          lastName: userData['lastName']!,
          role: userData['role']!,
        );
        print('✅ Created user: ${userData['email']}');
      } catch (e) {
        print('❌ Failed to create ${userData['email']}: $e');
      }
    }
  }

  // สร้าง user หนึ่งคน
  static Future<String?> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'employee',
  }) async {
    try {
      // สร้าง user ใน Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        
        // เพิ่มข้อมูลใน Firestore
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'profileImageUrl': null,
        });

        return uid;
      }
      return null;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // ตรวจสอบ users ที่มีอยู่
  static Future<void> checkExistingUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      print('📊 Total users in Firestore: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('👤 ${data['email']} (${data['role']})');
      }
    } catch (e) {
      print('Error checking users: $e');
    }
  }

  // ลบ users ทั้งหมด (สำหรับ reset)
  static Future<void> deleteAllUsers() async {
    try {
      // ลบจาก Firestore
      final snapshot = await _firestore.collection('users').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      print('✅ All users deleted from Firestore');
      print('⚠️ Need to manually delete from Authentication');
    } catch (e) {
      print('Error deleting users: $e');
    }
  }
}