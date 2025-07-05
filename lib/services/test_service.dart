import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/storage_service.dart';

class TestService {
  static Future<void> testFirebaseConnection() async {
    try {
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection').set({
        'message': 'Firebase connected successfully!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✅ Firestore connection successful!');
      
      // Test Authentication
      final auth = FirebaseAuth.instance;
      print('✅ Auth service initialized: ${auth.app.name}');
      
      // Check if we can read from users collection
      final usersSnapshot = await firestore.collection('users').limit(1).get();
      print('✅ Can read users collection: ${usersSnapshot.docs.length} documents');
      
      // Test Avatar Generation
      final avatarUrl = StorageService.generateAvatarUrl(
        name: 'Test User',
        userId: 'test-123',
      );
      print('✅ Avatar generation works: $avatarUrl');
      
    } catch (e) {
      print('❌ Firebase connection failed: $e');
    }
  }
  
  static Future<void> createDemoUser() async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      
      // Create demo user
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: 'demo@easywork.com',
        password: 'demo123',
      );
      
      if (userCredential.user != null) {
        // Add user to Firestore
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': 'demo@easywork.com',
          'firstName': 'Demo',
          'lastName': 'User',
          'role': 'employee',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'profileImageUrl': null, // จะใช้ generated avatar
        });
        
        print('✅ Demo user created successfully!');
        print('Email: demo@easywork.com');
        print('Password: demo123');
        print('UID: ${userCredential.user!.uid}');
        
        // Generate avatar URL
        final avatarUrl = StorageService.generateAvatarUrl(
          name: 'Demo User',
          userId: userCredential.user!.uid,
        );
        print('✅ Avatar URL: $avatarUrl');
      }
    } catch (e) {
      print('❌ Failed to create demo user: $e');
    }
  }
}