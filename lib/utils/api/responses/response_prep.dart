
Map<String, dynamic>? asMap(dynamic v) =>
    v == null ? null : (v is Map<String, dynamic> ? v : Map<String, dynamic>.from(v as Map));

List<Map<String, dynamic>>? asListMap(dynamic v) {
  if (v == null) return null;
  final list = v is List ? v : [];
  return list.map((e) => asMap(e) ?? {}).toList();
}

class LoginData {
  final TokenInfo? token;
  final UserInfo? user;

  LoginData({this.token, this.user});

  static LoginData? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return LoginData(
      token: TokenInfo.fromJson(m['token']),
      user: UserInfo.fromJson(m['user']),
    );
  }
}

class TokenInfo {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  TokenInfo({required this.accessToken, this.tokenType = 'Bearer', required this.expiresIn});

  static TokenInfo? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return TokenInfo(
      accessToken: m['accessToken'] as String? ?? '',
      tokenType: m['tokenType'] as String? ?? 'Bearer',
      expiresIn: m['expiresIn'] as int? ?? 0,
    );
  }
}

class VerificationResponse {
  final bool isSent;
  final String message;

  VerificationResponse({required this.isSent, required this.message});

  static VerificationResponse? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return VerificationResponse(
      isSent: (m['isSent'] as bool?) ?? false,
      message: m['message'] as String? ?? '',
    );
  }
}

class VerifyResponse {
  final bool isVerified;
  final String message;

  VerifyResponse({required this.isVerified, required this.message});

  static VerifyResponse? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return VerifyResponse(
      isVerified: (m['isVerified'] as bool?) ?? false,
      message: m['message'] as String? ?? '',
    );
  }
}

// Product Review API Response Classes

class ProductReviewItem {
  final int autoId;
  final String productCode;
  final int rating;
  final String reviewComment;
  final String createdAt;
  final String? firstName;
  final String? lastName;

  ProductReviewItem({
    required this.autoId,
    required this.productCode,
    required this.rating,
    required this.reviewComment,
    required this.createdAt,
    this.firstName,
    this.lastName,
  });

  static ProductReviewItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return ProductReviewItem(
      autoId: (m['autoId'] as int?) ?? 0,
      productCode: m['productCode'] as String? ?? '',
      rating: (m['rating'] as int?) ?? 0,
      reviewComment: m['reviewComment'] as String? ?? '',
      createdAt: m['createdAt'] as String? ?? '',
      firstName: m['firstName'] as String?,
      lastName: m['lastName'] as String?,
    );
  }
}

// Wishlist API Response Classes

class WishlistItem {
  final String productCode;
  final String productName;
  final num sellingPrice;
  final String shortDesc;
  final String imageUrl;
  final String altText;
  final String createdAt;

  WishlistItem({
    required this.productCode,
    required this.productName,
    required this.sellingPrice,
    required this.shortDesc,
    required this.imageUrl,
    required this.altText,
    required this.createdAt,
  });

  static WishlistItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return WishlistItem(
      productCode: m['productCode'] as String? ?? '',
      productName: m['productName'] as String? ?? '',
      sellingPrice: (m['sellingPrice'] as num?) ?? 0,
      shortDesc: m['shortDesc'] as String? ?? '',
      imageUrl: m['imageUrl'] as String? ?? '',
      altText: m['altText'] as String? ?? '',
      createdAt: m['createdAt'] as String? ?? '',
    );
  }
}

class WishlistCheckItem {
  final String productCode;
  final bool isWishlisted;

  WishlistCheckItem({
    required this.productCode,
    required this.isWishlisted,
  });

  static WishlistCheckItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return WishlistCheckItem(
      productCode: m['productCode'] as String? ?? '',
      isWishlisted: (m['isWishlisted'] as bool?) ?? false,
    );
  }
}

class WalletBalanceData {
  final String accountId;
  final num balance;

  WalletBalanceData({
    required this.accountId,
    required this.balance,
  });

  static WalletBalanceData? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return WalletBalanceData(
      accountId: m['accountId'] as String? ?? '',
      balance: (m['balance'] as num?) ?? 0,
    );
  }
}

class WalletOrderPaymentData {
  final String accountId;
  final String orderRefNo;
  final String paymentRefNo;
  final num amount;
  final num remainingBalance;

  WalletOrderPaymentData({
    required this.accountId,
    required this.orderRefNo,
    required this.paymentRefNo,
    required this.amount,
    required this.remainingBalance,
  });

