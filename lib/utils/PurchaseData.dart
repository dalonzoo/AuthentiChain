class Purchasedata {
  String image; // Nome del prodotto
  String data; // Nome del produttore// Data di produzione
  String location;
  String userId;
  String productId;
  Purchasedata({
    required this.image,
    required this.data,
    required this.location,
    required this.userId,
    required this.productId,
  });

  Map<String, dynamic> toJson() => {
    'image': image,
    'data': data,
    'idUser': userId,
    'location': location,
    'idProduct' : productId,
  };

  factory Purchasedata.fromMap(Map<dynamic, dynamic> data) {
    return Purchasedata(

      productId: data['idProduct'] as String,
      image: data['image'] as String,
      data: data['data'] as String,
      location: data['location'] as String,
      userId: data['idUser'] as String,

    );
  }
}
