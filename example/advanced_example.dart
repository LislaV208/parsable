// ignore_for_file: avoid_print

import 'package:parsable/parsable.dart';

// E-commerce domain models

class Price extends Parsable {
  const Price({required super.data});

  double get amount => get('amount') ?? 0.0;
  String get currency => get('currency') ?? 'USD';

  String get formatted => '\$$amount $currency';

  factory Price.fromMap(Map<String, dynamic> map) => Price(data: map);
}

class ProductImage extends Parsable {
  const ProductImage({required super.data});

  String? get url => get('url');
  String? get alt => get('alt');
  int get width => get('width') ?? 0;
  int get height => get('height') ?? 0;

  factory ProductImage.fromMap(Map<String, dynamic> map) =>
      ProductImage(data: map);
}

class Product extends Parsable {
  const Product({required super.data});

  String get id => get('id') ?? '';
  String get name => get('name') ?? 'Unknown';
  String? get description => get('description');
  Price? get price => get('price', parser: Price.fromMap);
  ProductImage? get mainImage => get('mainImage', parser: ProductImage.fromMap);
  int get stockQuantity => get('stockQuantity') ?? 0;
  bool get isAvailable => get('isAvailable') ?? false;

  // List parsing - needs manual handling
  List<String> get tags {
    final tagsList = data['tags'] as List?;
    return tagsList?.cast<String>() ?? [];
  }

  // Computed property
  bool get inStock => stockQuantity > 0 && isAvailable;

  factory Product.fromMap(Map<String, dynamic> map) => Product(data: map);
}

class ShippingInfo extends Parsable {
  const ShippingInfo({required super.data});

  String get method => get('method') ?? 'Standard';
  double get cost => get('cost') ?? 0.0;
  int get estimatedDays => get('estimatedDays') ?? 5;

  factory ShippingInfo.fromMap(Map<String, dynamic> map) =>
      ShippingInfo(data: map);
}

class OrderItem extends Parsable {
  const OrderItem({required super.data});

  Product? get product => get('product', parser: Product.fromMap);
  int get quantity => get('quantity') ?? 1;

  double get subtotal {
    final productPrice = product?.price?.amount ?? 0.0;
    return productPrice * quantity;
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(data: map);
}

class PaymentInfo extends Parsable {
  const PaymentInfo({required super.data});

  String get method => get('method') ?? 'Unknown';
  String? get transactionId => get('transactionId');
  String? get last4Digits => get('last4Digits');

  factory PaymentInfo.fromMap(Map<String, dynamic> map) =>
      PaymentInfo(data: map);
}

class Order extends Parsable {
  const Order({required super.data});

  String get orderId => get('orderId') ?? '';
  String? get customerId => get('customerId');
  String get status => get('status') ?? 'pending';
  ShippingInfo? get shipping => get('shipping', parser: ShippingInfo.fromMap);
  PaymentInfo? get payment => get('payment', parser: PaymentInfo.fromMap);

  DateTime? get orderDate {
    final String? dateStr = get('orderDate');
    return dateStr != null ? DateTime.tryParse(dateStr) : null;
  }

  // Parse list of order items
  List<OrderItem> get items =>
      getList('items', parser: OrderItem.fromMap) ?? [];

  // Computed properties
  double get itemsTotal {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get shippingCost => shipping?.cost ?? 0.0;

  double get totalAmount => itemsTotal + shippingCost;

  factory Order.fromMap(Map<String, dynamic> map) => Order(data: map);
}

// Custom error handling example
class StrictProduct extends Parsable {
  const StrictProduct({required super.data});

  String get id => get('id') ?? '';
  String get name => get('name') ?? '';
  double get price => get('price') ?? 0.0;

