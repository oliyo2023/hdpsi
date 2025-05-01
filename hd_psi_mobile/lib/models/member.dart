class Member {
  final int id;
  final String name;
  final String phone;
  final String gender;
  final String? birthday;
  final String email;
  final String address;
  final String level;
  final int points;
  final double totalSpent;
  final String? lastPurchaseDate;
  
  // 体型数据
  final int? bodyHeight;
  final int? bodyWeight;
  final int? shoulderWidth;
  final int? bustSize;
  final int? waistSize;
  final int? hipSize;
  final int? inseam;
  
  // 偏好数据
  final String? stylePreference;
  final String? favoriteColors;
  final String? favoriteCategories;
  final String? consumptionLevel;
  
  final String note;
  final String createdAt;
  final String updatedAt;
  
  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    this.birthday,
    required this.email,
    required this.address,
    required this.level,
    required this.points,
    required this.totalSpent,
    this.lastPurchaseDate,
    this.bodyHeight,
    this.bodyWeight,
    this.shoulderWidth,
    this.bustSize,
    this.waistSize,
    this.hipSize,
    this.inseam,
    this.stylePreference,
    this.favoriteColors,
    this.favoriteCategories,
    this.consumptionLevel,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['ID'],
      name: json['Name'],
      phone: json['Phone'],
      gender: json['Gender'] ?? '',
      birthday: json['Birthday'],
      email: json['Email'] ?? '',
      address: json['Address'] ?? '',
      level: json['Level'],
      points: json['Points'] ?? 0,
      totalSpent: json['TotalSpent']?.toDouble() ?? 0.0,
      lastPurchaseDate: json['LastPurchaseDate'],
      bodyHeight: json['BodyHeight'],
      bodyWeight: json['BodyWeight'],
      shoulderWidth: json['ShoulderWidth'],
      bustSize: json['BustSize'],
      waistSize: json['WaistSize'],
      hipSize: json['HipSize'],
      inseam: json['Inseam'],
      stylePreference: json['StylePreference'],
      favoriteColors: json['FavoriteColors'],
      favoriteCategories: json['FavoriteCategories'],
      consumptionLevel: json['ConsumptionLevel'],
      note: json['Note'] ?? '',
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
      'Phone': phone,
      'Gender': gender,
      'Birthday': birthday,
      'Email': email,
      'Address': address,
      'Level': level,
      'Points': points,
      'TotalSpent': totalSpent,
      'LastPurchaseDate': lastPurchaseDate,
      'BodyHeight': bodyHeight,
      'BodyWeight': bodyWeight,
      'ShoulderWidth': shoulderWidth,
      'BustSize': bustSize,
      'WaistSize': waistSize,
      'HipSize': hipSize,
      'Inseam': inseam,
      'StylePreference': stylePreference,
      'FavoriteColors': favoriteColors,
      'FavoriteCategories': favoriteCategories,
      'ConsumptionLevel': consumptionLevel,
      'Note': note,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    };
  }
}
