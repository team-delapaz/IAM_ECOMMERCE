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
- `ApiMiddleware.auth.signup(email: ..., mobileNo: ..., password: ..., firstName: ..., lastName: ..., referralId: 'optional')` → `ApiResponse<LoginData?>` (POST `/Auth/Signup`; `referralId` is optional and only sent when provided. Signups without referral return blank referral strings from the backend; the model normalizes blank `data.user.referralId` and `data.user.referralName` to `null`. Valid referral signups return those values. If an included referral ID is invalid/inactive, backend may return `status: 500`, `success: false`, `message: "Referral ID does not exist or is inactive."`, `data: null`; show `res.message`.)
- `ApiMiddleware.auth.resendVerificationCode(email)` → `ApiResponse<VerificationResponse?>`
- `ApiMiddleware.auth.verifyCode(email: ..., code: ...)` → `ApiResponse<VerifyResponse?>`

- `ApiMiddleware.auth.forgotPassword(emailAddress)` -> `ApiResponse<dynamic>` (POST `/Auth/ForgotPassword`, body `{ "emailAddress": "..." }`)
- `ApiMiddleware.auth.validateResetCode(emailAddress: ..., resetCode: ...)` -> `ApiResponse<ValidateResetCodeResponse?>` (POST `/Auth/ValidateResetCode`, body `{ "emailAddress": "...", "resetCode": "..." }`; success `data.isValid` is `true` when the reset code is valid)
- `ApiMiddleware.auth.resetPassword(emailAddress: ..., resetCode: ..., newPassword: ...)` -> `ApiResponse<dynamic>` (POST `/Auth/ResetPassword`, body `{ "emailAddress": "...", "resetCode": "...", "newPassword": "..." }`)
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
  - Profile is ready to display `data.username` when `/Member` starts returning it. The parser also accepts `userName` and `user_name`; until then the profile username row shows `N/A`.

## Payment

- `ApiMiddleware.payment.getPaymentMethods()` → `ApiResponse<List<PaymentMethodItem?>>`
- `ApiMiddleware.payment.getPaymentProviders()` → `ApiResponse<List<PaymentProviderItem?>>`
- `ApiMiddleware.payment.createPayment(orderNo: ..., idno: ..., amount: ..., currency: ..., paymentProvider: ..., paymentMethod: ..., description: ..., clientReferenceNo: ...)` → `ApiResponse<PaymentData?>`
- `ApiMiddleware.payment.callbackPayment(...)` → `ApiResponse<dynamic>`
- `ApiMiddleware.payment.getPaymentByTransaction(transactionId)` → `ApiResponse<dynamic>`
- `ApiMiddleware.payment.getPaymentStatus(refNo)` → `ApiResponse<dynamic>`

## Checkout

- `ApiMiddleware.checkout.checkout(fullName: ..., mobileNo: ..., emailAddress: ..., paymentProviderCode: ..., country: ..., province: ..., city: ..., barangay: ..., streetAddress: ..., postalCode: ..., completeAddress: ..., notes: 'optional note', fulfillmentTypeId: 2, areaCode: '101')` → `ApiResponse<CheckoutData?>` (POST `/Checkout`) — latest API body includes `fulfillmentTypeId` and `areaCode`; use fulfillment type from `getFulfillmentTypes()` and branch `areaCode` from `getBranches()` for pickup flows.
- `ApiMiddleware.checkout.computeFees(paymentProviderCode: 'IAMWALLET', country: 'PHILIPPINES', province: 'METRO-MANILA', city: 'QUEZON-CITY', fulfillmentTypeId: 2)` → `ApiResponse<ComputeFeesData?>` (POST `/Checkout/ComputeFees`) — latest API body includes `fulfillmentTypeId`; keep this value aligned with checkout request. Success `data` includes `cartRefno`, amounts, `totalBoxes`. On failure (e.g. no active cart), `success` is false, `data` is null, and `message` explains the error.

