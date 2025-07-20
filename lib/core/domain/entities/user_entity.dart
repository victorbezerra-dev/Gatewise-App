class User {
  final String id;
  final String name;
  final String email;
  final String registrationNumber;
  final String userAvatarUrl;
  final int userType;
  final String operationalSystem;
  final String operationalSystemVersion;
  final String deviceModel;
  final String deviceManufactureName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.registrationNumber,
    required this.userAvatarUrl,
    required this.userType,
    required this.operationalSystem,
    required this.operationalSystemVersion,
    required this.deviceModel,
    required this.deviceManufactureName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    registrationNumber: json['registrationNumber'],
    userAvatarUrl: json['userAvatarUrl'] ?? '',
    userType: json['userType'],
    operationalSystem: json['operationalSystem'] ?? '',
    operationalSystemVersion: json['operationalSystemVersion'] ?? '',
    deviceModel: json['deviceModel'] ?? '',
    deviceManufactureName: json['deviceManufactureName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'registrationNumber': registrationNumber,
    'userAvatarUrl': userAvatarUrl,
    'userType': userType,
    'operationalSystem': operationalSystem,
    'operationalSystemVersion': operationalSystemVersion,
    'deviceModel': deviceModel,
    'deviceManufactureName': deviceManufactureName,
  };
}
