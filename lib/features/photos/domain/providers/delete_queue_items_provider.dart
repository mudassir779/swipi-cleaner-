import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../shared/services/photo_service.dart';
import '../models/delete_candidate.dart';
import 'delete_queue_provider.dart';

final deleteQueueItemsProvider = FutureProvider<List<DeleteCandidate>>((ref) async {
  final ids = ref.watch(deleteQueueProvider);
  if (ids.isEmpty) return [];

  final photoService = PhotoService();
  final hasPermission = await photoService.hasPermission();
  if (!hasPermission) return [];

  final candidates = <DeleteCandidate>[];
  for (final id in ids) {
    final entity = await AssetEntity.fromId(id);
    if (entity == null) continue;
    final size = await photoService.getFileSize(entity);
    candidates.add(DeleteCandidate(id: id, asset: entity, fileSizeBytes: size));
  }

  return candidates;
});

