# 🔄 Cart Migration Guide

## Changes to CartItemModel

### ❌ Old Structure (BEFORE)

```dart
class CartItemModel {
  final String id;
  final ProductModel product;      // ← Full product object
  final String selectedWeight;
  final int quantity;
  final double price;

  double get totalPrice => price * quantity;
}
```

### ✅ New Structure (AFTER)

```dart
class CartItemModel {
  final String id;
  final String cartItemId;         // ← New: API cart item ID
  final String productId;          // ← New: Product ID
  final String productName;        // ← New: Direct field
  final String productImage;       // ← New: Direct field
  final String selectedWeight;
  final int quantity;
  final double price;
  final double mrp;                // ← New: MRP price

  double get totalPrice => price * quantity;
  double get totalMrp => mrp * quantity;
  double get savings => totalMrp - totalPrice;
}
```

---

## Migration Steps

### 1. Update UI References

#### ❌ BEFORE

```dart
// Accessing product data
Text(item.product.name)
Image.network(item.product.imageUrl)
Text('ID: ${item.product.id}')
```

#### ✅ AFTER

```dart
// Direct access to fields
Text(item.productName)
Image.network(item.productImage)
Text('ID: ${item.productId}')
```

---

### 2. Update Controller Methods

#### ❌ BEFORE

```dart
void updateQuantity(String itemId, int newQuantity) {
  final index = cartItems.indexWhere((item) => item.id == itemId);
  if (index != -1 && newQuantity > 0) {
    cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
  }
}

void removeItem(String itemId) {
  cartItems.removeWhere((item) => item.id == itemId);
}
```

#### ✅ AFTER

```dart
// Use productId for updates
Future<void> updateQuantity(String productId, int newQuantity) async {
  await _cartService.updateCart(
    productId: productId,
    quantity: newQuantity,
  );
  await loadCartInfo();
}

// Use cartItemId for removal
Future<void> removeItem(String cartItemId) async {
  await _cartService.removeCartItem(cartItemId: cartItemId);
  await loadCartInfo();
}
```

---

### 3. Update View Bindings

#### ❌ BEFORE

```dart
// In cart_view.dart
IconButton(
  onPressed: () => controller.updateQuantity(
    item.id,              // ← Old: using item.id
    item.quantity + 1,
  ),
)

TextButton(
  onPressed: () => controller.removeItem(item.id),  // ← Old
)
```

#### ✅ AFTER

```dart
// In cart_view.dart
IconButton(
  onPressed: () => controller.updateQuantity(
    item.productId,       // ← New: using productId
    item.quantity + 1,
  ),
)

TextButton(
  onPressed: () => controller.removeItem(item.cartItemId),  // ← New
)
```

---

## Breaking Changes Summary

| What Changed      | Before                  | After                       |
| ----------------- | ----------------------- | --------------------------- |
| Product reference | `item.product.name`     | `item.productName`          |
| Product image     | `item.product.imageUrl` | `item.productImage`         |
| Product ID        | `item.product.id`       | `item.productId`            |
| Update cart       | Uses `item.id`          | Uses `item.productId`       |
| Remove item       | Uses `item.id`          | Uses `item.cartItemId`      |
| Price info        | Only `price`            | `price` + `mrp` + `savings` |

---

## Files Modified

### Core Changes

- ✅ `lib/core/network/network_constents.dart` - Added cart endpoints
- ✅ `lib/data/models/cart_item_model.dart` - Complete refactor
- ✅ `lib/data/services/cart_api_service.dart` - NEW FILE

### Controller Updates

- ✅ `lib/modules/cart/controllers/cart_controller.dart` - API integration
- ✅ `lib/modules/products/controllers/product_detail_controller.dart` - Add to cart

### View Updates

- ✅ `lib/modules/cart/views/cart_view.dart` - Model field updates

---

## Backward Compatibility

### OrderModel

✅ **No changes needed** - Already uses `CartItemModel`, so it automatically works with the new structure.

### JSON Parsing

✅ **Flexible parsing** - Supports both old and new field names:

```dart
product_id / productId ✓
product_name / name ✓
product_image / image / imageUrl ✓
qty / quantity ✓
```

---

## Testing Your Migration

Run these checks to ensure everything works:

```dart
// 1. Check CartItemModel parsing
final json = {
  'cart_item_id': '123',
  'product_id': '456',
  'product_name': 'Test Product',
  'product_image': 'https://...',
  'qty': 2,
  'price': '100.00',
};

final item = CartItemModel.fromJson(json);
assert(item.productId == '456');
assert(item.productName == 'Test Product');
assert(item.quantity == 2);

// 2. Check controller methods
await cartController.loadCartInfo();  // Should fetch from API
await cartController.updateQuantity('456', 3);  // Use productId
await cartController.removeItem('123');  // Use cartItemId

// 3. Check UI binding
Obx(() => Text('${cartController.cartCount.value}'));  // Should update
```

---

## Rollback Plan

If you need to rollback, restore these files from git:

```bash
git checkout HEAD~1 -- lib/data/models/cart_item_model.dart
git checkout HEAD~1 -- lib/modules/cart/controllers/cart_controller.dart
git checkout HEAD~1 -- lib/modules/cart/views/cart_view.dart
```

---

## Questions?

- **Q: Why remove `ProductModel` dependency?**

  - A: API returns flat cart items, not full product objects. Cleaner, faster parsing.

- **Q: What if I need full product details in cart?**

  - A: Either extend `CartItemModel` or fetch on-demand using `productId`.

- **Q: How to handle offline cart?**
  - A: Add local storage layer in `CartController` to cache cart items.

---

## Next Steps

1. ✅ Test add to cart flow
2. ✅ Test update quantity
3. ✅ Test remove item
4. ✅ Verify cart count updates
5. ✅ Check checkout flow with new model
6. 🔲 Add cart badge to navigation (optional)
7. 🔲 Implement cart persistence (optional)

---

**Migration Complete!** Your cart is now fully integrated with the API. 🎉
