import { useState, useEffect, useCallback } from 'react';
import * as MediaLibrary from 'expo-media-library';

export interface BackupStatus {
  isBackedUp: boolean;
  cloudService: 'icloud' | 'google' | 'none';
  lastSynced?: Date;
}

/**
 * Hook to check backup status of photos
 * Note: This is a heuristic-based check since iOS doesn't expose direct iCloud status
 * We can only make educated guesses based on photo metadata
 */
export function useBackupStatus() {
  const [backupEnabled, setBackupEnabled] = useState<boolean | null>(null);
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    checkBackupStatus();
  }, []);

  const checkBackupStatus = useCallback(async () => {
    try {
      setIsChecking(true);
      
      // On iOS, we can't directly check iCloud Photos status
      // This is a placeholder that can be enhanced with native modules
      // For now, we assume backup is enabled if the user has granted photo access
      const { status } = await MediaLibrary.requestPermissionsAsync();
      
      if (status === 'granted') {
        // Heuristic: Check if recent photos exist (indicating active photo sync)
        const recentPhotos = await MediaLibrary.getAssetsAsync({
          first: 1,
          sortBy: [MediaLibrary.SortBy.creationTime],
        });
        
        setBackupEnabled(recentPhotos.totalCount > 0);
      } else {
        setBackupEnabled(false);
      }
      
      setIsChecking(false);
    } catch (error) {
      console.error('Error checking backup status:', error);
      setBackupEnabled(null);
      setIsChecking(false);
    }
  }, []);

  /**
   * Check if a specific photo is likely backed up
   * This is heuristic-based - actual iCloud status requires native code
   */
  const checkPhotoBackupStatus = useCallback(async (assetId: string): Promise<BackupStatus> => {
    try {
      const asset = await MediaLibrary.getAssetInfoAsync(assetId);
      
      // Heuristics for determining backup status:
      // 1. If photo has location, it's likely synced (iCloud preserves metadata)
      // 2. If photo is older than 30 days and still accessible, likely backed up
      // 3. If photo has original filename preserved, likely synced
      
      const isOlderThan30Days = asset.creationTime 
        ? Date.now() - asset.creationTime > 30 * 24 * 60 * 60 * 1000 
        : false;
      
      const hasLocation = asset.location !== null && asset.location !== undefined;
      
      // Simple heuristic: older photos that are still accessible are likely backed up
      const isLikelyBackedUp = isOlderThan30Days || hasLocation;
      
      return {
        isBackedUp: isLikelyBackedUp,
        cloudService: isLikelyBackedUp ? 'icloud' : 'none',
        lastSynced: isLikelyBackedUp ? new Date() : undefined,
      };
    } catch (error) {
      console.error('Error checking photo backup status:', error);
      return {
        isBackedUp: false,
        cloudService: 'none',
      };
    }
  }, []);

  /**
   * Get backup warning for photos about to be deleted
   * Returns number of photos that might not be backed up
   */
  const getBackupWarning = useCallback(async (assetIds: string[]): Promise<{
    notBackedUpCount: number;
    notBackedUpIds: string[];
  }> => {
    const notBackedUpIds: string[] = [];
    
    for (const id of assetIds.slice(0, 20)) { // Check first 20 for performance
      const status = await checkPhotoBackupStatus(id);
      if (!status.isBackedUp) {
        notBackedUpIds.push(id);
      }
    }
    
    // Extrapolate for larger sets
    const ratio = notBackedUpIds.length / Math.min(assetIds.length, 20);
    const estimatedNotBackedUp = Math.round(assetIds.length * ratio);
    
    return {
      notBackedUpCount: estimatedNotBackedUp,
      notBackedUpIds,
    };
  }, [checkPhotoBackupStatus]);

  return {
    backupEnabled,
    isChecking,
    checkPhotoBackupStatus,
    getBackupWarning,
    refreshStatus: checkBackupStatus,
  };
}
