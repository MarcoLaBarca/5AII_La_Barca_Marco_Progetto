class User {
  int id;
  String password;

  User(this.password);
  User.map(dynamic obj) {
    this.id = obj['user_id'];
    this.password = obj['password'];
  }

  //converto utente in map per inserirlo nel database
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['user_id'] = id;
    }
    map['password'] = password;
    return map;
  }

  //Estraggo oggetto user da oggetto map
  User.fromMapObject(Map<String, dynamic> map) {
    this.id = map['user_id'];
    this.password = map['password'];
  }
}