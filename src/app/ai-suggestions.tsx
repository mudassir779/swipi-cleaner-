import React, { useEffect, useState, useCallback } from "react";
import {
  View,
  Text,
  FlatList,
  Dimensions,
  Image,
  ActivityIndicator,
} from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useColorScheme } from "@/lib/useColorScheme";
import { useGalleryStore } from "@/lib/state/gallery-store";
import * as MediaLibrary from "expo-media-library";
import * as Haptics from "expo-haptics";
import { Ionicons, MaterialIcons } from "@expo/vector-icons";
import { cn } from "@/lib/cn";
import { analyzePhotoBlur, findSimilarPhotos } from "@/lib/utils/aiAnalysis";
import { AnimatedPressable } from "@/components/AnimatedPressable";
import { LinearGradient } from "expo-linear-gradient";
import Animated, {
  FadeIn,
  FadeInDown,
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withRepeat,
  withSequence,
  withSpring,
  Easing,
  interpolate,
} from "react-native-reanimated";

const { width } = Dimensions.get("window");
const NUM_COLUMNS = 3;
const SPACING = 2;
const ITEM_SIZE = (width - SPACING * (NUM_COLUMNS + 1)) / NUM_COLUMNS;

interface SuggestedPhoto {
  photo: MediaLibrary.Asset;
  reason: string;
  priority: "high" | "medium" | "low";
}

function AnimatedLoadingIcon() {
  const rotation = useSharedValue(0);
  const scale = useSharedValue(1);
  const sparkle1 = useSharedValue(0);
  const sparkle2 = useSharedValue(0);

  useEffect(() => {
    rotation.value = withRepeat(
      withTiming(360, { duration: 3000, easing: Easing.linear }),
      -1,
      false
    );
    scale.value = withRepeat(
      withSequence(
        withTiming(1.1, { duration: 1000 }),
        withTiming(1, { duration: 1000 })
      ),
      -1,
      true
    );
    sparkle1.value = withRepeat(
      withSequence(
        withTiming(1, { duration: 500 }),
        withTiming(0, { duration: 500 })
      ),
      -1,
      true
    );
    sparkle2.value = withRepeat(
      withSequence(
        withTiming(0, { duration: 300 }),
        withTiming(1, { duration: 500 }),
        withTiming(0, { duration: 500 })
      ),
      -1,
      true
    );
  }, []);

  const iconStyle = useAnimatedStyle(() => ({
    transform: [
      { rotate: `${rotation.value}deg` },
      { scale: scale.value },
    ],
  }));

  const sparkle1Style = useAnimatedStyle(() => ({
    opacity: sparkle1.value,
    transform: [{ scale: interpolate(sparkle1.value, [0, 1], [0.5, 1]) }],
  }));

  const sparkle2Style = useAnimatedStyle(() => ({
    opacity: sparkle2.value,
    transform: [{ scale: interpolate(sparkle2.value, [0, 1], [0.5, 1]) }],
  }));

  return (
    <View className="relative w-20 h-20 items-center justify-center">
      <Animated.View style={iconStyle}>
        <MaterialIcons name="auto-awesome" size={40} color="#60a5fa" />
      </Animated.View>
      <Animated.View 
        style={[sparkle1Style, { position: 'absolute', top: 5, right: 10 }]}
      >
        <MaterialIcons name="star" size={12} color="#fbbf24" />
      </Animated.View>
      <Animated.View 
        style={[sparkle2Style, { position: 'absolute', bottom: 5, left: 10 }]}
      >
        <MaterialIcons name="star" size={10} color="#f472b6" />
      </Animated.View>
    </View>
  );
}

interface AnimatedProgressBarProps {
  progress: number;
  isDark: boolean;
}

