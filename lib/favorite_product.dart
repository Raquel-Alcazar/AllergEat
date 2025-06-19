class FavoriteProduct  {
  int id;
  int userId;
  String productBarcode;

  FavoriteProduct ({required this.id, required this.userId, required this.productBarcode});

  Map<String, dynamic> toMap(){
    return {'id': id, 'user_id': userId, 'product_barcode': productBarcode};
  }

  @override
  String toString() {
    return 'FavoriteProduct {userId: $userId, productBarcode: $productBarcode}';
  }
}