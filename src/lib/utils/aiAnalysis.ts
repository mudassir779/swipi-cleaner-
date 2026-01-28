import * as FileSystem from 'expo-file-system';
import * as MediaLibrary from 'expo-media-library';

export interface PhotoAnalysis {
  isBlurry: boolean;
  blurScore: number; // 0-1, higher = more blurry
  quality: 'high' | 'medium' | 'low';
  suggestions: string[];
}

export async function analyzePhotoBlur(photoUri: string): Promise<PhotoAnalysis> {
  try {
    // Read image as base64
    const base64 = await FileSystem.readAsStringAsync(photoUri, {
      encoding: 'base64',
    });
    const mimeType = photoUri.endsWith('.png') ? 'image/png' : 'image/jpeg';
    const dataUrl = `data:${mimeType};base64,${base64}`;

    // Call OpenAI Vision API for blur detection
    const response = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${process.env.EXPO_PUBLIC_VIBECODE_OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: 'gpt-5.2',
        input: `Analyze this image for blur and quality. Respond with JSON: {"isBlurry": boolean, "blurScore": 0-1, "quality": "high"|"medium"|"low", "suggestions": string[]}. Focus on detecting motion blur, focus issues, and overall image quality.`,
        image: dataUrl,
      }),
    });

    if (!response.ok) {
      throw new Error('AI analysis failed');
    }

    const data = await response.json();
    // Parse the response (might be text that needs parsing)
    let analysis: PhotoAnalysis;
    
    try {
      // Try to parse as JSON if it's a string
      const content = typeof data.content === 'string' ? JSON.parse(data.content) : data.content;
      analysis = {
        isBlurry: content.isBlurry || false,
        blurScore: content.blurScore || 0.5,
        quality: content.quality || 'medium',
        suggestions: content.suggestions || [],
      };
    } catch {
      // Fallback analysis
      analysis = {
        isBlurry: false,
        blurScore: 0.3,
        quality: 'medium',
        suggestions: [],
      };
    }

    return analysis;
  } catch (error) {
    console.error('Error analyzing photo:', error);
    // Return default analysis on error
    return {
      isBlurry: false,
      blurScore: 0.3,
      quality: 'medium',
      suggestions: [],
    };
  }
}

export async function findSimilarPhotos(
  targetPhoto: MediaLibrary.Asset,
  allPhotos: MediaLibrary.Asset[]
): Promise<MediaLibrary.Asset[]> {
  try {
    // Simple similarity based on dimensions and creation time
    // In a real implementation, you'd use image hashing or AI
    const similar: MediaLibrary.Asset[] = [];
    const timeWindow = 5 * 60 * 1000; // 5 minutes

    allPhotos.forEach((photo) => {
      if (photo.id === targetPhoto.id) return;

      // Check if dimensions are similar (within 10%)
      const widthDiff = Math.abs(photo.width - targetPhoto.width) / targetPhoto.width;
      const heightDiff = Math.abs(photo.height - targetPhoto.height) / targetPhoto.height;

      // Check if taken around the same time
      const timeDiff = Math.abs(photo.creationTime - targetPhoto.creationTime);

      if (
        widthDiff < 0.1 &&
        heightDiff < 0.1 &&
        timeDiff < timeWindow
      ) {
        similar.push(photo);
      }
    });

    return similar.slice(0, 10); // Return top 10 similar
  } catch (error) {
    console.error('Error finding similar photos:', error);
    return [];
  }
}
