class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password; 

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
    );
  }
}
 UserModel dummyUser = UserModel(
    id: '12345',
    name: 'Omar Khader',
    email: 'omarkhader@example.com',
    phoneNumber: '+1234567890',
    password: 'password123',
  );

  List<UserModel> dummyUsers = [
  ];