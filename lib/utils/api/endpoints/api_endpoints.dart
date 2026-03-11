/// Central API base URL and path constants.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://ecom-api-staging.iam-ww.com/v1';

  static const String authLogin = '/Auth/Login';
  static const String authSignup = '/Auth/Signup';

  static const String cart = '/Cart';
  static const String cartAdd = '/Cart/Add';
  static String cartQty(String productCode) => '/Cart/Qty/$productCode';
  static String cartItem(String productCode) => '/Cart/$productCode';

  static const String products = '/Products';
  static String productDetail(String productCode) => '/Products/$productCode';
}
