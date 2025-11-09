class MessageModel {
  final String userId;
  final String phone;
  final String? profilePicture;
  final String name;
  final String gender;
  final int age;

  final String messageId;
  final String? voiceMessage;
  final String? videoMessage;
  final DateTime timestamp;
  final List<String> txtMessage;

  final Map<String, double> location;

  MessageModel({
    required this.userId,
    required this.phone,
    this.profilePicture,
    required this.name,
    required this.gender,
    required this.age,
    required this.messageId,
    this.voiceMessage,
    this.videoMessage,
    required this.timestamp,
    required this.txtMessage,
    required this.location, //
  });

  // Convert from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      userId: json['userId'],
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      name: json['name'],
      gender: json['gender'],
      age: json['age'],
      messageId: json['messageId'],
      voiceMessage: json['voiceMessage'],
      videoMessage: json['videoMessage'],
      timestamp: DateTime.parse(json['timestamp']),
      txtMessage: List<String>.from(json['txtMessage'] ?? []),
      location: Map<String, double>.from(json['location']), //
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phone': phone,
      'profilePicture': profilePicture,
      'name': name,
      'gender': gender,
      'age': age,
      'messageId': messageId,
      'voiceMessage': voiceMessage,
      'videoMessage': videoMessage,
      'timestamp': timestamp.toIso8601String(),
      'txtMessage': txtMessage,
      'location': location,
    };
  }
}
