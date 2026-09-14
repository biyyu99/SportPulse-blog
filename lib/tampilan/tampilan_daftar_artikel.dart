import 'package:flutter/material.dart';
import '../model/berita.dart';
import '../api/layanan_api.dart';
import '../util/format_tanggal.dart';
import 'tampilan_form_artikel.dart';

class TampilanDaftarArtikel extends StatefulWidget {
  const TampilanDaftarArtikel({super.key});

  @override
  State<TampilanDaftarArtikel> createState() => _TampilanDaftarArtikelState();
}

class _TampilanDaftarArtikelState extends State<TampilanDaftarArtikel> {
  final LayananApi _api = LayananApi();
  late Future<List<Berita>> _futureBerita;
  String? _filterKategori;

  @override
  void initState() {
    super.initState();
    _muatBerita();
  }

  void _muatBerita() {
    setState(() {
      _futureBerita = _api.ambilBerita();
    });
  }

  Future<void> _hapusBerita(int id) async {
    await _api.hapusBerita(id);
    _muatBerita();
  }

  void _bukaDetail(Berita berita) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TampilanDetailArtikel(berita: berita),
      ),
    );
  }

  void _bukaForm({Berita? berita}) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TampilanFormArtikel(artikel: berita),
      ),
    );
    if (hasil == true) {
      _muatBerita();
    }
  }

  String _cuplikan(String teks, {int panjang = 70}) {
    final bersih = teks.trim().replaceAll('\n', ' ');
    if (bersih.length <= panjang) return bersih;
    return '${bersih.substring(0, panjang).trimRight()}...';
  }

  Widget _chipFilter({required String label, required String? nilai}) {
    final aktif = _filterKategori == nilai;
    return GestureDetector(
      onTap: () => setState(() => _filterKategori = nilai),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: aktif ? warnaOutline.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: aktif
                ? warnaOutline
                : warnaOutline.withValues(alpha: 0.35),
            width: aktif ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: aktif ? warnaOutline : Colors.white60,
            fontSize: 13,
            fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
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
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Icon(Icons.sports_soccer, color: warnaOutline, size: 22),
            const SizedBox(width: 8),
            const Text(
              "SportPulse",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Berita>>(
        future: _futureBerita,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: warnaOutline),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final daftarBerita = snapshot.data ?? [];

          if (daftarBerita.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada berita",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          
          final daftarKategori = daftarBerita
              .map((b) => b.namaKategori)
              .whereType<String>()
              .toSet()
              .toList()
            ..sort();

          final beritaTersaring = _filterKategori == null
              ? daftarBerita
              : daftarBerita
                  .where((b) => b.namaKategori == _filterKategori)
                  .toList();

          return Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _chipFilter(label: "Semua", nilai: null),
                    const SizedBox(width: 8),
                    for (final kategori in daftarKategori) ...[
                      _chipFilter(label: kategori, nilai: kategori),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: beritaTersaring.isEmpty
                    ? const Center(
                        child: Text(
                          "Tidak ada berita di kategori ini",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : RefreshIndicator(
                        color: warnaOutline,
                        backgroundColor: Colors.black,
                        onRefresh: () async => _muatBerita(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                          itemCount: beritaTersaring.length,
                          itemBuilder: (context, index) {
                            final berita = beritaTersaring[index];

                final sudahDiedit = berita.diperbaruiPada != null &&
                    berita.diperbaruiPada != berita.dibuatPada;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D0D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: warnaOutline.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _bukaDetail(berita),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: warnaOutline.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(
                                      berita.namaKategori ?? 'Tanpa kategori',
                                      style: TextStyle(
                                        color: warnaOutline,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    berita.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    berita.penulis,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _cuplikan(berita.konten),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    sudahDiedit
                                        ? "Diedit ${formatTanggal(berita.diperbaruiPada)}"
                                        : "Dibuat ${formatTanggal(berita.dibuatPada)}",
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(Icons.edit_outlined,
                                      color: warnaOutline, size: 20),
                                  onPressed: () => _bukaForm(berita: berita),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.white38, size: 20),
                                  onPressed: () => _hapusBerita(berita.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: warnaOutline,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: warnaOutline, width: 1.5),
        ),
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


class TampilanDetailArtikel extends StatelessWidget {
  final Berita berita;

  const TampilanDetailArtikel({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    final sudahDiedit =
        berita.diperbaruiPada != null && berita.diperbaruiPada != berita.dibuatPada;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Detail Berita",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: warnaOutline.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: warnaOutline.withValues(alpha: 0.5)),
              ),
              child: Text(
                berita.namaKategori ?? 'Tanpa kategori',
                style: TextStyle(
                  color: warnaOutline,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              berita.judul,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              berita.penulis,
              style: const TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 4),
            Text(
              "Dibuat: ${formatTanggal(berita.dibuatPada)}",
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            if (sudahDiedit)
              Text(
                "Diedit: ${formatTanggal(berita.diperbaruiPada)}"
                "${berita.editor != null && berita.editor!.isNotEmpty ? ' oleh ${berita.editor}' : ''}",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            Divider(color: warnaOutline.withValues(alpha: 0.4), height: 32),
            Text(
              berita.konten,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}