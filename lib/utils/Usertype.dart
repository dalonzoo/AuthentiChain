class UserData {
  String image;
  String nomeCognome;
  String categoria;
  String citta;
  String id;
  String email;
  String prodotti;
  String tipo;
  String acquisti;

  UserData({
    required this.prodotti,
    required this.tipo,
    required this.id,
    required this.image,
    required this.nomeCognome,
    required this.citta,
    required this.categoria,
    required this.email,
    required this.acquisti,
  });

  Map<String, dynamic> toJson() => {
    'tipo' : tipo,
    'id' : id,
    'image': image,
    'nomeCognome': nomeCognome,
    'citta': citta,
    'categoria': categoria,
    'email' : email,
    'prodotti': prodotti,
    'acquisti' : acquisti,
  };

  factory UserData.fromMap(Map<dynamic, dynamic> data) {
    return UserData(
      tipo: data['tipo'],
      prodotti: data['prodotti'],
      email: data['email'] as String,
      id: data['id'] as String,
      image: data['image'] as String,
      nomeCognome: data['nomeCognome'] as String,
      citta: data['citta'] as String,
      categoria: data['categoria'] as String,
      acquisti: data['acquisti'] as String,
    );
  }
}
