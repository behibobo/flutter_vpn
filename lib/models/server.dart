class Server {
  int id;
  String country;
  String flag;
  String ip;
  String username;
  String password;
  bool premium;

  Server(
      {this.id,
      this.country,
      this.flag,
      this.ip,
      this.username,
      this.password,
      this.premium});

  Server.fromJson(Map json)
      : id = json['id'],
        country = json['country'],
        flag = json['flag'],
        ip = json['ip'],
        username = json['username'],
        password = json['password'],
        premium = json['premium'];

  Map toJson() {
    return {
      'id': id,
      'country': country,
      'flag': flag,
      'ip': ip,
      'username': username,
      'password': password,
      'premium': premium,
    };
  }
}
