import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:latihan_baru/main.dart';

void main() {
  testWidgets('Halaman daftar berita tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Berita Olahraga'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}