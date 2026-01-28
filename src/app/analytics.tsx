import React, { useEffect, useState, useCallback } from "react";
import {
  View,
  Text,
  ScrollView,
  ActivityIndicator,
  Dimensions,
} from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useColorScheme } from "@/lib/useColorScheme";
import { cn } from "@/lib/cn";
import * as MediaLibrary from "expo-media-library";
import { Ionicons, MaterialCommunityIcons, Feather } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { formatBytes, useGalleryStore } from "@/lib/state/gallery-store";
import { useStorageStats } from "@/lib/hooks/useStorageStats";
import { AnimatedPressable } from "@/components/AnimatedPressable";
import Animated, {
  FadeInDown,
  FadeIn,
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSpring,
  interpolate,
  Easing,
} from "react-native-reanimated";

const { width } = Dimensions.get("window");

interface StatCardProps {
  title: string;
  value: string;
  subtitle?: string;
  icon: React.ReactNode;
  gradient: [string, string];
  onPress?: () => void;
  index: number;
}

function StatCard({
  title,
  value,
  subtitle,
  icon,
  gradient,
  onPress,
  index,
}: StatCardProps) {
  return (
    <Animated.View
      entering={FadeInDown.delay(index * 100).springify()}
      style={{ width: (width - 48) / 2 }}
      className="mb-4"
    >
      <AnimatedPressable
        onPress={onPress}
        scaleValue={0.97}
        hapticFeedback={onPress ? "light" : "none"}
        disabled={!onPress}
      >
        <LinearGradient
          colors={gradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          className="p-4 rounded-2xl"
          style={{ 
            minHeight: 120,
            shadowColor: gradient[0],
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: 0.3,
            shadowRadius: 8,
          }}
        >
          <View className="w-10 h-10 rounded-xl bg-white/20 items-center justify-center mb-3">
            {icon}
          </View>
          <Text className="text-white/70 text-sm font-medium">{title}</Text>
          <Text className="text-white text-2xl font-bold mt-1">{value}</Text>
          {subtitle && (
            <Text className="text-white/60 text-xs mt-1">{subtitle}</Text>
          )}
        </LinearGradient>
      </AnimatedPressable>
    </Animated.View>
  );
}

interface ActionButtonProps {
  title: string;
  subtitle: string;
  icon: React.ReactNode;
  onPress: () => void;
  isDark: boolean;
  index: number;
}

function ActionButton({
  title,
  subtitle,
  icon,
  onPress,
  isDark,
  index,
}: ActionButtonProps) {
  return (
    <Animated.View entering={FadeInDown.delay(300 + index * 80).springify()}>
      <AnimatedPressable
        onPress={onPress}
        scaleValue={0.98}
        className={cn(
          "flex-row items-center p-4 rounded-2xl mb-3",
          isDark ? "bg-gray-800" : "bg-white",
        )}
        style={{
          shadowColor: "#000",
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDark ? 0.3 : 0.1,
          shadowRadius: 8,
          elevation: 4,
        }}
      >
        <View
          className={cn(
            "w-12 h-12 rounded-xl items-center justify-center mr-4",
            isDark ? "bg-gray-700" : "bg-gray-100",
          )}
        >
          {icon}
        </View>
        <View className="flex-1">
          <Text
            className={cn(
              "text-base font-semibold",
              isDark ? "text-white" : "text-gray-900",
            )}
          >
            {title}
          </Text>
          <Text
            className={cn("text-sm", isDark ? "text-gray-400" : "text-gray-500")}
          >
            {subtitle}
          </Text>
        </View>
        <Ionicons
          name="chevron-forward"
          size={20}
          color={isDark ? "#6b7280" : "#9ca3af"}
        />
      </AnimatedPressable>
    </Animated.View>
  );
}

interface AnimatedProgressRingProps {
  progress: number;
  size: number;
  strokeWidth: number;
  color: string;
  delay?: number;
}

function AnimatedProgressRing({ 
  progress, 
  size, 
  strokeWidth, 
  color, 
  delay = 0 
}: AnimatedProgressRingProps) {
  const animatedProgress = useSharedValue(0);
  
  useEffect(() => {
    animatedProgress.value = withDelay(
      delay,
      withTiming(progress, { duration: 1000, easing: Easing.bezier(0.25, 0.1, 0.25, 1) })
    );
  }, [progress]);

  const animatedStyle = useAnimatedStyle(() => {
    const rotation = animatedProgress.value * 360;
    return {
      transform: [{ rotate: `${rotation}deg` }],
    };
  });

  const circumference = 2 * Math.PI * ((size - strokeWidth) / 2);
  const radius = (size - strokeWidth) / 2;

  return (
    <View style={{ width: size, height: size }}>
      {/* Background circle */}
      <View
        style={{
          position: 'absolute',
          width: size,
          height: size,
          borderRadius: size / 2,
          borderWidth: strokeWidth,
          borderColor: 'rgba(255,255,255,0.1)',
        }}
      />
      {/* Progress arc (simplified) */}
      <View
        style={{
          position: 'absolute',
          width: size,
          height: size,
          borderRadius: size / 2,
          borderWidth: strokeWidth,
          borderColor: color,
          borderTopColor: 'transparent',
          borderRightColor: 'transparent',
          transform: [{ rotate: `${progress * 360}deg` }],
        }}
      />
    </View>
  );
}

export default function AnalyticsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";

  const storageStats = useStorageStats();
  const recentlyDeleted = useGalleryStore((s) => s.recentlyDeleted);
  const deleteQueue = useGalleryStore((s) => s.deleteQueue);

  const [photoStats, setPhotoStats] = useState({
    totalPhotos: 0,
    totalVideos: 0,
    screenshotsCount: 0,
    deletedThisMonth: 0,
    savedStorage: 0,
  });
  const [isLoading, setIsLoading] = useState(true);

  const loadAnalytics = useCallback(async () => {
    try {
      const { status } = await MediaLibrary.requestPermissionsAsync();
      if (status !== "granted") {
        setIsLoading(false);
        return;
      }

      // Get photo count
      const photos = await MediaLibrary.getAssetsAsync({
        first: 1,
        mediaType: [MediaLibrary.MediaType.photo],
      });

      // Get video count
      const videos = await MediaLibrary.getAssetsAsync({
        first: 1,
        mediaType: [MediaLibrary.MediaType.video],
      });

      // Estimate screenshots (by filename)
      const allPhotos = await MediaLibrary.getAssetsAsync({
        first: 500,
        mediaType: [MediaLibrary.MediaType.photo],
      });
      const screenshots = allPhotos.assets.filter((a) =>
        a.filename.toLowerCase().includes("screenshot"),
      );

      // Calculate saved storage from recently deleted
      const savedStorage = recentlyDeleted.reduce((acc, item) => {
        const size =
          item.asset?.width && item.asset?.height
            ? (item.asset.width * item.asset.height * 3) / 4
            : 0;
        return acc + size;
      }, 0);

      setPhotoStats({
        totalPhotos: photos.totalCount,
        totalVideos: videos.totalCount,
        screenshotsCount: screenshots.length,
        deletedThisMonth: recentlyDeleted.length,
        savedStorage,
      });

      setIsLoading(false);
    } catch (error) {
      console.error("Error loading analytics:", error);
      setIsLoading(false);
    }
  }, [recentlyDeleted]);

  useEffect(() => {
    loadAnalytics();
  }, [loadAnalytics]);

  if (isLoading || storageStats.loading) {
    return (
      <View
        className={cn(
          "flex-1 items-center justify-center",
          isDark ? "bg-black" : "bg-gray-50",
        )}
      >
        <ActivityIndicator
          size="large"
          color={isDark ? "#60a5fa" : "#3b82f6"}
        />
        <Text
          className={cn("mt-4", isDark ? "text-gray-400" : "text-gray-500")}
        >
          Loading analytics...
        </Text>
      </View>
    );
  }

  return (
    <View className={cn("flex-1", isDark ? "bg-black" : "bg-gray-50")}>
      {/* Header */}
      <Animated.View
        entering={FadeIn.duration(400)}
        style={{ paddingTop: insets.top }}
        className={cn("px-4 pb-4", isDark ? "bg-black" : "bg-white")}
      >
        <View className="flex-row items-center justify-between mt-4">
          <AnimatedPressable
            onPress={() => router.back()}
            className="w-10 h-10 items-center justify-center rounded-full"
            style={{ backgroundColor: isDark ? "#1f2937" : "#f3f4f6" }}
            scaleValue={0.9}
          >
            <Ionicons
              name="arrow-back"
              size={22}
              color={isDark ? "#fff" : "#000"}
            />
          </AnimatedPressable>
          <Animated.Text
            entering={FadeInDown.delay(100).springify()}
            className={cn(
              "text-xl font-bold",
              isDark ? "text-white" : "text-gray-900",
            )}
          >
            Analytics
          </Animated.Text>
          <View className="w-10" />
        </View>
      </Animated.View>

      <ScrollView
        className="flex-1 px-4"
        contentContainerStyle={{ paddingBottom: insets.bottom + 32 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Storage Overview */}
        <View className="mt-4 mb-2">
          <Animated.Text
            entering={FadeInDown.delay(150).springify()}
            className={cn(
              "text-lg font-semibold mb-3",
              isDark ? "text-white" : "text-gray-900",
            )}
          >
            Storage Overview
          </Animated.Text>
          <View className="flex-row flex-wrap justify-between">
            <StatCard
              title="Total Photos"
              value={photoStats.totalPhotos.toLocaleString()}
              icon={<Ionicons name="images" size={22} color="white" />}
              gradient={["#667eea", "#764ba2"]}
              index={0}
            />
            <StatCard
              title="Total Videos"
              value={photoStats.totalVideos.toLocaleString()}
              icon={<Ionicons name="videocam" size={22} color="white" />}
              gradient={["#4facfe", "#00f2fe"]}
              index={1}
            />
            <StatCard
              title="Screenshots"
              value={photoStats.screenshotsCount.toLocaleString()}
              subtitle="Tap to view"
              icon={<Ionicons name="phone-portrait" size={22} color="white" />}
              gradient={["#fa709a", "#fee140"]}
              onPress={() => router.push("/smart-collections")}
              index={2}
            />
            <StatCard
              title="In Queue"
              value={deleteQueue.length.toString()}
              subtitle="Ready to delete"
              icon={<Feather name="trash-2" size={22} color="white" />}
              gradient={["#f093fb", "#f5576c"]}
              onPress={() => router.push("/(tabs)/queue")}
              index={3}
            />
          </View>
        </View>

        {/* Cleanup Stats */}
        <View className="mt-4 mb-2">
          <Animated.Text
            entering={FadeInDown.delay(200).springify()}
            className={cn(
              "text-lg font-semibold mb-3",
              isDark ? "text-white" : "text-gray-900",
            )}
          >
            Cleanup Progress
          </Animated.Text>

          <Animated.View
            entering={FadeInDown.delay(250).springify()}
            className={cn(
              "p-4 rounded-2xl mb-4",
              isDark ? "bg-gray-800" : "bg-white",
            )}
            style={{
              shadowColor: "#000",
              shadowOffset: { width: 0, height: 2 },
              shadowOpacity: isDark ? 0.3 : 0.1,
              shadowRadius: 8,
              elevation: 4,
            }}
          >
            <View className="flex-row items-center justify-between mb-4">
              <View>
                <Text
                  className={cn(
                    "text-sm",
                    isDark ? "text-gray-400" : "text-gray-500",
                  )}
                >
                  Deleted This Month
                </Text>
                <Text
                  className={cn(
                    "text-3xl font-bold",
                    isDark ? "text-white" : "text-gray-900",
                  )}
                >
                  {photoStats.deletedThisMonth}
                </Text>
              </View>
              <Animated.View
                entering={FadeIn.delay(500)}
                className="w-16 h-16 rounded-full items-center justify-center"
                style={{ backgroundColor: isDark ? "#374151" : "#f3f4f6" }}
              >
                <MaterialCommunityIcons
                  name="delete-sweep"
                  size={32}
                  color={isDark ? "#60a5fa" : "#3b82f6"}
                />
              </Animated.View>
            </View>

            <View className="flex-row justify-between">
              <View>
                <Text
                  className={cn(
                    "text-sm",
                    isDark ? "text-gray-400" : "text-gray-500",
                  )}
                >
                  Storage Saved
                </Text>
                <Text className={cn("text-xl font-bold text-green-500")}>
                  {formatBytes(photoStats.savedStorage)}
                </Text>
              </View>
              <View>
                <Text
                  className={cn(
                    "text-sm text-right",
                    isDark ? "text-gray-400" : "text-gray-500",
                  )}
                >
                  In Trash
                </Text>
                <Text
                  className={cn(
                    "text-xl font-bold text-right",
                    isDark ? "text-white" : "text-gray-900",
                  )}
                >
                  {recentlyDeleted.length}
                </Text>
              </View>
            </View>
          </Animated.View>
        </View>

        {/* Quick Actions */}
        <View className="mt-4">
          <Animated.Text
            entering={FadeInDown.delay(250).springify()}
            className={cn(
              "text-lg font-semibold mb-3",
              isDark ? "text-white" : "text-gray-900",
            )}
          >
            Quick Actions
          </Animated.Text>

          <ActionButton
            title="Find Duplicates"
            subtitle="Scan for duplicate photos"
            icon={
              <Ionicons
                name="copy"
                size={24}
                color={isDark ? "#60a5fa" : "#3b82f6"}
              />
            }
            onPress={() => router.push("/duplicates")}
            isDark={isDark}
            index={0}
          />

          <ActionButton
            title="AI Suggestions"
            subtitle="Get smart cleanup recommendations"
            icon={
              <MaterialCommunityIcons
                name="robot"
                size={24}
                color={isDark ? "#60a5fa" : "#3b82f6"}
              />
            }
            onPress={() => router.push("/ai-suggestions")}
            isDark={isDark}
            index={1}
          />

          <ActionButton
            title="View Categories"
            subtitle="Organize by photo type"
            icon={
              <Ionicons
                name="folder"
                size={24}
                color={isDark ? "#60a5fa" : "#3b82f6"}
              />
            }
            onPress={() => router.push("/categories")}
            isDark={isDark}
            index={2}
          />

          <ActionButton
            title="Recently Deleted"
            subtitle={`${recentlyDeleted.length} items in trash`}
            icon={
              <Ionicons
                name="trash"
                size={24}
                color={isDark ? "#60a5fa" : "#3b82f6"}
              />
            }
            onPress={() => router.push("/recently-deleted")}
            isDark={isDark}
            index={3}
          />
        </View>
      </ScrollView>
    </View>
  );
}
