class User {
  final String email;
  final String name;

  User({
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json["email"],
    name: json["name"],
  );

  factory User.empty() => User(
      email: '',
      name: '',
  );
}


