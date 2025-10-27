class AppUser {
  final String? id;
  final String email;
  final String? displayName;

  AppUser({
    this.id,
    required this.email,
    this.displayName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
    );
  }
}