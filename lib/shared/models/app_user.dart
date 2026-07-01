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

  /// True when the user selected 'Under 13' during the survey.
  /// Stored top-level (not nested under `survey`) so backend scripts
  /// can query it directly: `.where('isChild', isEqualTo: true)`.
  final bool isChild;

  /// Guardian's alternate email, only relevant when [isChild] is true.
  /// Null/empty until the child (or their guardian) sets it.
  final String? guardianEmail;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
    this.surveyCompleted = false,
    this.isChild = false,
    this.guardianEmail,
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
      isChild: data['isChild'] as bool? ?? false,
      guardianEmail: data['guardianEmail'] as String?,
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
    'isChild': isChild,
    'guardianEmail': guardianEmail,
  };

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? surveyCompleted,
    bool? isChild,
    String? guardianEmail,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      surveyCompleted: surveyCompleted ?? this.surveyCompleted,
      isChild: isChild ?? this.isChild,
      guardianEmail: guardianEmail ?? this.guardianEmail,
    );
  }

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, surveyCompleted: $surveyCompleted, isChild: $isChild)';
}