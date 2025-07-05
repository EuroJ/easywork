import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSetupService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สร้าง users และข้อมูลทั้งหมดพร้อมกัน
  static Future<void> setupCompleteProject() async {
    print('🚀 Starting Firebase project setup...');
    
    try {
      // 1. สร้าง users
      final users = await _createAllUsers();
      print('✅ Created ${users.length} users');
      
      // 2. สร้าง demo tasks
      await _createDemoTasks(users);
      print('✅ Created demo tasks');
      
      print('🎉 Firebase project setup completed!');
      print('💡 You can now login with:');
      print('   - admin@easywork.com / admin123');
      print('   - john@easywork.com / user123');
      print('   - mary@easywork.com / user123');
      print('   - demo@easywork.com / demo123');
      
    } catch (e) {
      print('❌ Setup failed: $e');
    }
  }

  static Future<List<String>> _createAllUsers() async {
    final usersData = [
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
        'email': 'demo@easywork.com',
        'password': 'demo123',
        'firstName': 'Demo',
        'lastName': 'User',
        'role': 'employee',
      },
    ];

    List<String> userIds = [];

    for (var userData in usersData) {
      try {
        // สร้าง user ใน Authentication
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: userData['email']!,
          password: userData['password']!,
        );

        if (userCredential.user != null) {
          final uid = userCredential.user!.uid;
          userIds.add(uid);

          // เพิ่มข้อมูลใน Firestore
          await _firestore.collection('users').doc(uid).set({
            'uid': uid,
            'email': userData['email'],
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'role': userData['role'],
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'profileImageUrl': null,
          });

          print('✅ Created user: ${userData['email']}');
        }
      } catch (e) {
        print('❌ Failed to create ${userData['email']}: $e');
        // อาจจะ user มีอยู่แล้ว - ลองหา UID
        try {
          final existingUsers = await _firestore
              .collection('users')
              .where('email', isEqualTo: userData['email'])
              .get();
          
          if (existingUsers.docs.isNotEmpty) {
            userIds.add(existingUsers.docs.first.id);
            print('📌 User ${userData['email']} already exists');
          }
        } catch (e2) {
          print('❌ Could not find existing user: $e2');
        }
      }
    }

    return userIds;
  }

  static Future<void> _createDemoTasks(List<String> userIds) async {
    if (userIds.length < 3) {
      print('⚠️ Need at least 3 users to create demo tasks');
      return;
    }

    final adminId = userIds[0]; // Admin
    final johnId = userIds[1];  // John
    final maryId = userIds[2];  // Mary

    final demoTasks = [
      {
        'id': 'task-001',
        'title': 'ອັບເດດລະບົບຈັດການ',
        'description': 'ປັບປຸງລະບົບຈັດການງານໃຫ້ທັນສະໄໝ ແລະ ເພີ່ມຟີເຈີໃໝ່',
        'createdBy': adminId,
        'assignedTo': johnId,
        'status': 1, // inProgress
        'priority': 2, // high
        'category': 'Development',
        'daysFromNow': 7,
        'progress': 45.0,
      },
      {
        'id': 'task-002',
        'title': 'ລາຍງານປະຈໍາເດືອນ',
        'description': 'ຈັດທໍາລາຍງານສະຫຼຸບຜົນງານປະຈໍາເດືອນ',
        'createdBy': adminId,
        'assignedTo': maryId,
        'status': 0, // pending
        'priority': 1, // medium
        'category': 'Report',
        'daysFromNow': 3,
        'progress': 0.0,
      },
      {
        'id': 'task-003',
        'title': 'ປັບປຸງ UI ໃໝ່',
        'description': 'ອອກແບບ UI ໃໝ່ໃຫ້ສວຍງາມ ແລະ ໃຊ້ງານງ່າຍ',
        'createdBy': adminId,
        'assignedTo': johnId,
        'status': 2, // completed
        'priority': 1, // medium
        'category': 'Design',
        'daysFromNow': -2, // overdue
        'progress': 100.0,
      },
    ];

    for (var taskData in demoTasks) {
      final dueDate = DateTime.now().add(Duration(days: taskData['daysFromNow'] as int));
      
      await _firestore.collection('tasks').doc(taskData['id'] as String).set({
        'id': taskData['id'],
        'title': taskData['title'],
        'description': taskData['description'],
        'createdBy': taskData['createdBy'],
        'assignedTo': taskData['assignedTo'],
        'status': taskData['status'],
        'priority': taskData['priority'],
        'category': taskData['category'],
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': dueDate.millisecondsSinceEpoch,
        'completedAt': taskData['status'] == 2 ? DateTime.now().millisecondsSinceEpoch : null,
        'attachments': [],
        'comments': [],
        'progress': taskData['progress'],
      });
    }
  }

  // ตรวจสอบข้อมูลที่มีอยู่
  static Future<void> checkProjectData() async {
    try {
      // ตรวจสอบ users
      final usersSnapshot = await _firestore.collection('users').get();
      print('👥 Users in Firestore: ${usersSnapshot.docs.length}');
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        print('   - ${data['email']} (${data['role']})');
      }

      // ตรวจสอบ tasks
      final tasksSnapshot = await _firestore.collection('tasks').get();
      print('📋 Tasks in Firestore: ${tasksSnapshot.docs.length}');
      
      for (var doc in tasksSnapshot.docs) {
        final data = doc.data();
        print('   - ${data['title']}');
      }

    } catch (e) {
      print('❌ Error checking data: $e');
    }
  }

  // ลบข้อมูลทั้งหมด (สำหรับ reset)
  static Future<void> resetProject() async {
    try {
      // ลบ tasks
      final tasksSnapshot = await _firestore.collection('tasks').get();
      for (var doc in tasksSnapshot.docs) {
        await doc.reference.delete();
      }

      // ลบ users จาก Firestore
      final usersSnapshot = await _firestore.collection('users').get();
      for (var doc in usersSnapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ Project data reset complete');
      print('⚠️ You need to manually delete users from Authentication console');
      
    } catch (e) {
      print('❌ Reset failed: $e');
    }
  }
}