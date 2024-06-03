import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_to_tach/themes/app_themes.dart';

class FormCard extends StatefulWidget {
  const FormCard({
    super.key,
    required double width,
  }) : _width = width;
  final double _width;

  @override
  State<FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  final TextEditingController _pdfFieldController = TextEditingController(),
      _destinationPathFieldController = TextEditingController(),
      _nameFieldController = TextEditingController();
  File? pdfFile;
  String? destinationPath = '';
  String? name;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(228, 121, 197, 255),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: widget._width * .8,
          height: widget._width * .8,
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  const Text(
                    'Select PDF file',
                    style: AppTheme.labelTextStyle,
                  ),
                  TextFormField(
                    controller: _pdfFieldController,
                    onTap: () async {
                      pdfFile = await showPDFPicker(context);
                      _pdfFieldController.text = pdfFile!.path.split('/').last;
                    },
                  ),
                  const Text(
                    'Select Destination Path ( Tachiyomi Local directory )',
                    style: AppTheme.labelTextStyle,
                  ),
                  TextFormField(
                    controller: _destinationPathFieldController,
                    onTap: () async {
                      destinationPath = await showPathPicker(context);
                      _destinationPathFieldController.text = destinationPath!;
                    },
                  ),
                  const Text(
                    'Book Name',
                    style: AppTheme.labelTextStyle,
                  ),
                  TextFormField(
                    controller: _nameFieldController,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: convert, child: const Text('CONVERT')),
                  Text(
                    errorMessage,
                    style: AppTheme.errorTextStyle,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<File?> showPDFPicker(context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false);
      //TODO: ADD WEB SUPPORT
      if (result != null && result.files.isNotEmpty) {
        // if (kIsWeb) {
        //   Uint8List? bytes = result.files.first
        //       .bytes;
        // } else
        if (Platform.isAndroid) {
          String path = result.files.first.path!;
          return File(path);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> showPathPicker(context) async {
    String? path = await FilePicker.platform.getDirectoryPath();
    return path;
  }

  void convert() {
    name = _nameFieldController.text;
    if (pdfFile == null ||
        destinationPath == null ||
        destinationPath!.split('/').last != 'local' ||
        name == null ||
        name == '') {
      setState(() => errorMessage = 'Enter Valid Credentials');
    } else {
      setState(() => errorMessage = '');
      createBook();
    }
  }

  void createBook() async {
    debugPrint(
        "Create\nBook: $name\nDestination: $destinationPath\nPDF: $pdfFile");
    try {
      Directory directory = Directory('${destinationPath!}/$name/chapter');
      await directory.create(recursive: true);
      PdfDocument document = await PdfDocument.openFile(pdfFile!.path);
      PdfPage page = await document.getPage(1);
      PdfPageImage pageImage = await page.render(
        width: page.width.toInt(),
        height: page.height.toInt(),
        backgroundFill: false,
      );
      img.Image image = img.Image.fromBytes(
        width: pageImage.width,
        height: pageImage.height,
        bytes: pageImage.pixels.buffer,
      );
      final file = File('${directory.path}/cover.txt');

      pageImage.dispose();
      document.dispose();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
