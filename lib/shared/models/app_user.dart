// lib/shared/models/app_user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool surveyCompleted;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
    this.surveyCompleted = false,
  });

  /// Deserialize from Firestore document snapshot
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['uid'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      surveyCompleted: data['surveyCompleted'] as bool? ?? false,
    );
  }

  /// Serialize to Firestore — use FieldValue.serverTimestamp() for dates
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLogin': Timestamp.fromDate(lastLogin),
    'surveyCompleted': surveyCompleted,
  };

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? surveyCompleted,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      surveyCompleted: surveyCompleted ?? this.surveyCompleted,
    );
  }

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, surveyCompleted: $surveyCompleted)';
}