
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
  final String productCode;
  final String productName;
  final num regularPrice;
  final num memberPrice;
  final String shortDesc;
  final String longDesc;
  final bool isActive;
  final String imageUrl;
  final String altText;

  ProductItem({
    required this.productCode,
    required this.productName,
    required this.regularPrice,
    required this.memberPrice,
    required this.shortDesc,
    required this.longDesc,
    required this.isActive,
    required this.imageUrl,
    required this.altText,
  });

  static ProductItem? fromJson(dynamic json) {
    final m = asMap(json);
    if (m == null) return null;
    return ProductItem(
      productCode: m['productCode'] as String? ?? '',
      productName: m['productName'] as String? ?? '',
      regularPrice: (m['regularPrice'] as num?) ?? 0,
      memberPrice: (m['memberPrice'] as num?) ?? 0,
      shortDesc: m['shortDesc'] as String? ?? '',
      longDesc: m['longDesc'] as String? ?? '',
      isActive: m['isActive'] as bool? ?? false,
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
