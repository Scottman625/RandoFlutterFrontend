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
  final String about_me;
  int total_likes_count;
  String other_side_image_url;

  User({
    required this.id,
    required this.name,
    required this.image,
    required this.gender,
    required this.phone,
    required this.age,
    required this.career,
    required this.about_me,
    required this.total_likes_count,
    required this.other_side_image_url,
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
      'about_me': about_me,
      'total_likes_count': total_likes_count,
      'other_side_image_url': other_side_image_url,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? '',
      gender: json['gender'],
      phone: json['phone'],
      age: json['age'] ?? 18,
      career: json['career'] ?? '',
      about_me: json['about_me'] ?? '',
      total_likes_count: json['total_likes_count'] ?? 0,
      other_side_image_url: json['other_side_image_url'] ?? '',
    );
  }
}

class UserImage {
  final int id;
  final int user_id;
  final String image;

  UserImage({
    required this.id,
    required this.user_id,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user_id,
      'image': image,
    };
  }

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      id: json['id'],
      user_id: json['user'],
      image: json['imageUrl'] ?? '',
    );
  }
}
