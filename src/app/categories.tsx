import React, { useEffect, useState, useCallback } from "react";
import {
  View,
  Text,
  ScrollView,
  ActivityIndicator,
  Dimensions,
} from "react-native";
import { Image } from "expo-image";
import { useRouter, useFocusEffect } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useColorScheme } from "@/lib/useColorScheme";
import { cn } from "@/lib/cn";
import * as MediaLibrary from "expo-media-library";
import { Ionicons, MaterialIcons, Feather } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { formatBytes } from "@/lib/state/gallery-store";
import { AnimatedPressable } from "@/components/AnimatedPressable";
import Animated, {
  FadeInDown,
  FadeIn,
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  withSequence,
  interpolate,
  Extrapolation,
} from "react-native-reanimated";

const { width } = Dimensions.get("window");
const CARD_WIDTH = (width - 48) / 2;

interface Category {
  id: string;
  name: string;
  icon: string;
  iconFamily: "Ionicons" | "MaterialIcons" | "Feather";
  count: number;
  size: number;
  thumbnail?: string;
  gradient: [string, string];
  filter: {
    mediaType?: MediaLibrary.MediaTypeValue[];
    mediaSubtype?: string[];
  };
}

const CATEGORY_DEFINITIONS: Omit<Category, "count" | "size" | "thumbnail">[] = [
  {
    id: "screenshots",
    name: "Screenshots",
    icon: "phone-portrait-outline",
    iconFamily: "Ionicons",
    gradient: ["#667eea", "#764ba2"],
    filter: { mediaSubtype: ["screenshot"] },
  },
  {
    id: "selfies",
    name: "Selfies",
    icon: "camera-reverse-outline",
    iconFamily: "Ionicons",
    gradient: ["#f093fb", "#f5576c"],
    filter: { mediaSubtype: ["selfie"] },
  },
  {
    id: "videos",
    name: "Videos",
    icon: "videocam-outline",
    iconFamily: "Ionicons",
    gradient: ["#4facfe", "#00f2fe"],
    filter: { mediaType: [MediaLibrary.MediaType.video] },
  },
  {
    id: "live",
    name: "Live Photos",
    icon: "radio-button-on-outline",
    iconFamily: "Ionicons",
    gradient: ["#43e97b", "#38f9d7"],
    filter: { mediaSubtype: ["livePhoto"] },
  },
  {
    id: "burst",
    name: "Burst Photos",
    icon: "layers-outline",
    iconFamily: "Ionicons",
    gradient: ["#fa709a", "#fee140"],
    filter: { mediaSubtype: ["burst"] },
  },
  {
    id: "panoramas",
    name: "Panoramas",
    icon: "panorama-horizontal",
    iconFamily: "MaterialIcons",
    gradient: ["#a8edea", "#fed6e3"],
    filter: { mediaSubtype: ["panorama"] },
  },
  {
    id: "hdr",
    name: "HDR Photos",
    icon: "hdr",
    iconFamily: "MaterialIcons",
    gradient: ["#ffecd2", "#fcb69f"],
    filter: { mediaSubtype: ["hdr"] },
  },
  {
    id: "recent",
    name: "Recent",
    icon: "time-outline",
    iconFamily: "Ionicons",
    gradient: ["#89f7fe", "#66a6ff"],
    filter: {},
  },
];

interface CategoryCardProps {
  category: Category;
  onPress: () => void;
  isDark: boolean;
  index: number;
}

