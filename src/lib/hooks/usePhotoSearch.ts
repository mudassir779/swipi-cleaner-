import { useState, useEffect, useMemo } from 'react';
import * as MediaLibrary from 'expo-media-library';

export function usePhotoSearch(
  photos: MediaLibrary.Asset[],
  searchQuery: string
): MediaLibrary.Asset[] {
  const [searchResults, setSearchResults] = useState<MediaLibrary.Asset[]>(photos);

  useEffect(() => {
    if (!searchQuery.trim()) {
      setSearchResults(photos);
      return;
    }

    const query = searchQuery.toLowerCase().trim();
    const filtered = photos.filter((photo) => {
      // Search by filename
      if (photo.filename?.toLowerCase().includes(query)) {
        return true;
      }

      // Search by date (format: "2024", "january", "jan", etc.)
      const date = new Date(photo.creationTime);
      const year = date.getFullYear().toString();
      const monthName = date.toLocaleString('en-US', { month: 'long' }).toLowerCase();
      const monthShort = date.toLocaleString('en-US', { month: 'short' }).toLowerCase();

      if (
        year.includes(query) ||
        monthName.includes(query) ||
        monthShort.includes(query)
      ) {
        return true;
      }

      return false;
    });

    setSearchResults(filtered);
  }, [photos, searchQuery]);

  return searchResults;
}
