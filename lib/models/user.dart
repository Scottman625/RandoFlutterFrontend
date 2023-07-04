Map<String, String> genders = {
  'm': 'Male',
  'f': 'Female',
};

class User {
  final String id;
  final String name;
  final String image;
  final String gender;

  User(
      {required this.id,
      required this.name,
      required this.image,
      required this.gender});
}
