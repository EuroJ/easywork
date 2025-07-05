import '../services/storage_service.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.role = 'employee',
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';
  
  // ใช้ Avatar ฟรีแทน Firebase Storage
  String get avatarUrl {
    if (profileImageUrl != null && 
        profileImageUrl!.isNotEmpty && 
        !profileImageUrl!.startsWith('https://ui-avatars.com')) {
      return profileImageUrl!;
    }
    
    // สร้าง Avatar URL ฟรี
    return StorageService.generateAvatarUrl(
      name: firstName.isNotEmpty ? firstName : fullName,
      userId: uid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] ?? 'employee',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}