class UserModel {
  String uid;
  String name;
  String email;
  String phoneNumber;
  String imageUrl;
  String gender;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
    required this.gender,
  });

  // Convert a UserModel into a Map. The keys must correspond to the names of the
  // fields in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'gender': gender,
    };
  }

  // Create a UserModel from a Map. The keys must correspond to the names of the
  // fields in Firestore.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      gender: map['gender'] ?? '',
    );
  }
}
