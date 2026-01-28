import * as MediaLibrary from 'expo-media-library';

export type SourceApp =
  | 'whatsapp'
  | 'instagram'
  | 'snapchat'
  | 'telegram'
  | 'twitter'
  | 'facebook'
  | 'tiktok'
  | 'camera'
  | 'screenshot'
  | 'download'
  | 'other';

export interface SourceAppInfo {
  name: string;
  gradient: [string, string];
  patterns: string[];
}

export const SOURCE_APP_INFO: Record<SourceApp, SourceAppInfo> = {
  whatsapp: {
    name: 'WhatsApp',
    gradient: ['#25D366', '#128C7E'],
    patterns: ['img-', 'vid-', '-wa'],
  },
  instagram: {
    name: 'Instagram',
    gradient: ['#E1306C', '#C13584'],
    patterns: ['instagram', 'insta_', 'ig_'],
  },
  snapchat: {
    name: 'Snapchat',
    gradient: ['#FFFC00', '#F7B500'],
    patterns: ['snapchat', 'snap-'],
  },
  telegram: {
    name: 'Telegram',
    gradient: ['#0088cc', '#0066aa'],
    patterns: ['telegram', 'tg_'],
  },
  twitter: {
    name: 'Twitter/X',
    gradient: ['#1DA1F2', '#0d8bd9'],
    patterns: ['twitter', 'tweet', 'x_'],
  },
  facebook: {
    name: 'Facebook',
    gradient: ['#4267B2', '#3b5998'],
    patterns: ['facebook', 'fb_', 'messenger'],
  },
  tiktok: {
    name: 'TikTok',
    gradient: ['#00f2ea', '#ff0050'],
    patterns: ['tiktok', 'musically'],
  },
  camera: {
    name: 'Camera',
    gradient: ['#64748b', '#475569'],
    patterns: ['img_', 'photo_', 'dcim', 'dsc'],
  },
  screenshot: {
    name: 'Screenshots',
    gradient: ['#f97316', '#ea580c'],
    patterns: ['screenshot', 'screen shot', 'screen_shot', 'capture'],
  },
  download: {
    name: 'Downloads',
    gradient: ['#3b82f6', '#2563eb'],
    patterns: ['download', 'saved', 'received'],
  },
  other: {
    name: 'Other',
    gradient: ['#94a3b8', '#64748b'],
    patterns: [],
  },
};

/**
 * Detect the source app that created a media asset based on filename patterns
 */
export function detectSourceApp(asset: MediaLibrary.Asset): SourceApp {
  const filename = (asset.filename || '').toLowerCase();
  const uri = (asset.uri || '').toLowerCase();

  // Check for screenshot first (highest priority pattern)
  if (
    filename.includes('screenshot') ||
    filename.includes('screen shot') ||
    filename.includes('screen_shot') ||
    filename.includes('capture')
  ) {
    return 'screenshot';
  }

  // Check for WhatsApp (common pattern: IMG-YYYYMMDD-WA####)
  if (filename.includes('-wa') || uri.includes('whatsapp')) {
    return 'whatsapp';
  }

  // Check for Instagram
  if (filename.includes('instagram') || filename.includes('insta_') || uri.includes('instagram')) {
    return 'instagram';
  }

  // Check for Snapchat
  if (filename.includes('snapchat') || filename.includes('snap-')) {
    return 'snapchat';
  }

  // Check for Telegram
  if (filename.includes('telegram') || filename.includes('tg_')) {
    return 'telegram';
  }

  // Check for Twitter/X
  if (filename.includes('twitter') || filename.includes('tweet')) {
    return 'twitter';
  }

  // Check for Facebook
  if (filename.includes('facebook') || filename.includes('fb_') || filename.includes('messenger')) {
    return 'facebook';
  }

  // Check for TikTok
  if (filename.includes('tiktok') || filename.includes('musically')) {
    return 'tiktok';
  }

  // Check for downloads
  if (filename.includes('download') || filename.includes('saved') || filename.includes('received')) {
    return 'download';
  }

  // Check for camera (default camera naming patterns)
  if (
    filename.startsWith('img_') ||
    filename.startsWith('photo_') ||
    filename.includes('dcim') ||
    filename.startsWith('dsc')
  ) {
    return 'camera';
  }

  return 'other';
}

/**
 * Group assets by source app
 */
export function groupAssetsBySource(
  assets: MediaLibrary.Asset[]
): Record<SourceApp, MediaLibrary.Asset[]> {
  const groups: Record<SourceApp, MediaLibrary.Asset[]> = {
    whatsapp: [],
    instagram: [],
    snapchat: [],
    telegram: [],
    twitter: [],
    facebook: [],
    tiktok: [],
    camera: [],
    screenshot: [],
    download: [],
    other: [],
  };

  for (const asset of assets) {
    const source = detectSourceApp(asset);
    groups[source].push(asset);
  }

  return groups;
}