function CategoryCard({ category, onPress, isDark, index }: CategoryCardProps) {
  const IconComponent =
    category.iconFamily === "Ionicons"
      ? Ionicons
      : category.iconFamily === "MaterialIcons"
        ? MaterialIcons
        : Feather;

  const pulseScale = useSharedValue(1);
  
  useEffect(() => {
    if (category.count > 0) {
      pulseScale.value = withSequence(
        withSpring(1.1, { damping: 8 }),
        withSpring(1, { damping: 12 })
      );
    }
  }, [category.count]);

  const badgeAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: pulseScale.value }],
  }));

  return (
    <Animated.View
      entering={FadeInDown.delay(index * 80).springify()}
      style={{ width: CARD_WIDTH }}
      className="mb-4"
    >
      <AnimatedPressable
        onPress={onPress}
        scaleValue={0.97}
      >
        <View
          className={cn(
            "rounded-2xl overflow-hidden",
            isDark ? "bg-gray-800" : "bg-white",
          )}
          style={{
            shadowColor: "#000",
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: isDark ? 0.3 : 0.1,
            shadowRadius: 12,
            elevation: 6,
          }}
        >
          {/* Thumbnail or Gradient Background */}
          <View className="h-28 relative overflow-hidden">
            {category.thumbnail ? (
              <Image
                source={{ uri: category.thumbnail }}
                style={{ width: "100%", height: "100%" }}
                contentFit="cover"
                transition={300}
              />
            ) : (
              <LinearGradient
                colors={category.gradient}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={{ width: "100%", height: "100%" }}
              />
            )}

            {/* Overlay with icon */}
            <View className="absolute inset-0 items-center justify-center">
              <View className="w-14 h-14 rounded-full bg-white/20 items-center justify-center backdrop-blur">
                <IconComponent
                  name={category.icon as any}
                  size={28}
                  color="white"
                />
              </View>
            </View>

            {/* Count badge with pulse animation */}
            <Animated.View 
              style={badgeAnimatedStyle}
              className="absolute top-2 right-2 bg-black/50 px-2.5 py-1 rounded-full"
            >
              <Text className="text-white text-xs font-bold">
                {category.count}
              </Text>
            </Animated.View>
          </View>

          {/* Info section */}
          <View className="p-3">
            <Text
              className={cn(
                "text-base font-semibold",
                isDark ? "text-white" : "text-gray-900",
              )}
            >
              {category.name}
            </Text>
            <Text
              className={cn(
                "text-sm mt-0.5",
                isDark ? "text-gray-400" : "text-gray-500",
              )}
            >
              {formatBytes(category.size)}
            </Text>
          </View>
        </View>
      </AnimatedPressable>
    </Animated.View>
  );
}

