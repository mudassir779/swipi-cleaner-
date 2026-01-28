import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface PremiumState {
  isPremium: boolean;
  subscriptionType: 'free' | 'monthly' | 'yearly' | 'lifetime';
  expirationDate: number | null;
  
  // Actions
  setPremiumStatus: (isPremium: boolean, type?: 'monthly' | 'yearly' | 'lifetime') => void;
  setExpirationDate: (date: number | null) => void;
  checkPremiumStatus: () => boolean;
}

export const usePremiumStore = create<PremiumState>()(
  persist(
    (set, get) => ({
      isPremium: false,
      subscriptionType: 'free',
      expirationDate: null,

      setPremiumStatus: (isPremium, type = 'monthly') => set({
        isPremium,
        subscriptionType: isPremium ? type : 'free',
      }),

      setExpirationDate: (date) => set({ expirationDate: date }),

      checkPremiumStatus: () => {
        const { isPremium, subscriptionType, expirationDate } = get();
        
        // Lifetime never expires
        if (subscriptionType === 'lifetime') return true;
        
        // Check if subscription has expired
        if (expirationDate && Date.now() > expirationDate) {
          set({ isPremium: false, subscriptionType: 'free' });
          return false;
        }
        
        return isPremium;
      },
    }),
    {
      name: 'premium-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

/**
 * Hook to check if a feature requires premium and is accessible
 */
export function usePremiumFeature(featureName: PremiumFeature): {
  isLocked: boolean;
  isPremium: boolean;
  showPaywall: () => void;
} {
  const isPremium = usePremiumStore((s) => s.checkPremiumStatus());
  
  const featureRequiresPremium = PREMIUM_FEATURES[featureName];
  const isLocked = featureRequiresPremium && !isPremium;
  
  const showPaywall = () => {
    // This would typically navigate to premium screen
    console.log('Show paywall for feature:', featureName);
  };
  
  return {
    isLocked,
    isPremium,
    showPaywall,
  };
}

// Feature definitions
export type PremiumFeature = 
  | 'ai_duplicates'
  | 'blurry_detection'
  | 'unlimited_queue'
  | 'backup_status'
  | 'advanced_analytics'
  | 'smart_suggestions'
  | 'bulk_operations';

const PREMIUM_FEATURES: Record<PremiumFeature, boolean> = {
  ai_duplicates: true,
  blurry_detection: true,
  unlimited_queue: true,
  backup_status: true,
  advanced_analytics: true,
  smart_suggestions: true,
  bulk_operations: false, // Available in free
};

/**
 * Check delete queue limit for free users
 */
export function useQueueLimit() {
  const isPremium = usePremiumStore((s) => s.checkPremiumStatus());
  
  const FREE_QUEUE_LIMIT = 50;
  
  return {
    limit: isPremium ? Infinity : FREE_QUEUE_LIMIT,
    isUnlimited: isPremium,
    remaining: (currentCount: number) => 
      isPremium ? Infinity : Math.max(0, FREE_QUEUE_LIMIT - currentCount),
  };
}
