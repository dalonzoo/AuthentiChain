class ProductData {
  String nomeProdotto; // Name of the product
  String nomeProduttore; // Name of the producer
  String dataProduzione; // Production date
  String localitaProduzione; // Location of production
  String categoria; // Category
  String materiali; // List of materials used
  String particolariTipici; // Typical characteristics
  String linkProdotto; // Link to the product
  String immagini; // List of image URLs

  ProductData({
    required this.nomeProdotto,
    required this.nomeProduttore,
    required this.dataProduzione,
    required this.localitaProduzione,
    required this.categoria,
    required this.materiali,
    required this.particolariTipici,
    required this.linkProdotto,
    required this.immagini,
  });

  Map<String, dynamic> toJson() => {
    'nomeProdotto': nomeProdotto,
    'nomeProduttore': nomeProduttore,
    'dataProduzione': dataProduzione.toString(), // Convert DateTime to String
    'localitaProduzione': localitaProduzione,
    'categoria': categoria,
    'materiali': materiali,
    'particolariTipici': particolariTipici,
    'linkProdotto': linkProdotto,
    'immagini': immagini,
  };

  factory ProductData.fromMap(Map<dynamic, dynamic> data) {
    return ProductData(
      nomeProdotto: data['nomeProdotto'] as String,
      nomeProduttore: data['nomeProduttore'] as String,
      dataProduzione: data['dataProduzione'] as String, // Parse String back to DateTime
      localitaProduzione: data['localitaProduzione'] as String,
      categoria: data['categoria'] as String,
      materiali: data['materiali'] as String, // Convert dynamic list to String list
      particolariTipici: data['particolariTipici'] as String,
      linkProdotto: data['linkProdotto'] as String,
      immagini: data['immagini'] as String, // Convert dynamic list to String list
    );
  }
}
