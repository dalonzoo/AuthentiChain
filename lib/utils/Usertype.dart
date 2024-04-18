class User {
  String? image;
  String? materia;
  String? citta;
  String? bio;

  User({
    this.image,
    this.materia,
    this.citta,
    this.bio,
  });

  Map<String, dynamic> toJson() => {
    'image': image,
    'materia': materia,
    'citta': citta,
    'bio': bio,
  };
}