  static WalletOrderPaymentData? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return WalletOrderPaymentData(
      accountId: m['accountId'] as String? ?? '',
      orderRefNo: m['orderRefNo'] as String? ?? '',
      paymentRefNo: m['paymentRefNo'] as String? ?? '',
      amount: (m['amount'] as num?) ?? 0,
      remainingBalance: (m['remainingBalance'] as num?) ?? 0,
    );
  }
}

class CheckoutData {
  final String orderRefNo;
  final String cartRefNo;
  final num subtotalAmount;
  final num shippingAmount;
  final num processingFeeAmount;
  final num voucherDiscountAmount;
  final num discountAmount;
  final num totalAmount;
  final int orderStatusId;
  final int paymentStatusId;
  final String notes;
  final List<OrderProductItem?> items;

  CheckoutData({
    required this.orderRefNo,
    required this.cartRefNo,
    required this.subtotalAmount,
    required this.shippingAmount,
    required this.processingFeeAmount,
    required this.voucherDiscountAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.orderStatusId,
    required this.paymentStatusId,
    required this.notes,
    required this.items,
  });

  static CheckoutData? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    final itemsList = (m['items'] is List ? (m['items'] as List) : const [])
        .map((e) => OrderProductItem.fromJson(e))
        .whereType<OrderProductItem>()
        .toList();
    return CheckoutData(
      orderRefNo: (m['orderRefNo'] as String?) ?? (m['orderRefno'] as String? ?? ''),
      cartRefNo: (m['cartRefNo'] as String?) ?? (m['cartRefno'] as String? ?? ''),
      subtotalAmount: (m['subtotalAmount'] as num?) ?? 0,
      shippingAmount: (m['shippingAmount'] as num?) ?? 0,
      processingFeeAmount: (m['processingFeeAmount'] as num?) ?? 0,
      voucherDiscountAmount: (m['voucherDiscountAmount'] as num?) ?? 0,
      discountAmount: (m['discountAmount'] as num?) ?? 0,
      totalAmount: (m['totalAmount'] as num?) ?? 0,
      orderStatusId: (m['orderStatusId'] as int?) ?? 0,
      paymentStatusId: (m['paymentStatusId'] as int?) ?? 0,
      notes: m['notes'] as String? ?? '',
      items: itemsList,
    );
  }
}

class ComputeFeesData {
  final String cartRefno;
  final num subtotalAmount;
  final num shippingAmount;
  final num processingFeeAmount;
  final num voucherDiscountAmount;
  final num discountAmount;
  final num totalAmount;
  final int totalBoxes;

  ComputeFeesData({
    required this.cartRefno,
    required this.subtotalAmount,
    required this.shippingAmount,
    required this.processingFeeAmount,
    required this.voucherDiscountAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.totalBoxes,
  });

  static ComputeFeesData? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return ComputeFeesData(
      cartRefno: (m['cartRefno'] as String?) ?? (m['cartRefNo'] as String? ?? ''),
      subtotalAmount: (m['subtotalAmount'] as num?) ?? 0,
      shippingAmount: (m['shippingAmount'] as num?) ?? 0,
      processingFeeAmount: (m['processingFeeAmount'] as num?) ?? 0,
      voucherDiscountAmount: (m['voucherDiscountAmount'] as num?) ?? 0,
      discountAmount: (m['discountAmount'] as num?) ?? 0,
      totalAmount: (m['totalAmount'] as num?) ?? 0,
      totalBoxes: (m['totalBoxes'] as int?) ?? 0,
    );
  }
}

class OrderStatusHistoryItem {
  final int autoId;
  final String orderRefNo;
  final int orderStatusId;
  final String orderStatusName;
  final String trackingNo;
  final String remarks;
  final String userName;
  final String tranDate;

  OrderStatusHistoryItem({
    required this.autoId,
    required this.orderRefNo,
    required this.orderStatusId,
    required this.orderStatusName,
    required this.trackingNo,
    required this.remarks,
    required this.userName,
    required this.tranDate,
  });

  static OrderStatusHistoryItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return OrderStatusHistoryItem(
      autoId: (m['autoId'] as int?) ?? 0,
      orderRefNo: m['orderRefNo'] as String? ?? '',
      orderStatusId: (m['orderStatusId'] as int?) ?? 0,
      orderStatusName: m['orderStatusName'] as String? ?? '',
      trackingNo: m['trackingNo'] as String? ?? '',
      remarks: m['remarks'] as String? ?? '',
      userName: m['userName'] as String? ?? '',
      tranDate: m['tranDate'] as String? ?? '',
    );
  }
}

