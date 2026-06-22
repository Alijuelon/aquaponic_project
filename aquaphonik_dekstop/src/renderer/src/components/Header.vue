<script setup lang="ts">
/**
 * Header — Top bar component
 * Glassmorphism header with serial connection controls.
 */
import { ref, watch, onMounted, onUnmounted } from 'vue'
import { useSerial } from '../composables/useSerial'
import { useSensorData } from '../composables/useSensorData'

const {
  isConnected,
  currentPort,
  availablePorts,
  isScanning,
  isConnecting,
  lastError,
  scanPorts,
  connect,
  disconnect
} = useSerial()

const { lastUpdateFormatted, dataReceived } = useSensorData()

const selectedPort = ref('')
const selectedBaudRate = ref(115200)
const networkIP = ref<string | null>(null)
const networkIface = ref<string | null>(null)
let ipRefreshTimer: ReturnType<typeof setInterval> | null = null

const baudRates = [9600, 19200, 38400, 57600, 115200, 230400]

// Auto-scan ports on mount
scanPorts()

// Fetch WiFi IP on mount and refresh every 30 seconds
async function fetchNetworkIP(): Promise<void> {
  try {
    const result = await window.api.system.getNetworkIP()
    networkIP.value = result.ip
    networkIface.value = result.iface
  } catch {
    networkIP.value = null
    networkIface.value = null
  }
}

onMounted(() => {
  fetchNetworkIP()
  ipRefreshTimer = setInterval(fetchNetworkIP, 30000)
})

onUnmounted(() => {
  if (ipRefreshTimer) {
    clearInterval(ipRefreshTimer)
    ipRefreshTimer = null
  }
})

// Watch for available ports to auto-select and auto-connect
watch(availablePorts, async (ports) => {
  if (ports.length > 0 && !selectedPort.value && !isConnected.value && !isConnecting.value) {
    selectedPort.value = ports[0].path
    // Auto connect using the selected default baud rate
    await connect(selectedPort.value, selectedBaudRate.value)
  }
})

async function handleConnect(): Promise<void> {
  if (isConnected.value) {
    await disconnect()
  } else if (selectedPort.value) {
    await connect(selectedPort.value, selectedBaudRate.value)
  }
}

async function handleScan(): Promise<void> {
  await scanPorts()
}

// Window Controls
async function handleMinimize(): Promise<void> {
  await window.api.windowControls.minimize()
}

async function handleClose(): Promise<void> {
  await window.api.windowControls.close()
}
</script>

