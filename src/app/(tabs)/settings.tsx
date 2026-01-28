import React from "react";
import { View, Text, ScrollView, Linking } from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { useColorScheme } from "@/lib/useColorScheme";
import { cn } from "@/lib/cn";
import { Ionicons, Feather, MaterialIcons } from "@expo/vector-icons";
import { StatisticsCard } from "@/components/StatisticsCard";
import { AnimatedPressable } from "@/components/AnimatedPressable";
import Animated, { FadeInDown, FadeIn } from "react-native-reanimated";

interface SettingsItemProps {
  icon: React.ReactNode;
  label: string;
  onPress: () => void;
  isDark: boolean;
  showChevron?: boolean;
  destructive?: boolean;
  index?: number;
}

function SettingsItem({
  icon,
  label,
  onPress,
  isDark,
  showChevron = true,
  destructive = false,
  index = 0,
}: SettingsItemProps) {
  return (
    <AnimatedPressable
      onPress={onPress}
      scaleValue={0.98}
      hapticFeedback="light"
      className={cn(
        "flex-row items-center px-4 py-3.5",
        isDark ? "bg-white/5" : "bg-white",
      )}
    >
      <View
        className={cn(
          "w-9 h-9 rounded-lg items-center justify-center mr-3",
          destructive
            ? "bg-red-500/10"
            : isDark
              ? "bg-white/10"
              : "bg-slate-100",
        )}
      >
        {icon}
      </View>
      <Text
        className={cn(
          "flex-1 text-base",
          destructive
            ? "text-red-500"
            : isDark
              ? "text-white"
              : "text-slate-900",
        )}
      >
        {label}
      </Text>
      {showChevron && (
        <Ionicons
          name="chevron-forward"
          size={20}
          color={isDark ? "#475569" : "#94a3b8"}
        />
      )}
    </AnimatedPressable>
  );
}

function SectionHeader({ title, isDark, index = 0 }: { title: string; isDark: boolean; index?: number }) {
  return (
    <Animated.View entering={FadeInDown.delay(index * 50).springify()}>
      <Text
        className={cn(
          "text-xs font-medium uppercase tracking-wider px-4 pt-6 pb-2",
          isDark ? "text-slate-500" : "text-slate-400",
        )}
      >
        {title}
      </Text>
    </Animated.View>
  );
}

interface SettingsSectionProps {
  children: React.ReactNode;
  isDark: boolean;
  index?: number;
}

function SettingsSection({ children, isDark, index = 0 }: SettingsSectionProps) {
  return (
    <Animated.View
      entering={FadeInDown.delay(index * 50 + 100).springify()}
      className={cn(
        "mx-4 rounded-xl overflow-hidden",
        isDark ? "bg-white/5" : "bg-white",
      )}
      style={{
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: isDark ? 0.1 : 0.05,
        shadowRadius: 4,
        elevation: 2,
      }}
    >
      {children}
    </Animated.View>
  );
}

function Divider({ isDark }: { isDark: boolean }) {
  return (
    <View className={cn("h-px mx-4", isDark ? "bg-white/5" : "bg-slate-100")} />
  );
}