class UserInfo {
  final String idno;
  final String codedIdno;
  final String firstName;
  final String lastName;
  final String fullName;
  final String packageCode;
  final String packageName;
  final bool isMember;

  UserInfo({
    required this.idno,
    required this.codedIdno,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.packageCode,
    required this.packageName,
    required this.isMember,
  });

  static UserInfo? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return UserInfo(
      idno: m['idno'] as String? ?? '',
      codedIdno: m['codedIdno'] as String? ?? '',
      firstName: m['firstName'] as String? ?? '',
      lastName: m['lastName'] as String? ?? '',
      fullName: m['fullName'] as String? ?? '',
      packageCode: m['packageCode'] as String? ?? '',
      packageName: m['packageName'] as String? ?? '',
      isMember: m['isMember'] as bool? ?? false,
    );
  }
}

class ProductItem {
  final int categoryId;
  final String categoryName;
  final String productCode;
  final String productName;
  final num regularPrice;
  final num memberPrice;
  final String shortDesc;
  final String longDesc;
  final bool isActive;
  final bool isFeatured;
  final bool isPopular;
  final String imageUrl;
  final String altText;

  ProductItem({
    required this.categoryId,
    required this.categoryName,
    required this.productCode,
    required this.productName,
    required this.regularPrice,
    required this.memberPrice,
    required this.shortDesc,
    required this.longDesc,
    required this.isActive,
    required this.isFeatured,
    required this.isPopular,
    required this.imageUrl,
    required this.altText,
  });

  static ProductItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return ProductItem(
      categoryId: (m['categoryId'] as int?) ?? 0,
      categoryName: m['categoryName'] as String? ?? '',
      productCode: m['productCode'] as String? ?? '',
      productName: m['productName'] as String? ?? '',
      regularPrice: (m['regularPrice'] as num?) ?? 0,
      memberPrice: (m['memberPrice'] as num?) ?? 0,
      shortDesc: m['shortDesc'] as String? ?? '',
      longDesc: m['longDesc'] as String? ?? '',
      isActive: m['isActive'] as bool? ?? false,
      isFeatured: m['isFeatured'] as bool? ?? false,
      isPopular: m['isPopular'] as bool? ?? false,
      imageUrl: m['imageUrl'] as String? ?? '',
      altText: m['altText'] as String? ?? '',
    );
  }
}


class CartPayload {
  final String refNo;
  final String idno;
  final List<CartItem> items;
  final num subtotal;
  final int totalQty;
  final String currencyCode;

  CartPayload({
    required this.refNo,
    required this.idno,
    required this.items,
    required this.subtotal,
    required this.totalQty,
    required this.currencyCode,
  });

  static CartPayload? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    final items = (m['items'] is List ? (m['items'] as List) : const [])
        .map((e) => CartItem.fromJson(e))
        .whereType<CartItem>()
        .toList();
    return CartPayload(
      refNo: m['refNo'] as String? ?? '',
      idno: m['idno'] as String? ?? '',
      items: items,
      subtotal: (m['subtotal'] as num?) ?? 0,
      totalQty: (m['totalQty'] as int?) ?? 0,
      currencyCode: m['currencyCode'] as String? ?? '',
    );
  }
}

class CartItem {
  final String refNo;
  final String idno;
  final String productCode;
  final String productName;
  final int qty;
  final num regularPrice;
  final num sellingPrice;
  final num lineTotal;
  final String currencyCode;
  final String imageUrl;
  final String altText;

  CartItem({
    required this.refNo,
    required this.idno,
    required this.productCode,
    required this.productName,
    required this.qty,
    required this.regularPrice,
    required this.sellingPrice,
    required this.lineTotal,
    required this.currencyCode,
    required this.imageUrl,
    required this.altText,
  });

  static CartItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return CartItem(
      refNo: m['refNo'] as String? ?? '',
      idno: m['idno'] as String? ?? '',
      productCode: m['productCode'] as String? ?? '',
      productName: m['productName'] as String? ?? '',
      qty: (m['qty'] as int?) ?? 0,
      regularPrice: (m['regularPrice'] as num?) ?? 0,
      sellingPrice: (m['sellingPrice'] as num?) ?? 0,
      lineTotal: (m['lineTotal'] as num?) ?? 0,
      currencyCode: m['currencyCode'] as String? ?? '',
      imageUrl: m['imageUrl'] as String? ?? '',
      altText: m['altText'] as String? ?? '',
    );
  }
}

