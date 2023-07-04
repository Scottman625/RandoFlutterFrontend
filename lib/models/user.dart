Map<String, String> genders = {
  'm': 'Male',
  'f': 'Female',
};

class User {
  final String name;
  final String image;
  final String gender;

  User({required this.name, required this.image, required this.gender});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      image: json['imageUrl'],
      gender: json['gender'],
    );
  }
}
