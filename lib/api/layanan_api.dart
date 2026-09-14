import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/kategori.dart';
import '../model/berita.dart';

class LayananApi {
 
  // - buat android         -> http://10.0.2.2:3000
  // - buat iOS / Chrome    -> http://localhost:3000
  // - HP fisik (satu jaringan) -> http://<IP_LOKAL_KOMPUTER>:3000
  static const String baseUrl = "http://localhost:3000";

  final Map<String, String> _headers = {"Content-Type": "application/json"};


  Future<List<Kategori>> ambilKategori() async {
    final res = await http.get(Uri.parse("$baseUrl/categories"));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Kategori.fromJson(e)).toList();
    }
    throw Exception("Gagal mengambil kategori (${res.statusCode})");
  }

  Future<Kategori> buatKategori(String nama) async {
    final res = await http.post(
      Uri.parse("$baseUrl/categories"),
      headers: _headers,
      body: jsonEncode({"name": nama}),
    );
    if (res.statusCode == 201) {
      return Kategori.fromJson(jsonDecode(res.body));
    }
    throw Exception("Gagal membuat kategori (${res.statusCode})");
  }

  
  Future<List<Berita>> ambilBerita() async {
    final res = await http.get(Uri.parse("$baseUrl/posts"));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Berita.fromJson(e)).toList();
    }
    throw Exception("Gagal mengambil daftar berita (${res.statusCode})");
  }

  
  Future<Berita> ambilDetailBerita(int id) async {
    final res = await http.get(Uri.parse("$baseUrl/posts/$id"));
    if (res.statusCode == 200) {
      return Berita.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 404) {
      throw Exception("Berita tidak ditemukan");
    }
    throw Exception("Gagal mengambil detail berita (${res.statusCode})");
  }

  
  Future<void> buatBerita({
    required String judul,
    required String konten,
    required String penulis,
    int? idKategori,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/posts"),
      headers: _headers,
      body: jsonEncode({
        "title": judul,
        "content": konten,
        "author": penulis,
        "category_id": idKategori,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception("Gagal membuat berita (${res.statusCode})");
    }
  }

  
  Future<void> updateBerita({
    required int id,
    required String judul,
    required String konten,
    required String editor,
    int? idKategori,
  }) async {
    final res = await http.put(
      Uri.parse("$baseUrl/posts/$id"),
      headers: _headers,
      body: jsonEncode({
        "title": judul,
        "content": konten,
        "editor": editor,
        "category_id": idKategori,
        "confirm": true,
      }),
    );
    if (res.statusCode != 200) {
      String pesan = "Gagal mengedit berita (${res.statusCode})";
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] != null) {
          pesan = "Gagal mengedit berita: ${body['message']}";
        } else {
          pesan = "Gagal mengedit berita (${res.statusCode}): ${res.body}";
        }
      } catch (_) {
        
        pesan = "Gagal mengedit berita (${res.statusCode}): ${res.body}";
      }
      throw Exception(pesan);
    }
  }


  Future<void> hapusBerita(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/posts/$id"));
    if (res.statusCode != 200) {
      throw Exception("Gagal menghapus berita (${res.statusCode})");
    }
  }
}