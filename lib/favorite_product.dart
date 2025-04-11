
class FavoriteProduct  {
  int userId;
  int productId;

  
  FavoriteProduct ({required this.userId, required this.productId});

  Map<String, dynamic> toMap(){
    return { 'userId': userId, 'productId ': productId};
  }

    @override
  String toString() {
    return 'FavoriteProduct {userId: $userId, productId: $productId}';
  }
}