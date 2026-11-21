import 'package:share_plus/share_plus.dart';

class SharedImageFile {
  const SharedImageFile({required this.xFile, required this.cleanup});

  final XFile xFile;
  final Future<void> Function() cleanup;
}
