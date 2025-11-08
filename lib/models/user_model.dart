class UserModel {
  final String userId;
  final String name;
  final String emailId;
  final String phoneNumber;
  final String address;
  final List<Map<String, String>> emergencyContacts; // up to 5
  final String? profilePicture;
  final bool isVolunteer;
  final Map<String, double>? currentLocation; // {latitude, longitude}

  UserModel({
    required this.userId,
    required this.name,
    required this.emailId,
    required this.phoneNumber,
    required this.address,
    required this.emergencyContacts,
    this.profilePicture,
    this.isVolunteer = false,
    this.currentLocation,
  });

  /// Convert UserModel -> Map (for local storage or API)
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
    };
  }

  /// Convert Map -> UserModel (from local or API)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      emailId: map['emailId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      emergencyContacts: List<Map<String, String>>.from(
        (map['emergencyContacts'] ?? []).map(
          (e) => Map<String, String>.from(e),
        ),
      ),
      profilePicture: map['profilePicture'],
      isVolunteer: map['isVolunteer'] ?? false,
      currentLocation: map['currentLocation'] != null
          ? Map<String, double>.from(
              (map['currentLocation'] as Map).map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ),
            )
          : null,
    );
  }

  /// Convert UserModel -> JSON string
  String toJson() => toMap().toString();

  /// Copy an existing UserModel with modifications
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
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, userId: $userId, email: $emailId, phone: $phoneNumber, isVolunteer: $isVolunteer)';
  }
}