<template>
  <header class="w-full h-auto lg:h-14 py-2 lg:py-0 bg-slate-950/80 backdrop-blur-xl border-b-2 border-white/20 px-3 lg:px-4 flex flex-col lg:flex-row items-center justify-between gap-2 transition-all duration-300 z-50">
    <!-- Left: Page title & Logo -->
    <div class="flex items-center gap-2 lg:gap-3 w-full lg:w-auto">
      <!-- App Logo -->
      <div class="flex items-center justify-center w-8 h-8 rounded-lg bg-gradient-to-br from-neon-cyan to-neon-green/50 p-[1.5px] shadow-[0_0_15px_rgba(51,238,255,0.3)]">
        <div class="w-full h-full bg-black/90 rounded-md flex items-center justify-center">
          <svg class="w-5 h-5 text-neon-cyan drop-shadow-md" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" stroke-linejoin="round"/>
          </svg>
        </div>
      </div>
      <h2 class="text-lg lg:text-xl xl:text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-white to-slate-400 tracking-tighter drop-shadow-sm uppercase">
        AQUA<span class="text-neon-cyan drop-shadow-[0_0_8px_rgba(51,238,255,0.8)]">PHONIK</span>
      </h2>
      <!-- Live indicator & Time -->
      <div class="ml-1 lg:ml-2 flex items-center gap-2 px-2 py-1 lg:px-4 lg:py-1.5 rounded-full bg-black/40 border border-white/10 shadow-inner">
        <span
          class="w-2 h-2 rounded-full transition-all"
          :class="dataReceived ? 'bg-neon-green animate-pulse' : 'bg-slate-400'"
          :style="dataReceived ? 'box-shadow: 0 0 10px rgba(57,255,20,0.8)' : ''"
        ></span>
        <span class="text-[10px] md:text-xs font-mono font-bold text-white tracking-widest">
          {{ isConnected ? lastUpdateFormatted : 'OFFLINE' }}
        </span>
      </div>

      <!-- WiFi IP Address -->
      <div class="ml-1 lg:ml-2 flex items-center gap-2 px-2 py-1 lg:px-3 lg:py-1.5 rounded-full border shadow-inner transition-all duration-300"
        :class="networkIP ? 'bg-neon-cyan/5 border-neon-cyan/20' : 'bg-black/40 border-white/10'"
      >
        <!-- WiFi Icon -->
        <svg class="w-3.5 h-3.5 transition-colors" :class="networkIP ? 'text-neon-cyan' : 'text-slate-500'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M5 12.55a11 11 0 0 1 14.08 0" />
          <path d="M1.42 9a16 16 0 0 1 21.16 0" />
          <path d="M8.53 16.11a6 6 0 0 1 6.95 0" />
          <line x1="12" y1="20" x2="12.01" y2="20" />
        </svg>
        <span v-if="networkIP" class="text-[10px] md:text-xs font-mono font-bold text-neon-cyan tracking-wide" :style="'text-shadow: 0 0 8px rgba(51,238,255,0.4)'">
          {{ networkIP }}
        </span>
        <span v-else class="text-[10px] md:text-xs font-mono font-bold text-slate-500 tracking-wide">
          No Network
        </span>
      </div>
    </div>

    <!-- Right: Serial connection controls -->
    <div class="flex flex-wrap items-center justify-center lg:justify-end gap-1.5 lg:gap-2 w-full lg:w-auto">
      <!-- Error toast -->
      <div v-if="lastError" class="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-neon-red/10 border border-neon-red/20">
        <svg class="w-3.5 h-3.5 text-neon-red" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10" />
          <path d="M12 8v4m0 4h.01" stroke-linecap="round" />
        </svg>
        <span class="text-[11px] text-neon-red/80">{{ lastError }}</span>
      </div>

      <!-- Scan button -->
      <button
        class="p-2 rounded-lg bg-white/[0.06] border border-white/[0.1] text-white/50 hover:text-white hover:bg-white/[0.1] transition-all duration-200"
        :class="{ 'animate-spin': isScanning }"
        :disabled="isScanning"
        title="Scan Ports"
        @click="handleScan"
      >
        <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21.5 2v6h-6M2.5 22v-6h6M2 11.5a10 10 0 0 1 18.8-4.3M22 12.5a10 10 0 0 1-18.8 4.3" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </button>

      <!-- Port selector -->
      <select
        v-model="selectedPort"
        class="px-3 py-1.5 rounded-lg bg-black/60 border border-white/20 text-xs font-bold text-white outline-none focus:border-neon-cyan/50 transition-all appearance-none cursor-pointer"
        :disabled="isConnected"
      >
        <option value="" disabled class="bg-slate-900">Select Port</option>
        <option
          v-for="port in availablePorts"
          :key="port.path"
          :value="port.path"
          class="bg-slate-900"
        >
          {{ port.path }} {{ port.manufacturer ? `(${port.manufacturer})` : '' }}
        </option>
      </select>

      <!-- Baud rate selector -->
      <select
        v-model="selectedBaudRate"
        class="px-3 py-1.5 rounded-lg bg-black/60 border border-white/20 text-xs font-bold text-white outline-none focus:border-neon-cyan/50 transition-all w-24 appearance-none cursor-pointer"
        :disabled="isConnected"
      >
        <option v-for="baud in baudRates" :key="baud" :value="baud" class="bg-slate-900">
          {{ baud }}
        </option>
      </select>

      <!-- Connect/Disconnect button -->
      <button
        class="px-4 py-1.5 rounded-lg font-semibold text-xs transition-all duration-300 flex items-center gap-2 border"
        :class="
          isConnected
            ? 'bg-neon-red/10 text-neon-red border-neon-red/30 hover:bg-neon-red/20'
            : 'bg-neon-green/10 text-neon-green border-neon-green/30 hover:bg-neon-green/20'
        "
        :style="isConnected ? 'box-shadow: 0 0 12px rgba(255,23,68,0.15)' : 'box-shadow: 0 0 12px rgba(57,255,20,0.15)'"
        :disabled="isConnecting || (!selectedPort && !isConnected)"
        @click="handleConnect"
      >
        <span v-if="isConnecting" class="w-3.5 h-3.5 border-2 border-current border-t-transparent rounded-full animate-spin"></span>
        <template v-else>
          {{ isConnected ? 'Disconnect' : 'Connect' }}
        </template>
      </button>

      <!-- Status dot -->
      <div class="flex items-center gap-2 ml-1">
        <span :class="isConnected ? 'status-dot-connected' : 'status-dot-disconnected'"></span>
        <div class="flex flex-col">
          <span class="text-[10px] font-medium" :class="isConnected ? 'text-neon-green/80' : 'text-white/30'">
            {{ isConnected ? 'Connected' : 'Disconnected' }}
          </span>
          <span v-if="isConnected" class="text-[9px] text-white/30 font-mono">{{ currentPort }}</span>
        </div>
      </div>

      <!-- Window Controls -->
      <div class="flex items-center gap-1 ml-2 pl-2 border-l border-white/10">
        <button
          @click="handleMinimize"
          class="p-1.5 rounded-lg text-white/50 hover:text-white hover:bg-white/10 transition-colors"
          title="Minimize"
        >
          <svg class="w-4 h-4 md:w-5 md:h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
        </button>
        <button
          @click="handleClose"
          class="p-1.5 rounded-lg text-white/50 hover:text-white hover:bg-red-500/80 transition-colors"
          title="Exit"
        >
          <svg class="w-4 h-4 md:w-5 md:h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>
      </div>
    </div>
  </header>
</template>
