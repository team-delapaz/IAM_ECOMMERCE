/// `orderStatusId` values from the Orders API (`/Order`).
abstract final class OrderStatusIds {
  static const int pending = 1;
  static const int verified = 2;
  static const int readyToShip = 3;
  static const int inTransit = 4;
  static const int delivered = 5;
  static const int cancelled = 6;
  static const int failedDelivery = 7;
  static const int returned = 8;
  static const int lostAndDamaged = 10;
}
