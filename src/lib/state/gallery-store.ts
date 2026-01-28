import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface Photo {
  id: string;
  uri: string;
  filename: string;
  creationTime: number;
  width: number;
  height: number;
  fileSize?: number;
}

interface GalleryState {
  // Onboarding state
  hasCompletedOnboarding: boolean;
  setHasCompletedOnboarding: (completed: boolean) => void;

  // Delete queue
  deleteQueue: string[]; // Array of photo IDs
  addToDeleteQueue: (photoId: string) => void;
  removeFromDeleteQueue: (photoId: string) => void;
  clearDeleteQueue: () => void;
  isInDeleteQueue: (photoId: string) => boolean;
  toggleInDeleteQueue: (photoId: string) => void;
  selectAll: (photoIds: string[]) => void;
  deselectAll: () => void;
  invertSelection: (photoIds: string[]) => void;

  // Selection mode
  isSelectionMode: boolean;
  setSelectionMode: (mode: boolean) => void;

  // Swipe mode
  isSwipeMode: boolean;
  setSwipeMode: (mode: boolean) => void;
  currentSwipeIndex: number;
  setCurrentSwipeIndex: (index: number) => void;

  // Stats (mock data for now)
  totalPhotos: number;
  setTotalPhotos: (count: number) => void;

  // Estimated storage savings
  estimatedStorageSaved: number; // in bytes
  setEstimatedStorageSaved: (size: number) => void;

  // Date filter
  dateFilter: { preset: 'all' | 'today' | 'thisWeek' | 'thisMonth' | 'thisYear' | 'custom'; startDate?: number; endDate?: number };
  setDateFilter: (filter: { preset: 'all' | 'today' | 'thisWeek' | 'thisMonth' | 'thisYear' | 'custom'; startDate?: number; endDate?: number }) => void;

  // Advanced filters
  photoTypeFilter: 'all' | 'screenshots' | 'selfies' | 'live' | 'burst';
  sizeFilter: 'all' | 'large' | 'small' | 'medium';
  setPhotoTypeFilter: (filter: 'all' | 'screenshots' | 'selfies' | 'live' | 'burst') => void;
  setSizeFilter: (filter: 'all' | 'large' | 'small' | 'medium') => void;

  // Sorting
  sortBy: 'date' | 'size' | 'name';
  sortOrder: 'asc' | 'desc';
  setSortBy: (sortBy: 'date' | 'size' | 'name') => void;
  setSortOrder: (order: 'asc' | 'desc') => void;

  // Recently Deleted
  recentlyDeleted: Array<{ id: string; deletedAt: number; asset: any }>;
  addToRecentlyDeleted: (id: string, asset: any) => void;
  addManyToRecentlyDeleted: (items: Array<{ id: string; asset: any }>) => void;
  removeFromRecentlyDeleted: (id: string) => void;
  clearRecentlyDeleted: () => void;
  restorePhoto: (id: string) => void;

  // Undo
  lastDeletedPhotos: Array<{ id: string; asset: any }>;
  setLastDeletedPhotos: (photos: Array<{ id: string; asset: any }>) => void;
  clearLastDeletedPhotos: () => void;
}

export const useGalleryStore = create<GalleryState>()(
  persist(
    (set, get) => ({
      // Onboarding
      hasCompletedOnboarding: false,
      setHasCompletedOnboarding: (completed) => set({ hasCompletedOnboarding: completed }),

      // Delete queue
      deleteQueue: [],
      addToDeleteQueue: (photoId) => set((state) => ({
        deleteQueue: state.deleteQueue.includes(photoId)
          ? state.deleteQueue
          : [...state.deleteQueue, photoId]
      })),
      removeFromDeleteQueue: (photoId) => set((state) => ({
        deleteQueue: state.deleteQueue.filter((id) => id !== photoId)
      })),
      clearDeleteQueue: () => set({ deleteQueue: [] }),
      isInDeleteQueue: (photoId) => get().deleteQueue.includes(photoId),
      toggleInDeleteQueue: (photoId) => {
        const { deleteQueue } = get();
        if (deleteQueue.includes(photoId)) {
          set({ deleteQueue: deleteQueue.filter((id) => id !== photoId) });
        } else {
          set({ deleteQueue: [...deleteQueue, photoId] });
        }
      },
      selectAll: (photoIds) => set({ deleteQueue: [...new Set(photoIds)] }),
      deselectAll: () => set({ deleteQueue: [] }),
      invertSelection: (photoIds) => {
        const { deleteQueue } = get();
        const newQueue = photoIds.filter((id) => !deleteQueue.includes(id));
        set({ deleteQueue: newQueue });
      },

      // Selection mode
      isSelectionMode: false,
      setSelectionMode: (mode) => set({ isSelectionMode: mode }),

      // Swipe mode
      isSwipeMode: false,
      setSwipeMode: (mode) => set({ isSwipeMode: mode }),
      currentSwipeIndex: 0,
      setCurrentSwipeIndex: (index) => set({ currentSwipeIndex: index }),

      // Stats
      totalPhotos: 0,
      setTotalPhotos: (count) => set({ totalPhotos: count }),

      // Storage
      estimatedStorageSaved: 0,
      setEstimatedStorageSaved: (size) => set({ estimatedStorageSaved: size }),

      // Date filter
      dateFilter: { preset: 'all' },
      setDateFilter: (filter) => set({ dateFilter: filter }),

      // Advanced filters
      photoTypeFilter: 'all',
      sizeFilter: 'all',
      setPhotoTypeFilter: (filter) => set({ photoTypeFilter: filter }),
      setSizeFilter: (filter) => set({ sizeFilter: filter }),

      // Sorting
      sortBy: 'date',
      sortOrder: 'desc',
      setSortBy: (sortBy) => set({ sortBy }),
      setSortOrder: (order) => set({ sortOrder: order }),

      // Recently Deleted
      recentlyDeleted: [],
      addToRecentlyDeleted: (id, asset) => set((state) => ({
        recentlyDeleted: [
          ...state.recentlyDeleted.filter((item) => item.id !== id),
          { id, deletedAt: Date.now(), asset },
        ],
      })),
      addManyToRecentlyDeleted: (items) => set((state) => {
        const newItems = items.map(item => ({
          id: item.id,
          deletedAt: Date.now(),
          asset: item.asset
        }));
        // Filter out any that are already in the new list to avoid duplicates
        const existingIds = new Set(newItems.map(i => i.id));
        return {
          recentlyDeleted: [
            ...state.recentlyDeleted.filter((item) => !existingIds.has(item.id)),
            ...newItems,
          ],
        };
      }),
      removeFromRecentlyDeleted: (id) => set((state) => ({
        recentlyDeleted: state.recentlyDeleted.filter((item) => item.id !== id),
      })),
      clearRecentlyDeleted: () => set({ recentlyDeleted: [] }),
      restorePhoto: (id) => {
        const { recentlyDeleted } = get();
        const item = recentlyDeleted.find((item) => item.id === id);
        if (item) {
          // Remove from recently deleted
          set({
            recentlyDeleted: recentlyDeleted.filter((item) => item.id !== id),
          });
        }
      },

      // Undo
      lastDeletedPhotos: [],
      setLastDeletedPhotos: (photos) => set({ lastDeletedPhotos: photos }),
      clearLastDeletedPhotos: () => set({ lastDeletedPhotos: [] }),
    }),
    {
      name: 'clean-gallery-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        hasCompletedOnboarding: state.hasCompletedOnboarding,
        recentlyDeleted: state.recentlyDeleted,
      }),
    }
  )
);

// Helper to format bytes to human readable
export function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
}
