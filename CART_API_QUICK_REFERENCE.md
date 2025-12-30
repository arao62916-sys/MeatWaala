# 🛒 Cart API Quick Reference

## 🚀 Quick Start

### Add to Cart (Product Detail Screen)

```dart
// In ProductDetailController
final CartApiService _cartService = CartApiService();

await _cartService.addToCart(
  productId: productId,
  quantity: quantity.value,
);
```

### Update Cart Quantity

```dart
// In CartController
await _cartService.updateCart(
  productId: item.productId,
  quantity: newQuantity,
);
```

### Remove from Cart

```dart
// In CartController
await _cartService.removeCartItem(
  cartItemId: item.cartItemId,
);
```

### Get Cart Count (Badge)

```dart
final result = await _cartService.getCartCount();
if (result.success) {
  cartCount.value = result.data!;
}
```

### Get Full Cart Info

```dart
final result = await _cartService.getCartInfo();
if (result.success) {
  final cartInfo = result.data!;
  cartItems.value = cartInfo.items;
  subtotal.value = cartInfo.subtotal;
  total.value = cartInfo.total;
}
```

---

## 📊 CartController State

Access cart data anywhere using GetX:

```dart
// Get controller
final cartController = Get.find<CartController>();

// Cart items
cartController.cartItems.value

// Cart count
cartController.cartCount.value

// Totals
cartController.subtotal.value
cartController.shippingCharge.value
cartController.total.value

// Loading state
cartController.isLoading.value
```

---

## 🎨 UI Integration

### Show Cart Count Badge

```dart
Obx(() => Badge(
  label: Text('${cartController.cartCount.value}'),
  child: Icon(Icons.shopping_cart),
))
```

### Show Cart Items

```dart
Obx(() {
  return ListView.builder(
    itemCount: cartController.cartItems.length,
    itemBuilder: (context, index) {
      final item = cartController.cartItems[index];
      return ListTile(
        title: Text(item.productName),
        subtitle: Text('Qty: ${item.quantity}'),
        trailing: Text('₹${item.totalPrice}'),
      );
    },
  );
})
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: cartController.refreshCart,
  child: ListView(...),
)
```

---

## ⚡ CartItemModel Structure

```dart
class CartItemModel {
  final String id;              // cart_item_id
  final String cartItemId;      // cart_item_id
  final String productId;       // product_id
  final String productName;     // product_name
  final String productImage;    // product_image
  final String selectedWeight;  // weight
  final int quantity;           // qty
  final double price;           // price
  final double mrp;             // mrp

  double get totalPrice;        // price * quantity
  double get totalMrp;          // mrp * quantity
  double get savings;           // totalMrp - totalPrice
}
```

---

## 🔄 API Response Structure

### Cart Info Response

```json
{
  "status": 1,
  "message": "Success",
  "data": {
    "aCart": [
      {
        "cart_item_id": "123",
        "product_id": "456",
        "product_name": "Chicken Breast",
        "product_image": "https://...",
        "qty": 2,
        "price": "299.00",
        "mrp": "350.00",
        "weight": "500g"
      }
    ],
    "subtotal": "598.00",
    "shipping_charge": "40.00",
    "discount": "0.00",
    "total": "638.00",
    "item_count": 1
  }
}
```

---

## 🛡️ Error Handling

### Check for Errors

```dart
final result = await _cartService.addToCart(...);

if (result.success) {
  // Success
  Get.snackbar('Success', result.message);
} else {
  // Error
  Get.snackbar('Error', result.message);
}
```

### Common Errors

- **Not logged in**: "Customer ID or Area ID not found"
- **Network error**: "No internet connection"
- **Timeout**: "Request timed out"
- **API validation**: Check `result.message` from API

---

## 🔍 Debugging

### Check Storage Values

```dart
final storage = StorageService();
print('Customer ID: ${storage.getUserId()}');
print('Area ID: ${storage.getSelectedAreaId()}');
```

### Check Cart State

```dart
cartController.debugPrint(); // Custom method if needed
print('Cart Items: ${cartController.cartItems.length}');
print('Cart Count: ${cartController.cartCount.value}');
```

---

## 💡 Pro Tips

1. **Optimistic Updates**: UI updates immediately, API syncs in background
2. **Auto Refresh**: Cart refreshes automatically after add/update/remove
3. **Reactive**: All state changes trigger UI updates automatically
4. **Error Recovery**: Failed operations revert to last known good state
5. **Persistent**: Cart persists on server (no local storage needed)

---

## 🎯 Common Patterns

### Add to Cart with Validation

```dart
Future<void> addToCart() async {
  if (productDetail.value == null) return;

  if (quantity.value < 1) {
    Get.snackbar('Error', 'Invalid quantity');
    return;
  }

  isAddingToCart.value = true;

  final result = await _cartService.addToCart(
    productId: productId,
    quantity: quantity.value,
  );

  isAddingToCart.value = false;

  if (result.success) {
    Get.toNamed(AppRoutes.cart);
  }
}
```

### Increment/Decrement Quantity

```dart
void incrementQuantity(String productId, int currentQty) {
  controller.updateQuantity(productId, currentQty + 1);
}

void decrementQuantity(String productId, int currentQty) {
  if (currentQty > 1) {
    controller.updateQuantity(productId, currentQty - 1);
  } else {
    // Remove if quantity becomes 0
    controller.removeItem(cartItemId);
  }
}
```

### Show Cart Badge

```dart
// In AppBar or BottomNavigation
IconButton(
  icon: Stack(
    children: [
      Icon(Icons.shopping_cart),
      Obx(() {
        if (cartController.cartCount.value > 0) {
          return Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${cartController.cartCount.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return SizedBox.shrink();
      }),
    ],
  ),
  onPressed: () => Get.toNamed(AppRoutes.cart),
)
```

---

## 📦 Dependencies Used

- `get`: State management and dependency injection
- `get_storage`: Local storage for user/area IDs
- `http`: HTTP requests
- `cached_network_image`: Image caching

---

## ✅ Testing Checklist

- [ ] Add item to cart → Success message → Navigate to cart
- [ ] Increment quantity → UI updates → API syncs
- [ ] Decrement quantity → UI updates → API syncs
- [ ] Remove item → Item disappears → Count updates
- [ ] Pull to refresh → Cart reloads
- [ ] Empty cart → Shows empty state
- [ ] Not logged in → Error message
- [ ] Network error → Retry or error message
- [ ] Cart badge updates on all screens

---

**Need Help?** Check [CART_API_INTEGRATION_SUMMARY.md](./CART_API_INTEGRATION_SUMMARY.md) for detailed implementation docs.
