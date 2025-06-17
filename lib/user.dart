
class User {
  int id;
  String name;
  String surname;
  String email;
  String password;
  
  User({required this.id, required this.name, required this.surname, required this.email, required this.password});

  Map<String, dynamic> toMap({withId = true}){
    if (withId) {
      return { 'id': id, 'name': name, 'surname': surname, 'email': email, 'password': password };
    }
    else{
      return {'name': name, 'surname': surname, 'email': email, 'password': password };
    }
  }

  @override
  String toString() {
    return 'Usuario{id: $id, name: $name, surname: $surname, email: $email}';
  }
}