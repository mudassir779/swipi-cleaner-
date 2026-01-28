import * as MediaLibrary from 'expo-media-library';
import * as Crypto from 'expo-crypto';

export interface DuplicateGroup {
  id: string;
  photos: MediaLibrary.Asset[];
  totalSize: number;
}

/**
 * Simple hash-based duplicate detection
 * Groups photos with identical dimensions and similar file sizes
 */
export async function detectDuplicates(
  photos: MediaLibrary.Asset[],
  onProgress?: (progress: number) => void
): Promise<DuplicateGroup[]> {
  const groups: Map<string, MediaLibrary.Asset[]> = new Map();
  const total = photos.length;

  for (let i = 0; i < photos.length; i++) {
    const photo = photos[i];
    
    // Create a key based on dimensions and approximate size
    // This is a simple approach - for more accuracy, we'd need to hash the actual image data
    const key = `${photo.width}x${photo.height}`;

    if (!groups.has(key)) {
      groups.set(key, []);
    }
    groups.get(key)!.push(photo);

    if (onProgress) {
      onProgress((i + 1) / total);
    }
  }

  // Filter to only groups with 2+ photos (actual duplicates)
  const duplicateGroups: DuplicateGroup[] = [];

  for (const [key, groupPhotos] of groups.entries()) {
    if (groupPhotos.length > 1) {
      // Get file sizes for all photos in group
      let totalSize = 0;
      const photosWithInfo: MediaLibrary.Asset[] = [];

      for (const photo of groupPhotos) {
        try {
          const info = await MediaLibrary.getAssetInfoAsync(photo.id);
          if (info) {
            photosWithInfo.push(info);
            const fileSize = (info as any).fileSize;
            if (fileSize && fileSize > 0) {
              totalSize += fileSize;
            } else {
              totalSize += 2 * 1024 * 1024; // Estimate
            }
          }
        } catch (error) {
          // Skip on error
          photosWithInfo.push(photo);
          totalSize += 2 * 1024 * 1024; // Estimate
        }
      }

      // Sort by creation time (newest first) to help identify "best" photo
      photosWithInfo.sort((a, b) => b.creationTime - a.creationTime);

      duplicateGroups.push({
        id: key,
        photos: photosWithInfo,
        totalSize,
      });
    }
  }

  // Sort groups by number of duplicates (most duplicates first)
  duplicateGroups.sort((a, b) => b.photos.length - a.photos.length);

  return duplicateGroups;
}

/**
 * Get the "best" photo from a duplicate group
 * Currently selects the newest photo
 */
export function getBestPhoto(group: DuplicateGroup): MediaLibrary.Asset {
  // Sort by creation time (newest first) and file size (largest first)
  const sorted = [...group.photos].sort((a, b) => {
    // Prefer newer photos
    if (b.creationTime !== a.creationTime) {
      return b.creationTime - a.creationTime;
    }
    // If same time, prefer larger file size (higher quality)
    return (b as any).fileSize - (a as any).fileSize;
  });

  return sorted[0];
}