export default function SettingsScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";

  const openPhotoSettings = () => {
    Linking.openSettings();
  };

  const iconColor = isDark ? "#94a3b8" : "#64748b";

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
        <Text
          className={cn(
            "text-2xl font-bold",
            isDark ? "text-white" : "text-slate-900",
          )}
        >
          Settings
        </Text>
      </Animated.View>

      <ScrollView
        contentContainerStyle={{ paddingBottom: insets.bottom + 100 }}
        showsVerticalScrollIndicator={false}
      >
        {/* Statistics Section */}
        <SectionHeader title="Statistics" isDark={isDark} index={0} />
        <StatisticsCard />

        {/* Account Section */}
        <SectionHeader title="Account" isDark={isDark} index={1} />
        <SettingsSection isDark={isDark} index={1}>
          <SettingsItem
            icon={<Ionicons name="star" size={20} color="#f59e0b" />}
            label="Upgrade to Pro"
            onPress={() => router.push("/premium")}
            isDark={isDark}
          />
          <Divider isDark={isDark} />
          <SettingsItem
            icon={<Ionicons name="card" size={20} color={iconColor} />}
            label="Manage Subscription"
            onPress={() => {}}
            isDark={isDark}
          />
        </SettingsSection>

        {/* Analytics & Organization Section */}
        <SectionHeader title="Analytics & Organization" isDark={isDark} index={2} />
        <SettingsSection isDark={isDark} index={2}>
          <SettingsItem
            icon={<Ionicons name="stats-chart" size={20} color={iconColor} />}
            label="Analytics Dashboard"
            onPress={() => router.push("/analytics")}
            isDark={isDark}
          />
          <Divider isDark={isDark} />
          <SettingsItem
            icon={<Ionicons name="folder" size={20} color={iconColor} />}
            label="Photo Categories"
            onPress={() => router.push("/categories")}
            isDark={isDark}
          />
        </SettingsSection>

        {/* Privacy Section */}
        <SectionHeader title="Privacy" isDark={isDark} index={3} />
        <SettingsSection isDark={isDark} index={3}>
          <SettingsItem
            icon={<Ionicons name="image" size={20} color={iconColor} />}
            label="Photo Access Settings"
            onPress={openPhotoSettings}
            isDark={isDark}
          />
          <Divider isDark={isDark} />
          <SettingsItem
            icon={<Ionicons name="shield" size={20} color={iconColor} />}
            label="Privacy Policy"
            onPress={() => {}}
            isDark={isDark}
          />
          <Divider isDark={isDark} />
          <SettingsItem
            icon={<Ionicons name="document-text" size={20} color={iconColor} />}
            label="Terms of Service"
            onPress={() => {}}
            isDark={isDark}
          />
        </SettingsSection>

        {/* Tools Section */}
        <SectionHeader title="Tools" isDark={isDark} index={4} />
        <SettingsSection isDark={isDark} index={4}>
          <SettingsItem
            icon={<Ionicons name="copy" size={20} color={iconColor} />}
            label="Find Duplicates"
            onPress={() => router.push("/duplicates")}
            isDark={isDark}
          />
          <Divider isDark={isDark} />
          <SettingsItem
            icon={<Feather name="trash-2" size={20} color={iconColor} />}
            label="Recently Deleted"
            onPress={() => router.push("/recently-deleted")}
            isDark={isDark}
          />
          <Divider isDark={isDark} />
          <SettingsItem
            icon={
              <MaterialIcons name="auto-awesome" size={20} color={iconColor} />
            }
            label="Smart Collections"
            onPress={() => router.push("/smart-collections")}
            isDark={isDark}
          />
          <Divider isDark={isDark} />
          <SettingsItem
            icon={
              <MaterialIcons name="auto-awesome" size={20} color={iconColor} />
            }
            label="AI Suggestions"
            onPress={() => router.push("/ai-suggestions")}
            isDark={isDark}
          />
        </SettingsSection>

        {/* Support Section */}
        <SectionHeader title="Support" isDark={isDark} index={5} />
        <SettingsSection isDark={isDark} index={5}>
          <SettingsItem
            icon={<Ionicons name="mail" size={20} color={iconColor} />}
            label="Contact Support"
            onPress={() => {}}
            isDark={isDark}
          />
        </SettingsSection>

        {/* App Info */}
        <Animated.View 
          entering={FadeInDown.delay(400).springify()}
          className="items-center mt-10"
        >
          <View
            className={cn(
              "w-14 h-14 rounded-2xl items-center justify-center mb-3",
              isDark ? "bg-white/5" : "bg-slate-100",
            )}
          >
            <Ionicons name="images" size={28} color={isDark ? '#60a5fa' : '#3b82f6'} />
          </View>
          <Text
            className={cn(
              "text-sm font-medium",
              isDark ? "text-white" : "text-slate-900",
            )}
          >
            Clean Gallery
          </Text>
          <Text
            className={cn(
              "text-xs mt-0.5",
              isDark ? "text-slate-500" : "text-slate-400",
            )}
          >
            Version 1.0.0
          </Text>
        </Animated.View>
      </ScrollView>
    </View>
  );
}
