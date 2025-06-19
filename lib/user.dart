class User {
  int id;
  String name;
  String surname;
  String email;
  String password;
  List<String>? allergies;
  
  User({required this.id, required this.name, required this.surname, required this.email, required this.password, this.allergies}) {
    allergies ??= [];
  }

  Map<String, dynamic> toMap(){
    return { 'id': id, 'name': name, 'surname': surname, 'email': email, 'password': password, 'allergies': allergies };
  }

  @override
  String toString() {
    return 'Usuario{id: $id, name: $name, surname: $surname, email: $email, allergies: $allergies}';
  }
}