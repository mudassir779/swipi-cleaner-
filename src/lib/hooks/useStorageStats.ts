import { useState, useEffect } from 'react';
import * as MediaLibrary from 'expo-media-library';
import { formatBytes } from '../state/gallery-store';

export interface StorageStats {
  totalPhotos: number;
  totalVideos: number;
  totalStorage: number;
  photoStorage: number;
  videoStorage: number;
  loading: boolean;
  error: Error | null;
}

export function useStorageStats() {
  const [stats, setStats] = useState<StorageStats>({
    totalPhotos: 0,
    totalVideos: 0,
    totalStorage: 0,
    photoStorage: 0,
    videoStorage: 0,
    loading: true,
    error: null,
  });

  useEffect(() => {
    let isMounted = true;

    const calculateStats = async () => {
      try {
        setStats((prev) => ({ ...prev, loading: true, error: null }));

        // Get all photos
        const photosResult = await MediaLibrary.getAssetsAsync({
          first: 10000,
          mediaType: 'photo',
        });

        // Get all videos
        const videosResult = await MediaLibrary.getAssetsAsync({
          first: 10000,
          mediaType: 'video',
        });

        // Calculate photo storage
        let photoStorage = 0;
        const photoSample = photosResult.assets.slice(0, 100); // Sample first 100
        for (const asset of photoSample) {
          try {
            const info = await MediaLibrary.getAssetInfoAsync(asset.id);
            const fileSize = (info as any)?.fileSize;
            if (fileSize && fileSize > 0) {
              photoStorage += fileSize;
            }
          } catch (error) {
            // Skip on error
          }
        }
        // Estimate total from sample
        const avgPhotoSize = photoSample.length > 0 ? photoStorage / photoSample.length : 2 * 1024 * 1024;
        photoStorage = avgPhotoSize * photosResult.totalCount;

        // Calculate video storage
        let videoStorage = 0;
        const videoSample = videosResult.assets.slice(0, 50); // Sample first 50
        for (const asset of videoSample) {
          try {
            const info = await MediaLibrary.getAssetInfoAsync(asset.id);
            const fileSize = (info as any)?.fileSize;
            if (fileSize && fileSize > 0) {
              videoStorage += fileSize;
            }
          } catch (error) {
            // Skip on error
          }
        }
        // Estimate total from sample
        const avgVideoSize = videoSample.length > 0 ? videoStorage / videoSample.length : 50 * 1024 * 1024;
        videoStorage = avgVideoSize * videosResult.totalCount;

        if (isMounted) {
          setStats({
            totalPhotos: photosResult.totalCount,
            totalVideos: videosResult.totalCount,
            totalStorage: photoStorage + videoStorage,
            photoStorage,
            videoStorage,
            loading: false,
            error: null,
          });
        }
      } catch (error) {
        if (isMounted) {
          setStats((prev) => ({
            ...prev,
            loading: false,
            error: error as Error,
          }));
        }
      }
    };

    calculateStats();

    return () => {
      isMounted = false;
    };
  }, []);

  return stats;
}
