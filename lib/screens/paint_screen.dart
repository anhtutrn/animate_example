import 'dart:io';
import 'dart:ui';

import 'package:animate_example/models/sticker_data.dart';
import 'package:animate_example/screens/sticker_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class PaintScreen extends StatefulWidget {
  const PaintScreen({super.key});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  List<StickerData> stickers = [];

  Future<void> _handleSave() async {
    try {
      final width = context.size!.width;
      final height = context.size!.height;
      final recorder = PictureRecorder();
      final canvas = Canvas(
          recorder, Rect.fromPoints(const Offset(0, 0), Offset(width, height)));

      // Draw white background
      canvas.drawRect(
          Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);

      // Draw signature if not empty
      if (_controller.isNotEmpty) {
        final signature = await _controller.toImage(
          width: width.toInt(),
          height: height.toInt(),
        );
        canvas.drawImageRect(
          signature!,
          Rect.fromLTWH(
              0, 0, signature.width.toDouble(), signature.height.toDouble()),
          Rect.fromLTWH(
              0, 0, signature.width.toDouble(), signature.height.toDouble()),
          Paint(),
        );
      }

      // Draw stickers
      for (final sticker in stickers) {
        final byteData = await rootBundle.load(sticker.imagePath);
        final bytes = byteData.buffer.asUint8List();
        final codec = await instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        canvas.drawImage(frame.image, sticker.position, Paint());
      }

      // Convert canvas to image
      final picture = recorder.endRecording();
      final imgImage = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await imgImage.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Save the image to gallery
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/signature.png';
      final combinedFile = await File(filePath).writeAsBytes(buffer);
      await ImageGallerySaver.saveFile(combinedFile.path);
      if (context.mounted) {
        var snackBar = const SnackBar(
          content: Center(
            child: Text('Saved to gallery!'),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      if (context.mounted) {
        var snackBar = const SnackBar(
          content: Center(
            child: Text('Failed to save.'),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void _addSticker(String imagePath) {
    setState(() {
      stickers.add(
        StickerData(
          imagePath,
          const Offset(50, 50),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
                ...stickers
                    .map(
                      (sticker) => Positioned(
                        left: sticker.position.dx,
                        top: sticker.position.dy,
                        child: Draggable<StickerData>(
                          data: sticker,
                          feedback: Image.asset(
                            sticker.imagePath,
                          ),
                          childWhenDragging: Container(),
                          onDragEnd: (drag) {
                            setState(() {
                              sticker.position = drag.offset;
                            });
                          },
                          child: Image.asset(
                            sticker.imagePath,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: () => _controller.undo(),
                child: const Text('Undo'),
              ),
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StickerSelectionScreen(
                      onStickerSelected: _addSticker,
                    ),
                  ),
                ),
                child: const Text('Stickers'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
