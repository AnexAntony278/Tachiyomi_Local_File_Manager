import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf_to_tach/src/from_card.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(const PDFConverter());
}

class PDFConverter extends StatefulWidget {
  const PDFConverter({super.key});
  @override
  State<PDFConverter> createState() => _PDFConverterState();
}

class _PDFConverterState extends State<PDFConverter> {
  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    return MaterialApp(
        home: SafeArea(
            child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('PDF to Tachiyomi converter'),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.book,
              size: _width * .4,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: FormCard(width: _width),
            ),
          ],
        ),
      ),
    )));
  }
}

requestPermissions() async {
  try {
    await Permission.manageExternalStorage.request();
    debugPrint(
        '\n manageExternalStorage:${await Permission.manageExternalStorage.status.then((value) => value.name)} ');
  } catch (e) {
    debugPrint(e.toString());
  }
}