class MemberPayload {
  final String idno;
  final String firstName;
  final String lastName;
  final String middleName;
  final String membershipDate;
  final String packageCode;
  final String packageName;
  final String mobileNo;
  final String emailAddress;
  final String homeAddress;
  final String country;

  MemberPayload({
    required this.idno,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.membershipDate,
    required this.packageCode,
    required this.packageName,
    required this.mobileNo,
    required this.emailAddress,
    required this.homeAddress,
    required this.country,
  });

  static MemberPayload? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return MemberPayload(
      idno: m['idno'] as String? ?? '',
      firstName: m['firstName'] as String? ?? '',
      lastName: m['lastName'] as String? ?? '',
      middleName: m['middleName'] as String? ?? '',
      membershipDate: (m['membeshipDate'] as String?) ?? (m['membershipDate'] as String? ?? ''),
      packageCode: m['packageCode'] as String? ?? '',
      packageName: m['packageName'] as String? ?? '',
      mobileNo: m['mobileNo'] as String? ?? '',
      emailAddress: m['emailAddress'] as String? ?? '',
      homeAddress: m['homeAddress'] as String? ?? '',
      country: m['country'] as String? ?? '',
    );
  }
}

class PaymentMethodItem {
  final int paymentMethodId;
  final String methodCode;
  final String methodName;
  final bool isInternal;
  final bool requiresRedirect;
  final int sortOrder;
  final bool isActive;

  PaymentMethodItem({
    required this.paymentMethodId,
    required this.methodCode,
    required this.methodName,
    required this.isInternal,
    required this.requiresRedirect,
    required this.sortOrder,
    required this.isActive,
  });

  static PaymentMethodItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return PaymentMethodItem(
      paymentMethodId: (m['paymentMethodId'] as int?) ?? 0,
      methodCode: m['methodCode'] as String? ?? '',
      methodName: m['methodName'] as String? ?? '',
      isInternal: (m['isInternal'] as bool?) ?? false,
      requiresRedirect: (m['requiresRedirect'] as bool?) ?? false,
      sortOrder: (m['sortOrder'] as int?) ?? 0,
      isActive: (m['isActive'] as bool?) ?? false,
    );
  }
}

class PaymentProviderItem {
  final int autoId;
  final String providerCode;
  final String providerName;
  final bool isActive;
  final int sortOrder;

  PaymentProviderItem({
    required this.autoId,
    required this.providerCode,
    required this.providerName,
    required this.isActive,
    required this.sortOrder,
  });

  static PaymentProviderItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return PaymentProviderItem(
      autoId: (m['autoId'] as int?) ?? 0,
      providerCode: m['providerCode'] as String? ?? '',
      providerName: m['providerName'] as String? ?? '',
      isActive: (m['isActive'] as bool?) ?? false,
      sortOrder: (m['sortOrder'] as int?) ?? 0,
    );
  }
}

class PaymentData {
  final String paymentTxnId;
  final String orderNo;
  final String idno;
  final num amount;
  final String currency;
  final int paymentStatusId;
  final String paymentStatusMessage;
  final String paymentProvider;
  final String paymentMethod;
  final String providerReferenceNumber;
  final String checkoutUrl;

  PaymentData({
    required this.paymentTxnId,
    required this.orderNo,
    required this.idno,
    required this.amount,
    required this.currency,
    required this.paymentStatusId,
    required this.paymentStatusMessage,
    required this.paymentProvider,
    required this.paymentMethod,
    required this.providerReferenceNumber,
    required this.checkoutUrl,
  });

  static PaymentData? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return PaymentData(
      paymentTxnId: m['paymentTxnId'] as String? ?? '',
      orderNo: m['orderNo'] as String? ?? '',
      idno: m['idno'] as String? ?? '',
      amount: (m['amount'] as num?) ?? 0,
      currency: m['currency'] as String? ?? '',
      paymentStatusId: (m['paymentStatusId'] as int?) ?? 0,
      paymentStatusMessage: m['paymentStatusMessage'] as String? ?? '',
      paymentProvider: m['paymentProvider'] as String? ?? '',
      paymentMethod: m['paymentMethod'] as String? ?? '',
      providerReferenceNumber: m['providerReferenceNumber'] as String? ?? '',
      checkoutUrl: m['checkoutUrl'] as String? ?? '',
    );
  }
}

