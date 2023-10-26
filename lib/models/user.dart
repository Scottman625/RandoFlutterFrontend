Map<String, String> genders = {
  'm': 'Male',
  'f': 'Female',
};

class User {
  final int id;
  final String name;
  final String image;
  final String gender;
  final String phone;
  final int age;
  final String career;
  final String aboutMe;
  int totalLikesCount;
  String otherSideImageUrl;

  User({
    required this.id,
    required this.name,
    required this.image,
    required this.gender,
    required this.phone,
    required this.age,
    required this.career,
    required this.aboutMe,
    required this.totalLikesCount,
    required this.otherSideImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'gender': gender,
      'phone': phone,
      'age': age,
      'career': career,
      'aboutMe': aboutMe,
      'totalLikesCount': totalLikesCount,
      'otherSideImageUrl': otherSideImageUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? json['username'],
      image: json['image'] ?? '',
      gender: json['gender'],
      phone: json['phone'],
      age: json['age'] ?? 18,
      career: json['career'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      totalLikesCount: json['totalLikesCount'] ?? 0,
      otherSideImageUrl: json['otherSideImageUrl'] ?? '',
    );
  }
}

class UserImage {
  final int id;
  final int userId;
  final String image;

  UserImage({
    required this.id,
    required this.userId,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'image': image,
    };
  }

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      id: json['userImage']['id'],
      userId: json['userImage']['user']['id'],
      image: json['userImage']['imageUrl'] ?? json['userImage']['image'],
    );
  }
}
