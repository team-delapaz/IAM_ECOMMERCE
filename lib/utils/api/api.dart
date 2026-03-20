import 'core/api_client.dart';
import 'core/auth_token_store.dart';
import 'services/address_api.dart';
import 'services/auth_api.dart';
import 'services/cart_api.dart';
import 'services/checkout_api.dart';
import 'services/location_api.dart';
import 'services/member_api.dart';
import 'services/orders_api.dart';
import 'services/payment_api.dart';
import 'services/products_api.dart';

/// Single entry point for API calls...
///
/// sample is :
///   final res = await ApiMiddleware.auth.login(username, password);
///   if (res.success) { ... res.data?.token; }
///   ApiMiddleware.setToken(res.data?.token?.accessToken);

class ApiMiddleware {
  ApiMiddleware._();

  static final ApiClient _client = ApiClient();
  static final AuthTokenStore _tokenStore = AuthTokenStore();
  static final AuthApi auth = AuthApi(_client);
  static final AddressApi address = AddressApi(_client);
  static final CartApi cart = CartApi(_client);
  static final CheckoutApi checkout = CheckoutApi(_client);
  static final LocationApi location = LocationApi(_client);
  static final MemberApi member = MemberApi(_client);
  static final OrdersApi orders = OrdersApi(_client);
  static final PaymentApi payment = PaymentApi(_client);
  static final ProductsApi products = ProductsApi(_client);

  static Future<void> init() async {
    final token = await _tokenStore.read();
    _client.setAuthToken(token);
  }

  static Future<void> setToken(String? token) async {
    _client.setAuthToken(token);
    if (token == null || token.isEmpty) {
      await _tokenStore.clear();
      return;
    }
    await _tokenStore.write(token);
  }

  static Future<void> clearToken() => setToken(null);
}
