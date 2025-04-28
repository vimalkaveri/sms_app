// lib/pages/help.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    preparePdf();
  }

  Future<void> preparePdf() async {
    final ByteData bytes = await rootBundle.load('assets/manual.pdf');
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/manual.pdf');

    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help - Manual'),
      ),
      body: localPath != null
          ? PDFView(
        filePath: localPath,
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
