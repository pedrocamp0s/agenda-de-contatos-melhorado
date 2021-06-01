class User {
  final String username;
  final String password;
  final String email;

  User({this.username, this.password, this.email});

  Map<String, dynamic> toMap() {
    return {'username': username, 'password': password, 'email': email};
  }
}
