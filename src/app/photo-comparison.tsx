import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  Pressable,
  Dimensions,
  Image,
  ActivityIndicator,
  ScrollView,
} from "react-native";
import { useRouter, useLocalSearchParams } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useColorScheme } from "@/lib/useColorScheme";
import { useGalleryStore } from "@/lib/state/gallery-store";
import * as MediaLibrary from "expo-media-library";
import * as Haptics from "expo-haptics";
import { cn } from "@/lib/cn";
import { Ionicons } from "@expo/vector-icons";
import { Image as ExpoImage } from "expo-image";
import { Gesture, GestureDetector } from "react-native-gesture-handler";
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withTiming,
} from "react-native-reanimated";

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get("window");
const IMAGE_WIDTH = SCREEN_WIDTH / 2 - 24;

export default function PhotoComparisonScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";
  const params = useLocalSearchParams<{ photo1: string; photo2: string }>();

  const [photo1, setPhoto1] = useState<MediaLibrary.Asset | null>(null);
  const [photo2, setPhoto2] = useState<MediaLibrary.Asset | null>(null);
  const [loading, setLoading] = useState(true);
  const [zoom1, setZoom1] = useState(1);
  const [zoom2, setZoom2] = useState(1);
  const [syncZoom, setSyncZoom] = useState(true);

  const addToDeleteQueue = useGalleryStore((s) => s.addToDeleteQueue);
  const removeFromDeleteQueue = useGalleryStore((s) => s.removeFromDeleteQueue);
  const isInDeleteQueue = useGalleryStore((s) => s.isInDeleteQueue);

  useEffect(() => {
    loadPhotos();
  }, [params.photo1, params.photo2]);

  const loadPhotos = async () => {
    try {
      setLoading(true);
      const [asset1, asset2] = await Promise.all([
        MediaLibrary.getAssetInfoAsync(params.photo1),
        MediaLibrary.getAssetInfoAsync(params.photo2),
      ]);
      setPhoto1(asset1);
      setPhoto2(asset2);
    } catch (error) {
      console.error("Error loading photos:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    router.back();
  };

  const handleToggleDelete = (photoId: string) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    if (isInDeleteQueue(photoId)) {
      removeFromDeleteQueue(photoId);
    } else {
      addToDeleteQueue(photoId);
    }
  };

  const handleZoom = (side: "left" | "right", delta: number) => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    if (side === "left") {
      const newZoom = Math.max(1, Math.min(3, zoom1 + delta));
      setZoom1(newZoom);
      if (syncZoom) {
        setZoom2(newZoom);
      }
    } else {
      const newZoom = Math.max(1, Math.min(3, zoom2 + delta));
      setZoom2(newZoom);
      if (syncZoom) {
        setZoom1(newZoom);
      }
    }
  };

  const handleResetZoom = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setZoom1(1);
    setZoom2(1);
  };

  if (loading || !photo1 || !photo2) {
    return (
      <View
        className={cn(
          "flex-1 items-center justify-center",
          isDark ? "bg-black" : "bg-slate-50",
        )}
      >
        <ActivityIndicator
          size="large"
          color={isDark ? "#60a5fa" : "#3b82f6"}
        />
      </View>
    );
  }

  const isPhoto1Queued = isInDeleteQueue(photo1.id);
  const isPhoto2Queued = isInDeleteQueue(photo2.id);

  return (
    <View className={cn("flex-1", isDark ? "bg-black" : "bg-slate-50")}>
      {/* Header */}
      <View
        className={cn(
          "absolute top-0 left-0 right-0 z-10 flex-row items-center justify-between px-4",
          isDark ? "bg-black/90" : "bg-slate-50/90",
        )}
        style={{ paddingTop: insets.top + 8, paddingBottom: 12 }}
      >
        <Pressable
          onPress={handleClose}
          className={cn(
            "w-10 h-10 rounded-full items-center justify-center",
            isDark ? "bg-white/10" : "bg-black/5",
          )}
        >
          <Ionicons
            name="chevron-back"
            size={24}
            color={isDark ? "#fff" : "#1e293b"}
          />
        </Pressable>

        <Text
          className={cn(
            "text-base font-semibold",
            isDark ? "text-white" : "text-slate-900",
          )}
        >
          Compare Photos
        </Text>

        <Pressable
          onPress={() => setSyncZoom(!syncZoom)}
          className={cn(
            "px-3 py-1.5 rounded-full",
            syncZoom ? "bg-blue-500" : isDark ? "bg-white/10" : "bg-black/5",
          )}
        >
          <Text
            className={cn(
              "text-xs font-medium",
              syncZoom
                ? "text-white"
                : isDark
                  ? "text-slate-300"
                  : "text-slate-600",
            )}
          >
            Sync
          </Text>
        </Pressable>
      </View>

      {/* Comparison View */}
      <ScrollView
        className="flex-1"
        contentContainerStyle={{
          paddingTop: insets.top + 60,
          paddingBottom: insets.bottom + 100,
        }}
        showsVerticalScrollIndicator={false}
      >
        <View className="flex-row px-3 gap-3">
          {/* Left Photo */}
          <View className="flex-1">
            <View
              className={cn(
                "rounded-2xl overflow-hidden mb-3",
                isPhoto1Queued && "border-2 border-red-500",
              )}
            >
              <ExpoImage
                source={{ uri: photo1.uri }}
                style={{
                  width: IMAGE_WIDTH,
                  height: (IMAGE_WIDTH * photo1.height) / photo1.width,
                }}
                contentFit="contain"
                transition={200}
              />
            </View>
            <View className="flex-row items-center justify-between mb-2">
              <Text
                className={cn(
                  "text-xs font-medium",
                  isDark ? "text-slate-400" : "text-slate-500",
                )}
              >
                {photo1.width} × {photo1.height}
              </Text>
              <View className="flex-row items-center gap-2">
                <Pressable
                  onPress={() => handleZoom("left", -0.2)}
                  className={cn(
                    "w-8 h-8 rounded-full items-center justify-center",
                    isDark ? "bg-white/10" : "bg-black/5",
                  )}
                >
                  <Ionicons
                    name="remove-circle"
                    size={16}
                    color={isDark ? "#fff" : "#1e293b"}
                  />
                </Pressable>
                <Text
                  className={cn(
                    "text-xs font-medium w-12 text-center",
                    isDark ? "text-slate-300" : "text-slate-600",
                  )}
                >
                  {Math.round(zoom1 * 100)}%
                </Text>
                <Pressable
                  onPress={() => handleZoom("left", 0.2)}
                  className={cn(
                    "w-8 h-8 rounded-full items-center justify-center",
                    isDark ? "bg-white/10" : "bg-black/5",
                  )}
                >
                  <Ionicons
                    name="add-circle"
                    size={16}
                    color={isDark ? "#fff" : "#1e293b"}
                  />
                </Pressable>
              </View>
            </View>
            <Pressable
              onPress={() => handleToggleDelete(photo1.id)}
              className={cn(
                "py-2.5 rounded-xl items-center",
                isPhoto1Queued
                  ? "bg-red-500"
                  : isDark
                    ? "bg-white/10"
                    : "bg-black/5",
              )}
            >
              <Ionicons
                name="close"
                size={18}
                color={isPhoto1Queued ? "#fff" : isDark ? "#fff" : "#1e293b"}
              />
              <Text
                className={cn(
                  "text-xs font-medium mt-1",
                  isPhoto1Queued
                    ? "text-white"
                    : isDark
                      ? "text-slate-300"
                      : "text-slate-600",
                )}
              >
                {isPhoto1Queued ? "Remove" : "Delete"}
              </Text>
            </Pressable>
          </View>

          {/* Right Photo */}
          <View className="flex-1">
            <View
              className={cn(
                "rounded-2xl overflow-hidden mb-3",
                isPhoto2Queued && "border-2 border-red-500",
              )}
            >
              <ExpoImage
                source={{ uri: photo2.uri }}
                style={{
                  width: IMAGE_WIDTH,
                  height: (IMAGE_WIDTH * photo2.height) / photo2.width,
                }}
                contentFit="contain"
                transition={200}
              />
            </View>
            <View className="flex-row items-center justify-between mb-2">
              <Text
                className={cn(
                  "text-xs font-medium",
                  isDark ? "text-slate-400" : "text-slate-500",
                )}
              >
                {photo2.width} × {photo2.height}
              </Text>
              <View className="flex-row items-center gap-2">
                <Pressable
                  onPress={() => handleZoom("right", -0.2)}
                  className={cn(
                    "w-8 h-8 rounded-full items-center justify-center",
                    isDark ? "bg-white/10" : "bg-black/5",
                  )}
                >
                  <Ionicons
                    name="remove-circle"
                    size={16}
                    color={isDark ? "#fff" : "#1e293b"}
                  />
                </Pressable>
                <Text
                  className={cn(
                    "text-xs font-medium w-12 text-center",
                    isDark ? "text-slate-300" : "text-slate-600",
                  )}
                >
                  {Math.round(zoom2 * 100)}%
                </Text>
                <Pressable
                  onPress={() => handleZoom("right", 0.2)}
                  className={cn(
                    "w-8 h-8 rounded-full items-center justify-center",
                    isDark ? "bg-white/10" : "bg-black/5",
                  )}
                >
                  <Ionicons
                    name="add-circle"
                    size={16}
                    color={isDark ? "#fff" : "#1e293b"}
                  />
                </Pressable>
              </View>
            </View>
            <Pressable
              onPress={() => handleToggleDelete(photo2.id)}
              className={cn(
                "py-2.5 rounded-xl items-center",
                isPhoto2Queued
                  ? "bg-red-500"
                  : isDark
                    ? "bg-white/10"
                    : "bg-black/5",
              )}
            >
              <Ionicons
                name="close"
                size={18}
                color={isPhoto2Queued ? "#fff" : isDark ? "#fff" : "#1e293b"}
              />
              <Text
                className={cn(
                  "text-xs font-medium mt-1",
                  isPhoto2Queued
                    ? "text-white"
                    : isDark
                      ? "text-slate-300"
                      : "text-slate-600",
                )}
              >
                {isPhoto2Queued ? "Remove" : "Delete"}
              </Text>
            </Pressable>
          </View>
        </View>
      </ScrollView>

      {/* Bottom Controls */}
      <View
        className={cn(
          "absolute bottom-0 left-0 right-0 flex-row items-center justify-center gap-4 px-4",
          isDark ? "bg-black/90" : "bg-slate-50/90",
        )}
        style={{ paddingBottom: insets.bottom + 16, paddingTop: 16 }}
      >
        <Pressable
          onPress={handleResetZoom}
          className={cn(
            "px-4 py-2.5 rounded-xl flex-row items-center",
            isDark ? "bg-white/10" : "bg-black/5",
          )}
        >
          <Ionicons
            name="refresh"
            size={16}
            color={isDark ? "#fff" : "#1e293b"}
          />
          <Text
            className={cn(
              "text-sm font-medium ml-2",
              isDark ? "text-white" : "text-slate-900",
            )}
          >
            Reset Zoom
          </Text>
        </Pressable>
      </View>
    </View>
  );
}
