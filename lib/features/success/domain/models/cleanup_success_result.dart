class CleanupSuccessResult {
  final int itemsDeleted;
  final int bytesFreed;
  final int? storageBeforeBytes;
  final int? storageAfterBytes;
  final int? duplicatesRemoved;

  const CleanupSuccessResult({
    required this.itemsDeleted,
    required this.bytesFreed,
    this.storageBeforeBytes,
    this.storageAfterBytes,
    this.duplicatesRemoved,
  });
}

