/// Central API base URL and path constants.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://ecom-api-staging.iam-ww.com/v1';

  static const String authLogin = '/Auth/Login';
  static const String authSignup = '/Auth/Signup';
  static const String authResendVerificationCode = '/Auth/ResendVerificationCode';
  static const String authVerifyCode = '/Auth/VerifyEmailCode';

  static const String cart = '/Cart';
  static const String cartAdd = '/Cart/Add';
  static const String cartQty = '/Cart/Qty';
  static String cartItem(String productCode) => '/Cart/$productCode';

  static const String products = '/Products';
  static String productDetail(String productCode) => '/Products/$productCode';
  static String productsByCategory(int categoryId) => '/Products/Category/$categoryId';

  static const String member = '/Member';

  static const String paymentMethods = '/Payment/PaymentMethods';
  static const String paymentProviders = '/Payment/PaymentProviders';

  static const String checkout = '/Checkout';
  static const String checkoutComputeFees = '/Checkout/ComputeFees';

  static const String paymentCreate = '/Payment/CreatePayment';
  static const String paymentCallback = '/Payment/Callback';
  static String paymentByTransaction(String transactionId) => '/Payment/$transactionId';
  static String paymentStatusByRef(String refNo) => '/Payment/Status/$refNo';

  // Location APIs
  static const String locationCountries = '/Location/Countries';
  static String locationProvinces(String country) => '/Location/Provinces/$country';
  static String locationCities(String country, String province) => '/Location/Cities/$country/$province';
  static String locationBarangays(String country, String province, String city) => '/Location/Barangays/$country/$province/$city';

  // Address APIs
  static const String address = '/Address';
  static String addressById(int autoId) => '/Address/$autoId';
  static String addressDefault(int autoId) => '/Address/$autoId/default';

  // Orders APIs
  static const String orders = '/Orders';
  static String orderByRefNo(String refNo) => '/Orders/$refNo';
  static String orderHistoryByRefNo(String refNo) => '/Orders/$refNo/History';

  // Product Review APIs
  static const String productReviewCreate = '/ProductReview/Create';
  static String productReviewsByCode(String productCode) => '/ProductReview/$productCode';

  // Wishlist APIs
  static const String wishlist = '/Wishlist';
  static String wishlistByProductCode(String productCode) => '/Wishlist/$productCode';
  static String wishlistCheck(String productCode) => '/Wishlist/Check/$productCode';

  // Wallet APIs
  static const String walletBalance = '/Wallet/Balance';
  static const String walletValidateOrder = '/Wallet/ValidateOrder';
  static const String walletPayOrder = '/Wallet/PayOrder';
  static String walletTransaction(String tranno) => '/Wallet/Transaction/$tranno';

  // Fulfillment APIs
  static const String fulfillmentTypes = '/FulfillmentTypes';
  static const String branches = '/Branches';
}
