// lib/models/place_order_product.dart

class PlaceOrderProduct {
  String prodID;
  String name;
  int qty;
  double price;
  double bonus;
  double discount;

  PlaceOrderProduct({
    required this.prodID,
    required this.name,
    this.qty = 0,
    required this.price,
    this.bonus = 0.0,
    this.discount = 0.0,
  });

  PlaceOrderProduct.copy(PlaceOrderProduct other)
      : prodID = other.prodID,
        name = other.name,
        qty = other.qty,
        price = other.price,
        bonus = other.bonus,
        discount = other.discount;

  double getGrandTotal() {
    double total = price * qty;
    double discountAmount = (total * discount) / 100; // Discount is percentage
    return (total - discountAmount) + bonus;
  }

  @override
  String toString() {
    return 'Product ID: $prodID, Name: $name, Quantity: $qty, Price: $price, Bonus: $bonus, Discount: $discount, Grand Total: ${getGrandTotal()}';
  }
}
