import 'package:flutter/material.dart';
import '../model/berita.dart';
import '../model/kategori.dart';
import '../api/layanan_api.dart';


const Color warnaOutline = Color.fromARGB(255, 255, 0, 0);
class TampilanFormArtikel extends StatefulWidget {
  final Berita? artikel;

  const TampilanFormArtikel({super.key, this.artikel});

  @override
  State<TampilanFormArtikel> createState() => _TampilanFormArtikelState();
}

class _TampilanFormArtikelState extends State<TampilanFormArtikel> {
  final _formKey = GlobalKey<FormState>();
  final _api = LayananApi();

  late TextEditingController _judulCtrl;
  late TextEditingController _kontenCtrl;
  late TextEditingController _penulisCtrl;

  List<Kategori> _daftarKategori = [];
  int? _idKategoriTerpilih;

  bool get _modeEdit => widget.artikel != null;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.artikel?.judul ?? "");
    _kontenCtrl = TextEditingController(text: widget.artikel?.konten ?? "");
    _penulisCtrl = TextEditingController();
    _idKategoriTerpilih = widget.artikel?.idKategori;
    _muatKategori();
  }

  Future<void> _muatKategori() async {
    final data = await _api.ambilKategori();
    setState(() {
      _daftarKategori = data;
    });
  }

  // Menampilkan dialog konfirmasi, mengembalikan true jika user menekan "Yakin"
  Future<bool> _konfirmasiEdit() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Konfirmasi",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Yakin ingin mengedit berita ini?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yakin"),
          ),
        ],
      ),
    );
    return yakin == true;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kalau mode edit, tampilkan dialog konfirmasi dulu sebelum lanjut
    if (_modeEdit) {
      final yakin = await _konfirmasiEdit();
      if (!yakin) return; // user membatalkan, hentikan proses simpan
    }

    try {
      if (_modeEdit) {
        await _api.updateBerita(
          id: widget.artikel!.id,
          judul: _judulCtrl.text,
          konten: _kontenCtrl.text,
          editor: _penulisCtrl.text,
          idKategori: _idKategoriTerpilih,
        );
      } else {
        await _api.buatBerita(
          judul: _judulCtrl.text,
          konten: _kontenCtrl.text,
          penulis: _penulisCtrl.text,
          idKategori: _idKategoriTerpilih,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  
  InputDecoration _dekorasiInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: warnaOutline),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: warnaOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: warnaOutline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: warnaOutline, width: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_modeEdit ? "Edit Berita" : "Tambah Berita"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _judulCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dekorasiInput("Judul"),
                validator: (v) => v == null || v.isEmpty ? "Judul wajib diisi" : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _kontenCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dekorasiInput("Isi Berita"),
                maxLines: 6,
                validator: (v) => v == null || v.isEmpty ? "Konten wajib diisi" : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _idKategoriTerpilih,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: _dekorasiInput("Kategori"),
                items: _daftarKategori.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori.id,
                    child: Text(kategori.nama),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _idKategoriTerpilih = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _penulisCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dekorasiInput(
                  _modeEdit ? "Nama Editor" : "Nama Penulis",
                ),
                validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: warnaOutline,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: warnaOutline, width: 1.5),
                  ),
                ),
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}