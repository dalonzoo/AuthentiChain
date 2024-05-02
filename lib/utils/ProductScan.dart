class ProductScan {
  String location; // Nome del prodotto
  String data; // Nome del produttore
  String device;
  String status; // Data di produzione

  ProductScan({
    required this.location,
    required this.data,
    required this.device,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'location': location,
    'data': data,
    'device': device,
    'status': status,
  };

  factory ProductScan.fromMap(Map<dynamic, dynamic> data) {
    return ProductScan(
      location: data['location'] as String,
      data: data['data'] as String,
      device: data['device'] as String,
      status: data['status'] as String,
    );
  }
}
