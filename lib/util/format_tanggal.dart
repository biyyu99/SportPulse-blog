// Fungsi sederhana buat ubah tanggal dari database jadi lebih enak dibaca.
// Contoh input dari backend: "2026-09-13T10:24:00.000Z" (format ISO)
// Contoh output: "2026-09-13 10:24"
String formatTanggal(String? tanggal) {
  if (tanggal == null || tanggal.isEmpty) {
    return '-';
  }
  // Ganti huruf 'T' jadi spasi, biar lebih enak dibaca
  String hasil = tanggal.replaceFirst('T', ' ');
  // Ambil 16 karakter pertama saja (tanggal + jam:menit), buang detik
  if (hasil.length >= 16) {
    return hasil.substring(0, 16);
  }
  return hasil;
}