  factory StrictProduct.fromMap(Map<String, dynamic> map) =>
      StrictProduct(data: map);
}

void main() {
  print('=== Advanced Parsable Examples ===\n');

  // Example 1: Complex nested objects
  print('1. E-commerce Order with Multiple Nested Levels:');

  final orderData = {
    'orderId': 'ORD-2024-001',
    'customerId': 'CUST-123',
    'status': 'processing',
    'orderDate': '2024-01-15T10:30:00Z',
    'items': [
      {
        'product': {
          'id': 'PROD-001',
          'name': 'Wireless Headphones',
          'description': 'Premium noise-cancelling headphones',
          'price': {'amount': 199.99, 'currency': 'USD'},
          'mainImage': {
            'url': 'https://example.com/headphones.jpg',
            'alt': 'Wireless Headphones',
            'width': 800,
            'height': 600,
          },
          'stockQuantity': 50,
          'isAvailable': true,
          'tags': ['electronics', 'audio', 'wireless'],
        },
        'quantity': 2,
      },
      {
        'product': {
          'id': 'PROD-002',
          'name': 'Phone Case',
          'price': {'amount': 29.99, 'currency': 'USD'},
          'stockQuantity': 100,
          'isAvailable': true,
          'tags': ['accessories', 'mobile'],
        },
        'quantity': 1,
      },
    ],
    'shipping': {'method': 'Express', 'cost': 15.00, 'estimatedDays': 2},
    'payment': {
      'method': 'Credit Card',
      'transactionId': 'TXN-ABC123',
      'last4Digits': '4242',
    },
  };

  final order = Order.fromMap(orderData);

  print('   Order ID: ${order.orderId}');
  print('   Status: ${order.status}');
  print('   Date: ${order.orderDate}');
  print('');

  print('   Items:');
  for (var i = 0; i < order.items.length; i++) {
    final item = order.items[i];
    print('   ${i + 1}. ${item.product?.name}');
    print('      Price: ${item.product?.price?.formatted}');
    print('      Quantity: ${item.quantity}');
    print('      Subtotal: \$${item.subtotal.toStringAsFixed(2)}');
    print('      Tags: ${item.product?.tags.join(", ")}');
    print('      In Stock: ${item.product?.inStock}');
  }
  print('');

  print('   Shipping:');
  print('   Method: ${order.shipping?.method}');
  print('   Cost: \$${order.shippingCost.toStringAsFixed(2)}');
  print('   Estimated delivery: ${order.shipping?.estimatedDays} days');
  print('');

  print('   Payment:');
  print('   Method: ${order.payment?.method}');
  print('   Card: **** **** **** ${order.payment?.last4Digits}');
  print('   Transaction: ${order.payment?.transactionId}');
  print('');

  print('   Total Summary:');
  print('   Items Total: \$${order.itemsTotal.toStringAsFixed(2)}');
  print('   Shipping: \$${order.shippingCost.toStringAsFixed(2)}');
  print('   Grand Total: \$${order.totalAmount.toStringAsFixed(2)}');
  print('');

  // Example 2: Custom error handling
  print('2. Custom Error Handling:');

  final errors = <String>[];

  // Set up custom error handler
  Parsable.setOnParseError((message) {
    errors.add(message);
  });

  final invalidData = {
    'id': 'PROD-003',
    'name': 123, // Should be String - will cause error
    'price': 'invalid', // Should be double - will cause error
  };

  final product = StrictProduct.fromMap(invalidData);

  print('   Product ID: ${product.id}');
  print('   Product Name: ${product.name} (fell back to default)');
  print('   Product Price: ${product.price} (fell back to default)');
  print('');
  print('   Captured errors:');
  for (var error in errors) {
    print('   - $error');
  }
  print('');

  // Reset error handler to default
  Parsable.setOnParseError((message) {});

  // Example 3: Disabling numeric conversions
  print('3. Strict Type Checking (Numeric Conversions Disabled):');

  Parsable.handleNumericConversions(false);

  final strictData = {
    'id': 'PROD-004',
    'name': 'Test Product',
    'price': 50, // int instead of double
  };

  final strictProduct = StrictProduct.fromMap(strictData);

  print('   Product ID: ${strictProduct.id}');
  print('   Product Name: ${strictProduct.name}');
  print(
    '   Product Price: ${strictProduct.price} (got default because int was not converted to double)',
  );
  print('');

  // Re-enable conversions
  Parsable.handleNumericConversions(true);

  final lenientProduct = StrictProduct.fromMap(strictData);
  print('   With conversions enabled:');
  print('   Product Price: ${lenientProduct.price} (int converted to double)');
  print('');

  // Example 4: Equality with complex nested objects
  print('4. Equality Comparison with Nested Objects:');

  final order1Data = {
    'orderId': 'ORD-001',
    'status': 'pending',
    'shipping': {'method': 'Standard', 'cost': 10.0},
  };

  final order2Data = {
    'orderId': 'ORD-001',
    'status': 'pending',
    'shipping': {'method': 'Standard', 'cost': 10.0},
  };

  final order1 = Order.fromMap(order1Data);
  final order2 = Order.fromMap(order2Data);

  print('   Order 1: ${order1.orderId}');
  print('   Order 2: ${order2.orderId}');
  print('   Are equal: ${order1 == order2}');
  print('   (Note: Both have same structure and values)');
  print('');

  // Example 5: Handling deeply nested null values
  print('5. Partial Data and Null Safety:');

  final partialOrderData = {
    'orderId': 'ORD-002',
    // No items, shipping, payment, etc.
  };

  final partialOrder = Order.fromMap(partialOrderData);

  print('   Order ID: ${partialOrder.orderId}');
  print('   Status: ${partialOrder.status} (default)');
  print('   Items count: ${partialOrder.items.length}');
  print(
    '   Shipping method: ${partialOrder.shipping?.method ?? 'Not specified'}',
  );
  print('   Total amount: \$${partialOrder.totalAmount.toStringAsFixed(2)}');
  print('');

  print('=== Advanced Examples Complete ===');
}
