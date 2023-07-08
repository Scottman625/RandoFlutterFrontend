Map<String, String> genders = {
  'm': 'Male',
  'f': 'Female',
};

class User {
  final String name;
  final String image;
  final String gender;
  final String phone;
  final int age;
  final String career;
  final String about_me;

  User({
    required this.name,
    required this.image,
    required this.gender,
    required this.phone,
    required this.age,
    required this.career,
    required this.about_me,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      image: json['imageUrl'],
      gender: json['gender'],
      phone: json['phone'],
      age: json['age'] ?? 18,
      career: json['career'] ?? '',
      about_me: json['about_me'] ?? '',
    );
  }
}
