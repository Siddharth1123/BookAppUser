
class BaseModel {
  final String id;
  final List<dynamic> imageUrl;
  final String name;
  final double price;
  final List<dynamic> size;
  final String desc;
    int value;

  BaseModel( {
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.size,
    required this.desc,
    required this.value
  });
}
