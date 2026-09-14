
class Kategori {
  final int id;
  final String nama;
  final String? dibuatPada;

  Kategori({
    required this.id,
    required this.nama,
    this.dibuatPada,
  });

  
  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      nama: json['name'] ?? '',
      dibuatPada: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nama,
    };
  }

  @override
  String toString() => 'Kategori(id: $id, nama: $nama)';
}