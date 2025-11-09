import 'dart:convert';


class UserModel {
  final String userId;
  final String name;
  final String emailId;
  final String phoneNumber;
  final String address;
  final List<Map<String, String>> emergencyContacts;
  final String? profilePicture;
  final bool isVolunteer;
  final Map<String, double>? currentLocation;
  final bool isSafe;

  UserModel({
    required this.userId,
    required this.name,
    required this.emailId,
    required this.phoneNumber,
    required this.address,
    this.emergencyContacts = const [],
    this.profilePicture,
    this.isVolunteer = false,
    this.currentLocation,
    required this.isSafe,
  });

  /// Converts object to Map (for Firestore / JSON)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'emailId': emailId,
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContacts': emergencyContacts,
      'profilePicture': profilePicture,
      'isVolunteer': isVolunteer,
      'currentLocation': currentLocation,
      'isSafe': isSafe,
    };
  }

  /// Creates an instance from Map (from Firestore / JSON)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      emailId: map['emailId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      emergencyContacts: (map['emergencyContacts'] != null)
          ? List<Map<String, String>>.from(
              (map['emergencyContacts'] as List).map(
                (e) => Map<String, String>.from(e),
              ),
            )
          : [],
      profilePicture: map['profilePicture'],
      isVolunteer: map['isVolunteer'] ?? false,
      currentLocation: map['currentLocation'] != null
          ? Map<String, double>.from(
              (map['currentLocation'] as Map).map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ),
            )
          : null,
      isSafe: map['isSafe'] ?? true,
    );
  }

  /// Converts to JSON string
  String toJson() => jsonEncode(toMap());

  /// Creates object from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source));

  /// Returns a modified copy of the user
  UserModel copyWith({
    String? userId,
    String? name,
    String? emailId,
    String? phoneNumber,
    String? address,
    List<Map<String, String>>? emergencyContacts,
    String? profilePicture,
    bool? isVolunteer,
    Map<String, double>? currentLocation,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      emailId: emailId ?? this.emailId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      profilePicture: profilePicture ?? this.profilePicture,
      isVolunteer: isVolunteer ?? this.isVolunteer,
      currentLocation: currentLocation ?? this.currentLocation,
      isSafe: isSafe,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, userId: $userId, email: $emailId, phone: $phoneNumber, isVolunteer: $isVolunteer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.userId == userId &&
        other.name == name &&
        other.emailId == emailId &&
        other.phoneNumber == phoneNumber &&
        other.address == address &&
        other.profilePicture == profilePicture &&
        other.isVolunteer == isVolunteer &&
        other.emergencyContacts == emergencyContacts &&
        other.currentLocation == currentLocation;
  }

  @override
  int get hashCode => Object.hash(
        userId,
        name,
        emailId,
        phoneNumber,
        address,
        profilePicture,
        isVolunteer,
        emergencyContacts,
        currentLocation,
      );
}
