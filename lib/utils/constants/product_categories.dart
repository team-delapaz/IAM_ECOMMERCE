/// Product category IDs and names matching the API.
/// Use these when calling ApiMiddleware.products.getProductsByCategory(id).
class ProductCategories {
  ProductCategories._();

  //static const int iamPackages = 1;
  static const int amazingBarley = 2;
  //static const int awesomeBeautyProducts = 3;
  static const int deliciousJuiceDrinks = 4;
  static const int foodSupplements = 5;
  static const int healthyCoffee = 6;

  /// All category IDs in tab order (1-6).
  static const List<int> ids = [
    //iamPackages,
    amazingBarley,
    //awesomeBeautyProducts,
    deliciousJuiceDrinks,
    foodSupplements,
    healthyCoffee,
  ];

  static const List<String> names = [
    //'IAM Packages',
    'Amazing Barley',
    //'Awesome Beauty',
    'Delicious Juice Drinks',
    'Food Supplements',
    'Healthy Coffee',
  ];
}
