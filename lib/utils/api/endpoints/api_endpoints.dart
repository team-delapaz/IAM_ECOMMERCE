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
  static String productsByCategory(int categoryId) => '/Products/Category/$categoryId';

  static const String member = '/Member';

  static const String paymentMethods = '/Payment/PaymentMethods';
  static const String paymentProviders = '/Payment/PaymentProviders';

  static const String checkout = '/Checkout';

  static const String paymentCreate = '/Payment/CreatePayment';
  static const String paymentCallback = '/Payment/Callback';
  static String paymentByTransaction(String transactionId) => '/Payment/$transactionId';
  static String paymentStatusByRef(String refNo) => '/Payment/Status/$refNo';
}
