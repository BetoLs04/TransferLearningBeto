class Credential {
  final String id;
  final String title;
  final String username;
  final String email;
  final String password;
  final String? website;
  final String? notes;
  final String categoryId;
  final String userId;
  final DateTime createdAt;

  Credential({
    required this.id,
    required this.title,
    required this.username,
    required this.email,
    required this.password,
    this.website,
    this.notes,
    required this.categoryId,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'email': email,
      'password': password,
      'website': website,
      'notes': notes,
      'categoryId': categoryId,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Credential.fromMap(Map<String, dynamic> map) {
    return Credential(
      id: map['id'] as String,
      title: map['title'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      website: map['website'] as String?,
      notes: map['notes'] as String?,
      categoryId: map['categoryId'] as String,
      userId: map['userId'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Credential && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}