## Location

- `ApiMiddleware.location.getCountries()` → `ApiResponse<List<CountryItem?>>`
- `ApiMiddleware.location.getProvinces(country)` → `ApiResponse<List<ProvinceItem?>>`
- `ApiMiddleware.location.getCities(country, province)` → `ApiResponse<List<CityItem?>>`
- `ApiMiddleware.location.getBarangays(country, province, city)` → `ApiResponse<List<BarangayItem?>>`

## Fulfillment

- `ApiMiddleware.fulfillment.getFulfillmentTypes()` → `ApiResponse<List<FulfillmentTypeItem?>>` (GET `/api/FulfillmentTypes`) — returns options like `DELIVERY`, `PICKUP`
- `ApiMiddleware.fulfillment.getBranches()` → `ApiResponse<List<BranchItem?>>` (GET `/api/Branches`) — returns branch list (`areaCode`, `areaName`)

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
- `ApiMiddleware.orders.getOrderHistory(refNo)` → `ApiResponse<List<OrderStatusHistoryItem?>>` (GET `/Orders/{orderRefNo}/History`) — status timeline (e.g. `Delivered`, `In Transit`, with `trackingNo`, `remarks`, `userName`, `tranDate`)

## Product Review

- `ApiMiddleware.productReview.addReview(orderRefNo: ..., productCode: ..., rating: ..., reviewComment: ...)` → `ApiResponse<dynamic>` (POST `/ProductReview/Create`)
- `ApiMiddleware.productReview.getReviews(productCode)` → `ApiResponse<List<ProductReviewItem?>>` (GET `/ProductReview/{productCode}`) — items now include `reviewId/autoId`, `idno`, `orderRefNo`, `rating`, `reviewComment`, `createdAt`, `reviewerName`

## Wishlist

- `ApiMiddleware.wishlist.addWishlist(productCode)` → `ApiResponse<dynamic>`
- `ApiMiddleware.wishlist.getWishlist()` → `ApiResponse<List<WishlistItem?>>`
- `ApiMiddleware.wishlist.removeWishlist(productCode)` → `ApiResponse<dynamic>`
- `ApiMiddleware.wishlist.checkWishlist(productCode)` → `ApiResponse<WishlistCheckItem?>`

## Wallet (JWT required)

- `ApiMiddleware.wallet.getBalance()` → `ApiResponse<WalletBalanceData?>` (GET `/Wallet/Balance`)
- `ApiMiddleware.wallet.validateOrder(amount: ..., orderRefNo: ..., remarks: ...)` → `ApiResponse<WalletOrderPaymentData?>` (POST `/Wallet/ValidateOrder`)
- `ApiMiddleware.wallet.payOrder(amount: ..., orderRefNo: ..., remarks: ...)` → `ApiResponse<WalletOrderPaymentData?>` (POST `/Wallet/PayOrder`)
- `ApiMiddleware.wallet.getTransaction(tranno)` → `ApiResponse<dynamic>` (GET `/Wallet/Transaction/{tranno}`)
- `ApiMiddleware.wallet.sendOtp(orderRefNo: ...)` → `ApiResponse<dynamic>` (POST `/Wallet/SendOtp`, body `{ "orderRefNo": "..." }`) — Willl add DTO control laterrrr
- `ApiMiddleware.wallet.validateOtp(orderRefNo: ..., otpCode: ...)` → `ApiResponse<dynamic>` (POST `/Wallet/ValidateOtp`, body `{ "orderRefNo": "...", "otpCode": "..." }`) — Willl add DTO control laterrrr

## Points (JWT required)

- `ApiMiddleware.points.getPoints()` → `ApiResponse<List<dynamic>?>` (GET `/Points`)
- `ApiMiddleware.points.getBalance()` → `ApiResponse<PointsBalanceData?>` (GET `/Points/Balance`)

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

