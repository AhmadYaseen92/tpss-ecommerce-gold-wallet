import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ProductVideo extends StatefulWidget {
  const ProductVideo({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<ProductVideo> createState() => _ProductVideoState();
}

class _ProductVideoState extends State<ProductVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final url = widget.videoUrl.trim();
    if (url.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Video',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
                setState(() {});
              },
              icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ],
        ),
      ],
    );
  }
}
