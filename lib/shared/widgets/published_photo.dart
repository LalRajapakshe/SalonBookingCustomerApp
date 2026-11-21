import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/state/app_scope.dart';

/// Customer-safe catalogue photograph. Falls back to [fallback] when the
/// record has no published photo or the file cannot be loaded.
class PublishedPhoto extends StatefulWidget {
  const PublishedPhoto({
    required this.enabled,
    required this.path,
    required this.fallback,
    this.borderRadius,
    super.key,
  });

  final bool enabled;
  final String path;
  final Widget fallback;
  final BorderRadius? borderRadius;

  @override
  State<PublishedPhoto> createState() => _PublishedPhotoState();
}

class _PublishedPhotoState extends State<PublishedPhoto> {
  List<int>? _bytes;
  bool _failed = false;
  String? _requestKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final token = AppScope.maybeOf(context)?.signedIn?.accessToken;
    final key = '${widget.enabled}|${token ?? ''}|${widget.path}';
    if (_requestKey == key) return;
    _requestKey = key;
    if (!widget.enabled || token == null || token.isEmpty) return;
    try {
      final bytes = await ApiClient().getBytes(widget.path, accessToken: token);
      if (!mounted || _requestKey != key) return;
      setState(() {
        _bytes = bytes;
        _failed = false;
      });
    } on ApiException {
      if (!mounted || _requestKey != key) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes == null || _failed) return widget.fallback;
    final image = Image.memory(
      Uint8List.fromList(bytes),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
    final radius = widget.borderRadius;
    if (radius == null) return image;
    return ClipRRect(borderRadius: radius, child: image);
  }
}
