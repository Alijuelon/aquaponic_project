<script setup lang="ts">
/**
 * App.vue — Root component
 * Layout: Immersive fullscreen BG + Sidebar + Header + RouterView
 * Theme: Futuristic Glassmorphism with real-world aquaponics background
 */
import Sidebar from './components/Sidebar.vue'
import Header from './components/Header.vue'
import { useRoute } from 'vue-router'
import { computed } from 'vue'
import bgImage from './assets/bg-aquaponics.png'

const route = useRoute()

const pageTitle = computed(() => {
  return (route.meta?.title as string) || 'Dashboard'
})
</script>

<template>
  <div class="relative h-screen w-screen overflow-hidden text-white">
    <!-- Immersive Fullscreen Background -->
    <div
      class="absolute inset-0 bg-cover bg-center bg-no-repeat"
      :style="{ backgroundImage: `url(${bgImage})` }"
    >
      <!-- Dark overlay for readability -->
      <div class="absolute inset-0 bg-black/40 backdrop-blur-[2px]"></div>
    </div>

    <!-- Main Layout (over background) -->
    <div class="relative z-10 flex flex-col h-full w-full">
      <!-- Main Content Area -->
      <div class="flex-1 flex flex-col min-w-0 overflow-hidden">
        <!-- Header -->
        <Header>
          <template #title>{{ pageTitle }}</template>
        </Header>

        <!-- Page Content with transition -->
        <main class="flex-1 overflow-hidden pb-4">
          <router-view v-slot="{ Component }">
            <transition name="page" mode="out-in">
              <component :is="Component" />
            </transition>
          </router-view>
        </main>
      </div>

      <!-- Bottom Nav -->
      <Sidebar class="z-50 shrink-0" />
    </div>

    <!-- Ambient glow particles (decorative) -->
    <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-aqua-500/5 rounded-full blur-3xl animate-pulse-slow pointer-events-none"></div>
    <div class="absolute bottom-1/4 right-1/4 w-80 h-80 bg-ocean-500/5 rounded-full blur-3xl animate-pulse-slow pointer-events-none" style="animation-delay: 1s;"></div>
  </div>
</template>
