import 'package:photo_manager/photo_manager.dart';

class DeleteCandidate {
  final String id;
  final AssetEntity asset;
  final int fileSizeBytes;

  const DeleteCandidate({
    required this.id,
    required this.asset,
    required this.fileSizeBytes,
  });
}

