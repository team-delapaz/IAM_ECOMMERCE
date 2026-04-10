# middleware v1

Use `ApiMiddleware` instead of raw HTTP. All calls return `ApiResponse<T>`: `status`, `success`, `message`, `data`. Network and HTTP errors are caught and returned as an `ApiResponse` with `success: false`, so you don't have to try/catch for normal flow na.

Standard JSON from backend:

```json
{
  "status": 200, // status code
  "success": true, // true or falsee of api call
  "message": "Products retrieved successfully.", // Display the message onn toasts , snackbars etc
  "data": {} // actual data of the api
}
```

## Setup after login

```dart
final res = await ApiMiddleware.auth.login(username, password);
if (res.success && res.data?.token != null) {
  await ApiMiddleware.setToken(res.data!.token!.accessToken);
}
```

## App startup

Call once before `runApp()` so saved token is reused:

```dart
WidgetsFlutterBinding.ensureInitialized();
await ApiMiddleware.init();
```

## Auth

- `ApiMiddleware.auth.login(username, password)` → `ApiResponse<LoginData?>`
- `ApiMiddleware.auth.signup(email: ..., mobileNo: ..., password: ..., firstName: ..., lastName: ...)` → `ApiResponse<dynamic>`
- `ApiMiddleware.auth.resendVerificationCode(email)` → `ApiResponse<VerificationResponse?>`
- `ApiMiddleware.auth.verifyCode(email: ..., code: ...)` → `ApiResponse<VerifyResponse?>`

## Cart

- `ApiMiddleware.cart.add(productCode: 'X', qty: 1)` → `ApiResponse<CartPayload?>`
- `ApiMiddleware.cart.getCart()` → `ApiResponse<CartPayload?>`
- `ApiMiddleware.cart.updateQty(productCode, qty)` → `ApiResponse<CartPayload?>`
- `ApiMiddleware.cart.deleteItem(productCode)` → `ApiResponse<CartPayload?>`

## Products

- `ApiMiddleware.products.getProducts()` → `ApiResponse<List<ProductItem?>>`
- `ApiMiddleware.products.getProductDetail(productCode)` → `ApiResponse<ProductItem?>`
- `ApiMiddleware.products.getProductsByCategory(categoryId)` → `ApiResponse<List<ProductItem?>>`

## Member

- `ApiMiddleware.member.getMember()` → `ApiResponse<MemberPayload?>`

## Payment

- `ApiMiddleware.payment.getPaymentMethods()` → `ApiResponse<List<PaymentMethodItem?>>`
- `ApiMiddleware.payment.getPaymentProviders()` → `ApiResponse<List<PaymentProviderItem?>>`
- `ApiMiddleware.payment.createPayment(orderNo: ..., idno: ..., amount: ..., currency: ..., paymentProvider: ..., paymentMethod: ..., description: ..., clientReferenceNo: ...)` → `ApiResponse<PaymentData?>`
- `ApiMiddleware.payment.callbackPayment(...)` → `ApiResponse<dynamic>`
- `ApiMiddleware.payment.getPaymentByTransaction(transactionId)` → `ApiResponse<dynamic>`
- `ApiMiddleware.payment.getPaymentStatus(refNo)` → `ApiResponse<dynamic>`

## Checkout

- `ApiMiddleware.checkout.checkout(fullName: ..., mobileNo: ..., emailAddress: ..., country: ..., province: ..., city: ..., barangay: ..., streetAddress: ..., postalCode: ..., completeAddress: ..., notes: 'optional note')` → `ApiResponse<dynamic>`

## Location

- `ApiMiddleware.location.getCountries()` → `ApiResponse<List<CountryItem?>>`
- `ApiMiddleware.location.getProvinces(country)` → `ApiResponse<List<ProvinceItem?>>`
- `ApiMiddleware.location.getCities(country, province)` → `ApiResponse<List<CityItem?>>`
- `ApiMiddleware.location.getBarangays(country, province, city)` → `ApiResponse<List<BarangayItem?>>`

## Address

- `ApiMiddleware.address.getAddresses()` → `ApiResponse<List<AddressItem?>>`
- `ApiMiddleware.address.getAddress(autoId)` → `ApiResponse<AddressItem?>`
- `ApiMiddleware.address.addAddress(recipientName: ..., mobileNo: ..., country: ..., province: ..., city: ..., barangay: ..., streetAddress: ..., postalCode: ..., completeAddress: ..., isDefault: ...)` → `ApiResponse<AddressItem?>`
- `ApiMiddleware.address.updateAddress(autoId: ..., recipientName: ..., mobileNo: ..., country: ..., province: ..., city: ..., barangay: ..., streetAddress: ..., postalCode: ..., completeAddress: ..., isDefault: ...)` → `ApiResponse<AddressItem?>`
- `ApiMiddleware.address.deleteAddress(autoId)` → `ApiResponse<dynamic>`
- `ApiMiddleware.address.setDefaultAddress(autoId)` → `ApiResponse<dynamic>`

## Orders

- `ApiMiddleware.orders.getOrders()` → `ApiResponse<List<OrderItem?>>`
- `ApiMiddleware.orders.getOrderDetail(refNo)` → `ApiResponse<OrderDetailItem?>`

## Product Review

- `ApiMiddleware.productReview.addReview(orderRefNo: ..., productCode: ..., rating: ..., reviewComment: ...)` → `ApiResponse<dynamic>` (POST `/ProductReview/Create`)
- `ApiMiddleware.productReview.getReviews(productCode)` → `ApiResponse<List<ProductReviewItem?>>`

## Wishlist

- `ApiMiddleware.wishlist.addWishlist(productCode)` → `ApiResponse<dynamic>`
- `ApiMiddleware.wishlist.getWishlist()` → `ApiResponse<List<WishlistItem?>>`
- `ApiMiddleware.wishlist.removeWishlist(productCode)` → `ApiResponse<dynamic>`
- `ApiMiddleware.wishlist.checkWishlist(productCode)` → `ApiResponse<WishlistCheckItem?>`

## Response handling

```dart
final res = await ApiMiddleware.auth.login(u, p);
if (!res.success) {
  // show res.message, check res.status
  return;
}
final token = res.data?.token?.accessToken;
final user = res.data?.user;
```

Typed models for login and products live in `responses/response_prep.dart`.

To follow to : some response mapping is left dynamic until some of thee API contracts are fixed.

Endpoints are in `endpoints/api_endpoints.dart`. Base URL is set in `ApiClient` / `ApiEndpoints.baseUrl`-
