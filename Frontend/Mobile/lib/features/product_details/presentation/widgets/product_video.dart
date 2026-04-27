import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class ProductVideo extends StatefulWidget {
  const ProductVideo({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<ProductVideo> createState() => _ProductVideoState();
}

class _ProductVideoState extends State<ProductVideo> {
  VideoPlayerController? _controller;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final url = widget.videoUrl.trim();
    if (url.isEmpty) return;

    final platform = defaultTargetPlatform;
    final isSupportedRuntime = !kIsWeb && (platform == TargetPlatform.android || platform == TargetPlatform.iOS);
    if (!isSupportedRuntime) {
      if (!mounted) return;
      setState(() {
        _initError = 'Video preview is not supported on this device.';
      });
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;
      await controller.initialize();
      if (mounted) setState(() {});
    } on PlatformException catch (_) {
      if (!mounted) return;
      setState(() {
        _initError = 'Unable to load product video on this device.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initError = 'Unable to load product video.';
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
    if (_initError != null) {
      return Text(
        _initError!,
        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
      );
    }

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
