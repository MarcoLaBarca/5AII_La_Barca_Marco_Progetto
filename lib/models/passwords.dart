class Password {
  int id;
  String password;
  String email;
  String username;
  String url;
  String nome;

  Password(this.password, this.nome, [this.email, this.username, this.url]);

  Password.map(dynamic obj) {
    this.id = obj['password_id'];
    this.password = obj['password'];
    this.nome = obj['nome'];
    this.email = obj['email'];
    this.username = obj['username'];
    this.url = obj['url'];
  }
  //converto password in map per inserirlo nel database
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['password_id'] = id;
    }
    map['password'] = password;
    map['email'] = email;
    map['username'] = username;
    map['url'] = url;
    map['nome'] = nome;

    return map;
  }

  //Estraggo oggetto password da oggetto map
  Password.fromMapObject(Map<String, dynamic> map) {
    this.id = map['password_id'];
    this.password = map['password'];
    this.email = map['email'];
    this.username = map['username'];
    this.url = map['url'];
    this.nome = map['nome'];
  }
}