// Address API Response Classes

class AddressItem {
  final int autoId;
  final String idNo;
  final String recipientName;
  final String mobileNo;
  final String country;
  final String province;
  final String city;
  final String barangay;
  final String streetAddress;
  final String postalCode;
  final String completeAddress;
  final bool isDefault;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  AddressItem({
    required this.autoId,
    required this.idNo,
    required this.recipientName,
    required this.mobileNo,
    required this.country,
    required this.province,
    required this.city,
    required this.barangay,
    required this.streetAddress,
    required this.postalCode,
    required this.completeAddress,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  static AddressItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return AddressItem(
      autoId: (m['autoId'] as int?) ?? 0,
      idNo: m['idNo'] as String? ?? '',
      recipientName: m['recipientName'] as String? ?? '',
      mobileNo: m['mobileNo'] as String? ?? '',
      country: m['country'] as String? ?? '',
      province: m['province'] as String? ?? '',
      city: m['city'] as String? ?? '',
      barangay: m['barangay'] as String? ?? '',
      streetAddress: m['streetAddress'] as String? ?? '',
      postalCode: m['postalCode'] as String? ?? '',
      completeAddress: m['completeAddress'] as String? ?? '',
      isDefault: (m['isDefault'] as bool?) ?? false,
      isActive: (m['isActive'] as bool?) ?? false,
      createdAt: m['createdAt'] as String? ?? '',
      updatedAt: m['updatedAt'] as String?,
    );
  }
}

// Orders API Response Classes

class OrderItem {
  final String orderRefno;
  final String orderDate;
  final num totalAmount;
  final int orderStatusId;
  final String orderStatusName;
  final int paymentStatusId;
  final String paymentStatusName;
  final int itemCount;
  final String paymentProvider;
  final String imageUrl;

  OrderItem({
    required this.orderRefno,
    required this.orderDate,
    required this.totalAmount,
    required this.orderStatusId,
    required this.orderStatusName,
    required this.paymentStatusId,
    required this.paymentStatusName,
    required this.itemCount,
    required this.paymentProvider,
    required this.imageUrl,
  });

  static OrderItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return OrderItem(
      orderRefno: m['orderRefno'] as String? ?? '',
      orderDate: m['orderDate'] as String? ?? '',
      totalAmount: (m['totalAmount'] as num?) ?? 0,
      orderStatusId: (m['orderStatusId'] as int?) ?? 0,
      orderStatusName: m['orderStatusName'] as String? ?? '',
      paymentStatusId: (m['paymentStatusId'] as int?) ?? 0,
      paymentStatusName: m['paymentStatusName'] as String? ?? '',
      itemCount: (m['itemCount'] as int?) ?? 0,
      paymentProvider: m['paymentProvider'] as String? ?? '',
      imageUrl: m['imageUrl'] as String? ?? '',
    );
  }
}

class OrderDetailItem {
  final String orderRefno;
  final String cartRefno;
  final String orderDate;
  final num subtotalAmount;
  final num shippingAmount;
  final num voucherDiscountAmount;
  final num discountAmount;
  final num totalAmount;
  final int orderStatusId;
  final String orderStatusName;
  final int paymentStatusId;
  final String paymentStatusName;
  final String paymentProvider;
  final String paymentMethod;
  final String paymentStatusMessage;
  final String gatewayReference;
  final String checkoutUrl;
  final ShippingInfo? shippingInfo;
  final List<OrderProductItem?> items;

  OrderDetailItem({
    required this.orderRefno,
    required this.cartRefno,
    required this.orderDate,
    required this.subtotalAmount,
    required this.shippingAmount,
    required this.voucherDiscountAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.orderStatusId,
    required this.orderStatusName,
    required this.paymentStatusId,
    required this.paymentStatusName,
    required this.paymentProvider,
    required this.paymentMethod,
    required this.paymentStatusMessage,
    required this.gatewayReference,
    required this.checkoutUrl,
    this.shippingInfo,
    required this.items,
  });

