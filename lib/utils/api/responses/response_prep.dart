/// Prep/map raw API data to typed models. Extend as more response shapes are known.

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

/// Use for Cart/Add, Cart GET, etc. when backend returns a known shape.
/// Replace or add fields once actual cart response is defined.
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
