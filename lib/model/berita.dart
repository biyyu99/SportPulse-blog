
class Berita {
  final int id;
  final String judul; 
  final String konten; 
  final String penulis; 
  final String? editor; 
  final int? idKategori; 
  final String? namaKategori; 
  final String? dibuatPada; 
  final String? diperbaruiPada; 

  Berita({
    required this.id,
    required this.judul,
    required this.konten,
    required this.penulis,
    this.editor,
    this.idKategori,
    this.namaKategori,
    this.dibuatPada,
    this.diperbaruiPada,
  });


  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: json['id'],
      judul: json['title'] ?? '',
      konten: json['content'] ?? '',
      penulis: json['author'] ?? '',
      editor: json['editor'],
      idKategori: json['category_id'],
      namaKategori: json['category_name'],
      dibuatPada: json['created_at']?.toString(),
      diperbaruiPada: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': judul,
      'content': konten,
      'author': penulis,
      'editor': editor,
      'category_id': idKategori,
      'created_at': dibuatPada,
      'updated_at': diperbaruiPada,
    };
  }
}