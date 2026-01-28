import { create } from 'zustand';

export type ToastType = 'success' | 'error' | 'info';

interface ToastState {
  visible: boolean;
  message: string;
  type: ToastType;
  timerId?: NodeJS.Timeout;
  showToast: (message: string, type?: ToastType) => void;
  hideToast: () => void;
}

export const useToastStore = create<ToastState>((set, get) => ({
  visible: false,
  message: '',
  type: 'success',
  timerId: undefined,
  
  showToast: (message: string, type: ToastType = 'success') => {
    const { timerId } = get();
    if (timerId) clearTimeout(timerId);
    
    set({ visible: true, message, type });
    
    // Auto-hide after 2.5 seconds
    const newTimer = setTimeout(() => {
      set({ visible: false, timerId: undefined });
    }, 2500);
    
    set({ timerId: newTimer });
  },
  
  hideToast: () => {
    const { timerId } = get();
    if (timerId) clearTimeout(timerId);
    set({ visible: false, timerId: undefined });
  },
}));
