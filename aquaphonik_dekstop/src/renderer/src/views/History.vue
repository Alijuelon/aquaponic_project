<script setup lang="ts">
/**
 * History View — Displays historical sensor data from SQLite database.
 * Supports filtering by date range and displays data in a table.
 */
import { ref, onMounted, computed } from 'vue'

interface LogEntry {
  id: number
  timestamp: string
  temp_water: number
  ph: number
  tds: number
  do_value: number
  turbidity: number
  water_lvl: number
  co2: number
  eco2: number
  tvoc: number
  temp_air: number
  humidity: number
  pump_status: number
  oxy_status: number
}

const logs = ref<LogEntry[]>([])
const isLoading = ref(false)
const totalCount = ref(0)
const limit = ref(50)

// Date filter
const startDate = ref('')
const endDate = ref('')

// Set default dates
const today = new Date()
const yesterday = new Date(today)
yesterday.setDate(yesterday.getDate() - 1)
startDate.value = yesterday.toISOString().split('T')[0]
endDate.value = today.toISOString().split('T')[0]

async function loadLatestLogs(): Promise<void> {
  isLoading.value = true
  try {
    logs.value = (await window.api.database.getLatestLogs(limit.value)) as unknown as LogEntry[]
    totalCount.value = await window.api.database.getLogCount()
  } catch (err) {
    console.error('Failed to load logs:', err)
  } finally {
    isLoading.value = false
  }
}

async function loadByDateRange(): Promise<void> {
  if (!startDate.value || !endDate.value) return
  isLoading.value = true
  try {
    logs.value = (await window.api.database.getLogsByDateRange(
      `${startDate.value} 00:00:00`,
      `${endDate.value} 23:59:59`
    )) as unknown as LogEntry[]
  } catch (err) {
    console.error('Failed to load filtered logs:', err)
  } finally {
    isLoading.value = false
  }
}

const formattedLogs = computed(() => {
  return logs.value.map((log) => ({
    ...log,
    formattedTime: new Date(log.timestamp).toLocaleString('id-ID', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  }))
})

onMounted(() => {
  loadLatestLogs()
})
</script>

<template>
  <div class="p-6 md:p-8 space-y-6 md:space-y-8 overflow-y-auto h-full">
    <!-- Header removed, handled by Top Nav -->

    <!-- Filters -->
    <div class="glass-card p-5 flex flex-wrap items-end gap-5 bg-black/40 border border-white/10 shadow-2xl backdrop-blur-md rounded-3xl">
      <div class="flex flex-col gap-1.5">
        <label class="text-sm font-bold text-white uppercase tracking-wider">Dari Tanggal</label>
        <input v-model="startDate" type="date"
          class="px-4 py-2.5 rounded-xl bg-black/40 border border-white/30 text-base font-medium text-white shadow-inner outline-none focus:border-neon-cyan focus:ring-2 focus:ring-neon-cyan/30 transition-all" />
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-sm font-bold text-white uppercase tracking-wider">Sampai Tanggal</label>
        <input v-model="endDate" type="date"
          class="px-4 py-2.5 rounded-xl bg-black/40 border border-white/30 text-base font-medium text-white shadow-inner outline-none focus:border-neon-cyan focus:ring-2 focus:ring-neon-cyan/30 transition-all" />
      </div>
      <button @click="loadByDateRange" class="px-6 py-2.5 rounded-xl font-bold text-white bg-gradient-to-r from-neon-blue to-neon-cyan border border-white/20 shadow-[0_0_15px_rgba(51,238,255,0.4)] hover:shadow-[0_0_25px_rgba(51,238,255,0.6)] transition-all">
        Filter
      </button>
      <button @click="loadLatestLogs"
        class="px-5 py-2.5 rounded-xl font-bold text-white bg-white/10 border border-white/30 hover:bg-white/20 transition-all shadow-md">
        Latest {{ limit }}
      </button>

      <div class="flex items-center gap-3 ml-auto">
        <label class="text-sm font-bold text-white uppercase tracking-wider">Show:</label>
        <select v-model="limit"
          class="px-3 py-2 rounded-xl bg-black/40 border border-white/30 text-base font-medium text-white shadow-inner outline-none focus:border-neon-cyan"
          @change="loadLatestLogs">
          <option :value="25">25</option>
          <option :value="50">50</option>
          <option :value="100">100</option>
          <option :value="200">200</option>
          <option :value="500">500</option>
        </select>
      </div>
    </div>

    <!-- Table -->
    <div class="glass-card overflow-hidden bg-black/40 border border-white/10 shadow-2xl rounded-3xl backdrop-blur-md">
      <!-- Loading -->
      <div v-if="isLoading" class="p-12 text-center">
        <div class="w-10 h-10 mx-auto border-4 border-neon-cyan border-t-transparent rounded-full animate-spin"></div>
        <p class="text-base font-bold text-white mt-4 tracking-wide">Memuat data...</p>
      </div>

      <!-- Empty state -->
      <div v-else-if="logs.length === 0" class="p-12 text-center">
        <svg class="w-16 h-16 mx-auto text-white/50 mb-4" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="2" />
          <path d="M3 9h18M9 3v18" />
        </svg>
        <p class="text-lg font-bold text-white/80">Belum ada data log tersimpan</p>
      </div>

      <!-- Data table -->
      <div v-else class="overflow-x-auto">
        <table class="w-full text-base">
          <thead>
            <tr class="bg-black/40 border-b border-white/30">
              <th class="text-left px-5 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">Waktu</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">Suhu Air</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">pH</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">TDS</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">DO</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">Turb.</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">Level</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">Suhu Udara</th>
              <th class="text-right px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">Hum.</th>
              <th class="text-center px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest border-r border-white/10">Pompa</th>
              <th class="text-center px-4 py-4 text-sm font-extrabold text-white uppercase tracking-widest">O₂</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="log in formattedLogs" :key="log.id"
              class="border-b border-white/10 hover:bg-white/20 transition-colors duration-200">
              <td class="px-5 py-3.5 text-white font-mono font-bold text-sm whitespace-nowrap border-r border-white/10 bg-black/20">
                {{ log.formattedTime }}
              </td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.temp_water.toFixed(1) }}°C</td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.ph.toFixed(1) }}</td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.tds.toFixed(0) }}</td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.do_value.toFixed(0) }}</td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.turbidity.toFixed(0) }}</td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.water_lvl.toFixed(1) }}</td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.temp_air.toFixed(1) }}°C</td>
              <td class="text-right px-4 py-3.5 text-white font-bold drop-shadow-md border-r border-white/10">{{ log.humidity.toFixed(1) }}%</td>
              <td class="text-center px-4 py-3.5 border-r border-white/10">
                <span class="inline-block px-3 py-1 rounded-full text-xs font-extrabold tracking-wider border" :class="log.pump_status
                    ? 'bg-aqua-500/30 text-aqua-300 border-aqua-400/50 shadow-[0_0_10px_rgba(58,205,148,0.5)]'
                    : 'bg-black/50 text-white/50 border-white/20'
                  ">
                  {{ log.pump_status ? 'ON' : 'OFF' }}
                </span>
              </td>
              <td class="text-center px-4 py-3.5">
                <span class="inline-block px-3 py-1 rounded-full text-xs font-extrabold tracking-wider border" :class="log.oxy_status
                    ? 'bg-ocean-500/30 text-ocean-300 border-ocean-400/50 shadow-[0_0_10px_rgba(54,150,252,0.5)]'
                    : 'bg-black/50 text-white/50 border-white/20'
                  ">
                  {{ log.oxy_status ? 'ON' : 'OFF' }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