export default function CategoriesScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";

  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [totalPhotos, setTotalPhotos] = useState(0);
  const [totalSize, setTotalSize] = useState(0);

  const loadCategories = useCallback(async () => {
    try {
      const { status } = await MediaLibrary.requestPermissionsAsync();
      if (status !== "granted") {
        setIsLoading(false);
        return;
      }

      const loadedCategories: Category[] = [];

      for (const def of CATEGORY_DEFINITIONS) {
        let assets: MediaLibrary.Asset[] = [];
        let totalCategorySize = 0;

        if (def.id === "recent") {
          // Get photos from last 7 days
          const weekAgo = Date.now() - 7 * 24 * 60 * 60 * 1000;
          const result = await MediaLibrary.getAssetsAsync({
            first: 100,
            mediaType: [
              MediaLibrary.MediaType.photo,
              MediaLibrary.MediaType.video,
            ],
            createdAfter: weekAgo,
            sortBy: [MediaLibrary.SortBy.creationTime],
          });
          assets = result.assets;
        } else if (def.filter.mediaType) {
          const result = await MediaLibrary.getAssetsAsync({
            first: 1000,
            mediaType: def.filter.mediaType,
            sortBy: [MediaLibrary.SortBy.creationTime],
          });
          assets = result.assets;
        } else {
          // For subtypes like screenshots, selfies, etc., we fetch all and filter
          const result = await MediaLibrary.getAssetsAsync({
            first: 1000,
            mediaType: [MediaLibrary.MediaType.photo],
            sortBy: [MediaLibrary.SortBy.creationTime],
          });

          // Filter by filename pattern for screenshots
          if (def.id === "screenshots") {
            assets = result.assets.filter(
              (a) =>
                a.filename.toLowerCase().includes("screenshot") ||
                a.filename.toLowerCase().includes("screen shot"),
            );
          } else {
            assets = result.assets;
          }
        }

        // Calculate size (estimate based on dimensions)
        for (const asset of assets) {
          const estimatedSize = (asset.width * asset.height * 3) / 4; // rough JPEG estimate
          totalCategorySize += estimatedSize;
        }

        loadedCategories.push({
          ...def,
          count: assets.length,
          size: totalCategorySize,
          thumbnail: assets[0]?.uri,
        });
      }

      // Calculate totals
      const allPhotos = await MediaLibrary.getAssetsAsync({
        first: 1,
        mediaType: [MediaLibrary.MediaType.photo, MediaLibrary.MediaType.video],
      });
      setTotalPhotos(allPhotos.totalCount);

      setCategories(loadedCategories);
      setTotalSize(loadedCategories.reduce((acc, c) => acc + c.size, 0));
      setIsLoading(false);
    } catch (error) {
      console.error("Error loading categories:", error);
      setIsLoading(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      loadCategories();
    }, [loadCategories])
  );

  const handleCategoryPress = (category: Category) => {
    // Navigate to library with filter applied
    router.push({
      pathname: "/(tabs)",
      params: {
        filterType: category.id,
        filterName: category.name,
      },
    });
  };

  if (isLoading) {
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
          Analyzing your photos...
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
            Categories
          </Animated.Text>
          <View className="w-10" />
        </View>

        {/* Summary Stats */}
        <Animated.View 
          entering={FadeInDown.delay(150).springify()}
          className="flex-row mt-4 gap-4"
        >
          <View
            className={cn(
              "flex-1 p-3 rounded-xl",
              isDark ? "bg-gray-800" : "bg-gray-100",
            )}
          >
            <Text
              className={cn(
                "text-2xl font-bold",
                isDark ? "text-white" : "text-gray-900",
              )}
            >
              {totalPhotos.toLocaleString()}
            </Text>
            <Text
              className={cn(
                "text-sm",
                isDark ? "text-gray-400" : "text-gray-500",
              )}
            >
              Total Items
            </Text>
          </View>
          <View
            className={cn(
              "flex-1 p-3 rounded-xl",
              isDark ? "bg-gray-800" : "bg-gray-100",
            )}
          >
            <Text
              className={cn(
                "text-2xl font-bold",
                isDark ? "text-white" : "text-gray-900",
              )}
            >
              {categories.length}
            </Text>
            <Text
              className={cn(
                "text-sm",
                isDark ? "text-gray-400" : "text-gray-500",
              )}
            >
              Categories
            </Text>
          </View>
        </Animated.View>
      </Animated.View>

      {/* Categories Grid */}
      <ScrollView
        className="flex-1 px-4 pt-4"
        contentContainerStyle={{ paddingBottom: insets.bottom + 100 }}
        showsVerticalScrollIndicator={false}
      >
        <View className="flex-row flex-wrap justify-between">
          {categories.map((category, index) => (
            <CategoryCard
              key={category.id}
              category={category}
              onPress={() => handleCategoryPress(category)}
              isDark={isDark}
              index={index}
            />
          ))}
        </View>

        {/* All Photos Card */}
        <Animated.View entering={FadeInDown.delay(700).springify()}>
          <AnimatedPressable
            onPress={() => router.push("/(tabs)")}
            scaleValue={0.98}
            className={cn(
              "mt-2 p-4 rounded-2xl flex-row items-center justify-between",
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
            <View className="flex-row items-center">
              <View
                className="w-12 h-12 rounded-xl items-center justify-center"
                style={{ backgroundColor: isDark ? "#374151" : "#f3f4f6" }}
              >
                <Ionicons
                  name="images"
                  size={24}
                  color={isDark ? "#60a5fa" : "#3b82f6"}
                />
              </View>
              <View className="ml-3">
                <Text
                  className={cn(
                    "text-base font-semibold",
                    isDark ? "text-white" : "text-gray-900",
                  )}
                >
                  All Photos
                </Text>
                <Text
                  className={cn(
                    "text-sm",
                    isDark ? "text-gray-400" : "text-gray-500",
                  )}
                >
                  {totalPhotos.toLocaleString()} items • {formatBytes(totalSize)}
                </Text>
              </View>
            </View>
            <Ionicons
              name="chevron-forward"
              size={20}
              color={isDark ? "#6b7280" : "#9ca3af"}
            />
          </AnimatedPressable>
        </Animated.View>
      </ScrollView>
    </View>
  );
}
