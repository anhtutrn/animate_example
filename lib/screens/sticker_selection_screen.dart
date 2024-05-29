import 'package:flutter/material.dart';

class StickerSelectionScreen extends StatelessWidget {
  final Function(String) onStickerSelected;

  StickerSelectionScreen({
    super.key,
    required this.onStickerSelected,
  });

  final List<String> stickerList = [
    'assets/free.png',
    'assets/smile.png',
    'assets/new.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Sticker'),
      ),
      body: GridView.builder(
        itemCount: stickerList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: stickerList.length,
        ),
        itemBuilder: (context, index) {
          final sticker = stickerList[index];
          return SizedBox(
            height: 100,
            width: 100,
            child: GestureDetector(
              onTap: () {
                onStickerSelected(sticker);
                Navigator.pop(context);
              },
              child: Image.asset(
                stickerList[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