function AnimatedProgressBar({ progress, isDark }: AnimatedProgressBarProps) {
  const animatedProgress = useSharedValue(0);

  useEffect(() => {
    animatedProgress.value = withTiming(progress, {
      duration: 300,
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
    });
  }, [progress]);

  const animatedStyle = useAnimatedStyle(() => ({
    width: `${animatedProgress.value * 100}%`,
  }));

  return (
    <View
      className={cn(
        "h-2 rounded-full overflow-hidden",
        isDark ? "bg-white/10" : "bg-black/10",
      )}
    >
      <Animated.View style={animatedStyle} className="h-full rounded-full overflow-hidden">
        <LinearGradient
          colors={["#3b82f6", "#8b5cf6"]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={{ width: 500, height: "100%" }}
        />
      </Animated.View>
    </View>
  );
}

export default function AISuggestionsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";

  const [suggestedPhotos, setSuggestedPhotos] = useState<SuggestedPhoto[]>([]);
  const [loading, setLoading] = useState(true);
  const [analyzing, setAnalyzing] = useState(false);
  const [progress, setProgress] = useState(0);

  const addToDeleteQueue = useGalleryStore((s) => s.addToDeleteQueue);
  const removeFromDeleteQueue = useGalleryStore((s) => s.removeFromDeleteQueue);
  const isInDeleteQueue = useGalleryStore((s) => s.isInDeleteQueue);

  useEffect(() => {
    analyzePhotos();
  }, []);

  const analyzePhotos = async () => {
    try {
      setLoading(true);
      setAnalyzing(true);
      setProgress(0);

      // Load all photos
      const result = await MediaLibrary.getAssetsAsync({
        first: 1000,
        mediaType: "photo",
        sortBy: [[MediaLibrary.SortBy.creationTime, false]],
      });

      const suggestions: SuggestedPhoto[] = [];
      const total = Math.min(result.assets.length, 50); // Analyze first 50 for performance

      for (let i = 0; i < total; i++) {
        const photo = result.assets[i];
        setProgress((i + 1) / total);

        // Analyze for blur
        const analysis = await analyzePhotoBlur(photo.uri);

        if (analysis.isBlurry && analysis.blurScore > 0.6) {
          suggestions.push({
            photo,
            reason: "Blurry or low quality",
            priority: analysis.blurScore > 0.8 ? "high" : "medium",
          });
        }

        // Check for duplicates/similar
        const similar = await findSimilarPhotos(photo, result.assets);
        if (similar.length > 0) {
          suggestions.push({
            photo,
            reason: `${similar.length} similar photos found`,
            priority: similar.length > 3 ? "high" : "medium",
          });
        }

        // Check file size
        const fileSize = (photo as any).fileSize || 0;
        if (fileSize > 10 * 1024 * 1024) {
          suggestions.push({
            photo,
            reason: "Large file size",
            priority: "medium",
          });
        }
      }

      // Remove duplicates and sort by priority
      const unique = suggestions.filter(
        (s, index, self) =>
          index === self.findIndex((t) => t.photo.id === s.photo.id),
      );
      unique.sort((a, b) => {
        const priorityOrder = { high: 3, medium: 2, low: 1 };
        return priorityOrder[b.priority] - priorityOrder[a.priority];
      });

      setSuggestedPhotos(unique);
    } catch (error) {
      console.error("Error analyzing photos:", error);
    } finally {
      setLoading(false);
      setAnalyzing(false);
    }
  };

  const handleToggleDelete = useCallback(
    (photoId: string) => {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      if (isInDeleteQueue(photoId)) {
        removeFromDeleteQueue(photoId);
      } else {
        addToDeleteQueue(photoId);
      }
    },
    [isInDeleteQueue, addToDeleteQueue, removeFromDeleteQueue],
  );

  const renderPhoto = useCallback(
    ({ item, index }: { item: SuggestedPhoto; index: number }) => {
      const isSelected = isInDeleteQueue(item.photo.id);
      return (
        <Animated.View entering={FadeInDown.delay(index * 50).springify()}>
          <AnimatedPressable
            onPress={() => handleToggleDelete(item.photo.id)}
            scaleValue={0.95}
            style={{
              width: ITEM_SIZE,
              height: ITEM_SIZE,
              margin: SPACING / 2,
            }}
          >
            <Image
              source={{ uri: item.photo.uri }}
              style={{
                width: "100%",
                height: "100%",
                borderRadius: 8,
              }}
              resizeMode="cover"
            />
            {isSelected && (
              <View className="absolute inset-0 rounded-lg bg-red-500/30" />
            )}
            <View className="absolute top-2 right-2">
              {isSelected ? (
                <Animated.View 
                  entering={FadeIn.duration(200)}
                  className="w-6 h-6 rounded-full bg-red-500 items-center justify-center"
                  style={{
                    shadowColor: '#ef4444',
                    shadowOffset: { width: 0, height: 2 },
                    shadowOpacity: 0.4,
                    shadowRadius: 4,
                  }}
                >
                  <Ionicons name="checkmark" size={14} color="#fff" />
                </Animated.View>
              ) : (
                <View
                  className={cn(
                    "w-6 h-6 rounded-full border-2",
                    isDark
                      ? "border-white/60 bg-black/30"
                      : "border-white bg-black/20",
                  )}
                />
              )}
            </View>
            <View className="absolute bottom-2 left-2 right-2">
              <View
                className={cn(
                  "px-2 py-1 rounded-full",
                  item.priority === "high"
                    ? "bg-red-500/90"
                    : item.priority === "medium"
                      ? "bg-orange-500/90"
                      : "bg-yellow-500/90",
                )}
                style={{
                  shadowColor: item.priority === "high" ? '#ef4444' : '#f97316',
                  shadowOffset: { width: 0, height: 2 },
                  shadowOpacity: 0.3,
                  shadowRadius: 4,
                }}
              >
                <Text
                  className="text-white text-xs font-semibold"
                  numberOfLines={1}
                >
                  {item.reason}
                </Text>
              </View>
            </View>
          </AnimatedPressable>
        </Animated.View>
      );
    },
    [isInDeleteQueue, handleToggleDelete, isDark],
  );

  const keyExtractor = useCallback((item: SuggestedPhoto) => item.photo.id, []);

  if (loading) {
    return (
      <View
        className={cn(
          "flex-1 items-center justify-center px-8",
          isDark ? "bg-black" : "bg-slate-50",
        )}
      >
        <Animated.View 
          entering={FadeIn.duration(400)}
          className="items-center"
        >
          <AnimatedLoadingIcon />
          <Text
            className={cn(
              "text-lg font-semibold mt-6 text-center",
              isDark ? "text-white" : "text-slate-900",
            )}
          >
            {analyzing ? "AI is analyzing your photos..." : "Loading suggestions..."}
          </Text>
          <Text
            className={cn(
              "text-sm mt-2 text-center",
              isDark ? "text-slate-400" : "text-slate-500",
            )}
          >
            Finding blurry, duplicate, and low-quality photos
          </Text>
          {analyzing && (
            <View className="w-full mt-6">
              <AnimatedProgressBar progress={progress} isDark={isDark} />
              <Text
                className={cn(
                  "text-sm mt-3 text-center font-medium",
                  isDark ? "text-blue-400" : "text-blue-600",
                )}
              >
                {Math.round(progress * 100)}% complete
              </Text>
            </View>
          )}
        </Animated.View>
      </View>
    );
  }

  return (
    <View className={cn("flex-1", isDark ? "bg-black" : "bg-slate-50")}>
      {/* Header */}
      <Animated.View
        entering={FadeIn.duration(400)}
        className={cn(
          "px-4 pb-3 border-b",
          isDark ? "bg-black border-white/10" : "bg-slate-50 border-black/5",
        )}
        style={{ paddingTop: insets.top + 12 }}
      >
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center">
            <AnimatedPressable
              onPress={() => router.back()}
              className={cn(
                "w-10 h-10 rounded-full items-center justify-center mr-3",
                isDark ? "bg-white/10" : "bg-black/5",
              )}
              scaleValue={0.9}
            >
              <Ionicons
                name="chevron-back"
                size={24}
                color={isDark ? "#fff" : "#1e293b"}
              />
            </AnimatedPressable>
            <View>
              <Text
                className={cn(
                  "text-2xl font-bold",
                  isDark ? "text-white" : "text-slate-900",
                )}
              >
                AI Suggestions
              </Text>
              <Text
                className={cn(
                  "text-sm mt-0.5",
                  isDark ? "text-slate-400" : "text-slate-500",
                )}
              >
                {suggestedPhotos.length} photos you might want to delete
              </Text>
            </View>
          </View>

          <AnimatedPressable
            onPress={analyzePhotos}
            className={cn(
              "w-10 h-10 rounded-full items-center justify-center",
              isDark ? "bg-white/10" : "bg-black/5",
            )}
            scaleValue={0.9}
          >
            <MaterialIcons
              name="refresh"
              size={20}
              color={isDark ? "#94a3b8" : "#64748b"}
            />
          </AnimatedPressable>
        </View>
      </Animated.View>

      {suggestedPhotos.length === 0 ? (
        <View className="flex-1 items-center justify-center px-8">
          <Animated.View 
            entering={FadeInDown.springify()}
            className={cn(
              "w-20 h-20 rounded-full items-center justify-center mb-6",
              isDark ? "bg-white/5" : "bg-black/5",
            )}
          >
            <Ionicons
              name="checkmark-circle"
              size={40}
              color={isDark ? "#22c55e" : "#16a34a"}
            />
          </Animated.View>
          <Text
            className={cn(
              "text-xl font-semibold text-center mb-2",
              isDark ? "text-white" : "text-slate-900",
            )}
          >
            No Suggestions
          </Text>
          <Text
            className={cn(
              "text-base text-center",
              isDark ? "text-slate-500" : "text-slate-400",
            )}
          >
            Your photos look good! No blurry or low-quality photos detected.
          </Text>
        </View>
      ) : (
        <FlatList
          data={suggestedPhotos}
          renderItem={renderPhoto}
          keyExtractor={keyExtractor}
          numColumns={NUM_COLUMNS}
          contentContainerStyle={{
            paddingHorizontal: SPACING / 2,
            paddingTop: SPACING,
            paddingBottom: insets.bottom + 20,
          }}
          showsVerticalScrollIndicator={false}
        />
      )}
    </View>
  );
}