  static OrderDetailItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    final itemsList = (m['items'] is List ? (m['items'] as List) : const [])
        .map((e) => OrderProductItem.fromJson(e))
        .whereType<OrderProductItem>()
        .toList();
    return OrderDetailItem(
      orderRefno: m['orderRefno'] as String? ?? '',
      cartRefno: m['cartRefno'] as String? ?? '',
      orderDate: m['orderDate'] as String? ?? '',
      subtotalAmount: (m['subtotalAmount'] as num?) ?? 0,
      shippingAmount: (m['shippingAmount'] as num?) ?? 0,
      voucherDiscountAmount: (m['voucherDiscountAmount'] as num?) ?? 0,
      discountAmount: (m['discountAmount'] as num?) ?? 0,
      totalAmount: (m['totalAmount'] as num?) ?? 0,
      orderStatusId: (m['orderStatusId'] as int?) ?? 0,
      orderStatusName: m['orderStatusName'] as String? ?? '',
      paymentStatusId: (m['paymentStatusId'] as int?) ?? 0,
      paymentStatusName: m['paymentStatusName'] as String? ?? '',
      paymentProvider: m['paymentProvider'] as String? ?? '',
      paymentMethod: m['paymentMethod'] as String? ?? '',
      paymentStatusMessage: m['paymentStatusMessage'] as String? ?? '',
      gatewayReference: m['gatewayReference'] as String? ?? '',
      checkoutUrl: m['checkoutUrl'] as String? ?? '',
      shippingInfo: ShippingInfo.fromJson(m['shippingInfo']),
      items: itemsList,
    );
  }
}

class ShippingInfo {
  final String fullName;
  final String mobileNo;
  final String emailAddress;
  final String country;
  final String province;
  final String city;
  final String barangay;
  final String streetAddress;
  final String postalCode;
  final String completeAddress;
  final String notes;

  ShippingInfo({
    required this.fullName,
    required this.mobileNo,
    required this.emailAddress,
    required this.country,
    required this.province,
    required this.city,
    required this.barangay,
    required this.streetAddress,
    required this.postalCode,
    required this.completeAddress,
    required this.notes,
  });

  static ShippingInfo? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return ShippingInfo(
      fullName: m['fullName'] as String? ?? '',
      mobileNo: m['mobileNo'] as String? ?? '',
      emailAddress: m['emailAddress'] as String? ?? '',
      country: m['country'] as String? ?? '',
      province: m['province'] as String? ?? '',
      city: m['city'] as String? ?? '',
      barangay: m['barangay'] as String? ?? '',
      streetAddress: m['streetAddress'] as String? ?? '',
      postalCode: m['postalCode'] as String? ?? '',
      completeAddress: m['completeAddress'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
    );
  }
}

class OrderProductItem {
  final String productCode;
  final String productName;
  final int qty;
  final num sellingPrice;
  final num lineTotal;
  final String imageUrl;
  final String altText;

  OrderProductItem({
    required this.productCode,
    required this.productName,
    required this.qty,
    required this.sellingPrice,
    required this.lineTotal,
    required this.imageUrl,
    required this.altText,
  });

  static OrderProductItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return OrderProductItem(
      productCode: m['productCode'] as String? ?? '',
      productName: m['productName'] as String? ?? '',
      qty: (m['qty'] as int?) ?? 0,
      sellingPrice: (m['sellingPrice'] as num?) ?? 0,
      lineTotal: (m['lineTotal'] as num?) ?? 0,
      imageUrl: m['imageUrl'] as String? ?? '',
      altText: m['altText'] as String? ?? '',
    );
  }
}


class CartItemPayload {
  final String productCode;
  final int qty;

  CartItemPayload({required this.productCode, required this.qty});

  static CartItemPayload? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return CartItemPayload(
      productCode: m['productCode'] as String? ?? '',
      qty: m['qty'] as int? ?? 0,
    );
  }
}

// Location API Response Classes

class CountryItem {
  final String country;

  CountryItem({required this.country});

  static CountryItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return CountryItem(
      country: m['country'] as String? ?? '',
    );
  }
}

class ProvinceItem {
  final String province;

  ProvinceItem({required this.province});

  static ProvinceItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return ProvinceItem(
      province: m['province'] as String? ?? '',
    );
  }
}

class CityItem {
  final String city;

  CityItem({required this.city});

  static CityItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return CityItem(
      city: m['city'] as String? ?? '',
    );
  }
}

class BarangayItem {
  final String barangay;

  BarangayItem({required this.barangay});

  static BarangayItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return BarangayItem(
      barangay: m['barangay'] as String? ?? '',
    );
  }
}
