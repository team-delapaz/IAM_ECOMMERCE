# middleware v1 

Use `ApiMiddleware` instead of raw HTTP. All calls return `ApiResponse<T>`: `status`, `success`, `message`, `data`. Network and HTTP errors are caught and returned as an `ApiResponse` with `success: false`, so you don't have to try/catch for normal flow na.

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

## Cart

- `ApiMiddleware.cart.add(productCode: 'X', qty: 1, sourceApp: 'M')`
- `ApiMiddleware.cart.getCart()`
- `ApiMiddleware.cart.updateQty(productCode, qty)`
- `ApiMiddleware.cart.deleteItem(productCode)`

## Products

- `ApiMiddleware.products.getProducts()` → `ApiResponse<List<ProductItem?>>`
- `ApiMiddleware.products.getProductDetail(productCode)` → `ApiResponse<ProductItem?>`

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
