class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String password;
  final String uid;
  final String natId;
  final bool isApproved;
  final bool managerOrUser;

  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.password,
    required this.uid,
    required this.natId,
    required this.isApproved,
    required this.managerOrUser,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "first_name": firstName,
      "last_name": lastName,
      "role": role,
      "email": email,
      "password": password,
      "uid": uid,
      "nat_id": natId,
      "manager_or_user": managerOrUser,
      "is_approved": isApproved,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstName: map["first_name"] as String,
      lastName: map["last_name"] as String,
      role: map["role"] as String,
      managerOrUser: map["manager_or_user"] as bool,
      email: map["email"] as String,
      password: map["password"] as String,
      natId: map["nat_id"] as String,
      uid: map["uid"] as String,
      isApproved: map["is_approved"] as bool,
    );
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? password,
    String? uid,
    String? natId,
    bool? isApproved,
    bool? managerOrUser,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
      uid: uid ?? this.uid,
      natId: natId ?? this.natId,
      isApproved: isApproved ?? this.isApproved,
      managerOrUser: managerOrUser ?? this.managerOrUser,
    );
  }
}
