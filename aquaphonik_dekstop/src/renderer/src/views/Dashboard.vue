<script setup lang="ts">
/**
 * Dashboard View — Futuristic Glassmorphism Monitoring Dashboard
 * Features: ECharts Gauge Charts, Floating Sensor Badges, IoT Network Lines,
 * Neon Control Panel, and Dark Immersive Theme.
 */
import { computed } from 'vue'
import GaugeChart from '../components/GaugeChart.vue'
import ControlPanel from '../components/ControlPanel.vue'
import { useSensorData } from '../composables/useSensorData'
import { useSerial } from '../composables/useSerial'

const { sensorData, lastUpdateFormatted, dataReceived, chartHistory, isPumpOn, isOxygenOn } =
  useSensorData()
const { sendCommand, isConnected } = useSerial()

// Handle pump toggle
async function handlePumpToggle(newState: boolean): Promise<void> {
  await sendCommand(newState ? 'POMPA:1' : 'POMPA:0')
}

// Handle oxygen toggle
async function handleOxygenToggle(newState: boolean): Promise<void> {
  await sendCommand(newState ? 'OKSIGEN:1' : 'OKSIGEN:0')
}

// Floating sensor badge configurations
const floatingSensors = computed(() => [
  {
    title: 'Level Air', value: sensorData.value.water_lvl, unit: 'cm',
    icon: 'waves', neonColor: '#5294ff', glowColor: 'rgba(82, 148, 255, 0.2)'
  },
  {
    title: 'Kekeruhan', value: sensorData.value.turbidity, unit: 'NTU',
    icon: 'eye', neonColor: '#c4a1ff', glowColor: 'rgba(196, 161, 255, 0.2)'
  },
  {
    title: 'DO', value: sensorData.value.do, unit: 'mg/L',
    icon: 'bubble', neonColor: '#33eeff', glowColor: 'rgba(51, 238, 255, 0.2)'
  }
])
</script>

<template>
  <div class="p-6 md:p-8 overflow-y-auto h-full space-y-8 scroll-smooth">
    <!-- No extra header here, moved to Top Nav -->

    <!-- ===== No Data Warning ===== -->
    <div v-if="!dataReceived && !isConnected" class="glass-card p-14 text-center animate-fade-in border-2 border-white/20">
      <!-- Animated IoT icon -->
      <div class="relative w-24 h-24 mx-auto mb-8">
        <div class="absolute inset-0 rounded-full bg-white/10 animate-pulse-slow"></div>
        <div class="absolute inset-2 rounded-full bg-white/20 flex items-center justify-center">
          <svg class="w-10 h-10 text-white/80" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z" opacity="0.4" fill="currentColor"/>
            <path d="M7 13c0-2.76 2.24-5 5-5s5 2.24 5 5" stroke-linecap="round"/>
            <circle cx="12" cy="14" r="2.5" fill="currentColor"/>
          </svg>
        </div>
        <!-- Orbiting ring -->
        <div class="absolute inset-0 border-2 border-white/20 rounded-full animate-spin-slow"></div>
      </div>
      <h3 class="text-xl md:text-2xl font-bold text-white mb-3">Menunggu Koneksi Data</h3>
      <p class="text-base font-medium text-slate-300 max-w-lg mx-auto leading-relaxed">
        Silakan hubungkan perangkat melalui Serial Port di panel atas untuk mulai menerima data sensor secara real-time.
      </p>
      <div class="mt-8 mx-auto w-32 h-1 rounded-full bg-gradient-to-r from-transparent via-white/40 to-transparent"></div>
    </div>

    <!-- ===== MAIN CONTENT ===== -->
    <div v-if="dataReceived || isConnected" class="space-y-6 md:space-y-8">

      <!-- ===== ROW 1: Floating Sensors + Gauges + Control Panel ===== -->
      <div class="flex flex-col xl:flex-row gap-6">

        <!-- LEFT: Floating Sensor Badges (Redesigned for visibility) -->
        <div class="xl:w-48 flex flex-row xl:flex-col items-center justify-center gap-4 xl:gap-5">
          <div
            v-for="(sensor, idx) in floatingSensors"
            :key="sensor.title"
            class="sensor-badge group w-full flex xl:flex-col items-center justify-between xl:justify-center p-3 xl:py-4 rounded-2xl bg-black/40 border border-white/10 shadow-2xl backdrop-blur-md"
            :class="{
              'animate-float': idx === 0,
              'animate-float-delay-1': idx === 1,
              'animate-float-delay-2': idx === 2
            }"
            :style="{ '--badge-glow': sensor.glowColor }"
          >
            <!-- Icon -->
            <div class="mb-0 xl:mb-2 flex-shrink-0 bg-white/5 p-2 rounded-xl border border-white/10">
              <svg v-if="sensor.icon === 'waves'" class="w-6 h-6" :style="{ color: sensor.neonColor }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M2 6c.6.5 1.2 1 2.5 1C7 7 7 5 9.5 5c2.6 0 2.4 2 5 2 2.5 0 2.5-2 5-2 1.3 0 1.9.5 2.5 1" />
                <path d="M2 12c.6.5 1.2 1 2.5 1 2.5 0 2.5-2 5-2 2.6 0 2.4 2 5 2 2.5 0 2.5-2 5-2 1.3 0 1.9.5 2.5 1" />
                <path d="M2 18c.6.5 1.2 1 2.5 1 2.5 0 2.5-2 5-2 2.6 0 2.4 2 5 2 2.5 0 2.5-2 5-2 1.3 0 1.9.5 2.5 1" />
              </svg>
              <svg v-else-if="sensor.icon === 'eye'" class="w-6 h-6" :style="{ color: sensor.neonColor }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                <circle cx="12" cy="12" r="3.5" />
              </svg>
              <svg v-else-if="sensor.icon === 'bubble'" class="w-6 h-6" :style="{ color: sensor.neonColor }" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <circle cx="12" cy="12" r="10" />
                <circle cx="12" cy="12" r="4.5" />
                <circle cx="8" cy="8" r="2" fill="currentColor" opacity="0.6"/>
              </svg>
            </div>
            
            <!-- Content -->
            <div class="flex flex-col text-right xl:text-center w-full min-w-0">
              <div class="flex items-end justify-end xl:justify-center gap-1 w-full min-w-0">
                <span class="text-2xl md:text-3xl font-extrabold tracking-tight drop-shadow-lg truncate" :style="{ color: sensor.neonColor }">
                  {{ sensor.value.toFixed(1) }}
                </span>
                <span class="text-xs font-bold text-white/80 mb-0.5">{{ sensor.unit }}</span>
              </div>
              <span class="text-xs md:text-sm font-semibold text-slate-200 mt-1 uppercase tracking-wider truncate">{{ sensor.title }}</span>
            </div>
            
            <!-- IoT connecting line -->
            <div class="hidden xl:block absolute -right-6 top-1/2 w-6 h-1 rounded-full"
                 :style="{ background: `linear-gradient(90deg, ${sensor.neonColor}80, transparent)` }"></div>
          </div>
        </div>

        <!-- CENTER: Main Gauge Panel -->
        <div class="flex-1 glass-card p-6 md:p-8 bg-black/40 border border-white/10 shadow-2xl rounded-3xl flex flex-col justify-between backdrop-blur-md">
          <div>
            <div class="flex items-center gap-3 mb-6 bg-white/5 p-3 rounded-xl w-fit border border-white/10">
              <div class="w-3 h-3 rounded-full bg-neon-green" style="box-shadow: 0 0 12px rgba(57,255,20,0.8);"></div>
              <h2 class="text-sm md:text-base font-bold text-white uppercase tracking-widest">Parameter Utama</h2>
            </div>

            <!-- Gauge Grid -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
              <div class="flex flex-col items-center bg-black/20 rounded-2xl p-3 border border-white/10 shadow-inner">
                <GaugeChart title="Suhu Air" :value="sensorData.temp_water" unit="°C" :min="15" :max="40" color="green" :size="160" />
              </div>
              <div class="flex flex-col items-center bg-black/20 rounded-2xl p-3 border border-white/10 shadow-inner">
                <GaugeChart title="pH" :value="sensorData.ph" unit="pH" :min="0" :max="14" color="cyan" :size="160" />
              </div>
              <div class="flex flex-col items-center bg-black/20 rounded-2xl p-3 border border-white/10 shadow-inner">
                <GaugeChart title="TDS" :value="sensorData.tds" unit="ppm" :min="0" :max="1000" color="amber" :size="160" />
              </div>
              <div class="flex flex-col items-center bg-black/20 rounded-2xl p-3 border border-white/10 shadow-inner">
                <GaugeChart title="Suhu Udara" :value="sensorData.temp_air" unit="°C" :min="15" :max="50" color="rose" :size="160" />
              </div>
            </div>
          </div>

          <!-- Secondary parameters row -->
          <div class="mt-8 pt-6 border-t border-white/20">
            <div class="flex flex-wrap justify-center gap-3 md:gap-4">
              <!-- Kelembaban -->
              <div class="flex-1 min-w-[130px] flex items-center gap-3 px-4 py-3.5 rounded-xl bg-black/20 border border-white/10 shadow-md">
                <div class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-neon-cyan/20 flex items-center justify-center flex-shrink-0 border border-neon-cyan/30">
                  <svg class="w-4 h-4 md:w-5 md:h-5 text-neon-cyan drop-shadow-md" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z" />
                    <path d="M8 14h8" stroke-linecap="round" />
                  </svg>
                </div>
                <div class="w-full">
                  <div class="text-sm md:text-base font-extrabold text-white">{{ sensorData.humidity.toFixed(1) }}<span class="text-xs text-slate-300 ml-1">%</span></div>
                  <div class="text-[10px] md:text-xs font-semibold text-slate-300 uppercase leading-tight mt-0.5">Kelembaban</div>
                </div>
              </div>
              <!-- CO2 -->
              <div class="flex-1 min-w-[130px] flex items-center gap-3 px-4 py-3.5 rounded-xl bg-black/20 border border-white/10 shadow-md">
                <div class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-emerald-500/20 flex items-center justify-center flex-shrink-0 border border-emerald-500/30">
                  <svg class="w-4 h-4 md:w-5 md:h-5 text-emerald-400 drop-shadow-md" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M17.7 7.7a2.5 2.5 0 1 1 1.8 4.3H2" stroke-linecap="round"/>
                    <path d="M9.6 4.6A2 2 0 1 1 11 8H2" stroke-linecap="round"/>
                  </svg>
                </div>
                <div class="w-full">
                  <div class="text-sm md:text-base font-extrabold text-white">{{ sensorData.co2.toFixed(0) }}<span class="text-xs text-slate-300 ml-1">ppm</span></div>
                  <div class="text-[10px] md:text-xs font-semibold text-slate-300 uppercase leading-tight mt-0.5">CO₂</div>
                </div>
              </div>
              <!-- eCO2 -->
              <div class="flex-1 min-w-[130px] flex items-center gap-3 px-4 py-3.5 rounded-xl bg-black/20 border border-white/10 shadow-md">
                <div class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-violet-500/20 flex items-center justify-center flex-shrink-0 border border-violet-500/30">
                  <svg class="w-4 h-4 md:w-5 md:h-5 text-violet-400 drop-shadow-md" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z" />
                  </svg>
                </div>
                <div class="w-full">
                  <div class="text-sm md:text-base font-extrabold text-white">{{ sensorData.eco2.toFixed(0) }}<span class="text-xs text-slate-300 ml-1">ppm</span></div>
                  <div class="text-[10px] md:text-xs font-semibold text-slate-300 uppercase leading-tight mt-0.5">eCO₂</div>
                </div>
              </div>
              <!-- TVOC -->
              <div class="flex-1 min-w-[130px] flex items-center gap-3 px-4 py-3.5 rounded-xl bg-black/20 border border-white/10 shadow-md">
                <div class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-amber-500/20 flex items-center justify-center flex-shrink-0 border border-amber-500/30">
                  <svg class="w-4 h-4 md:w-5 md:h-5 text-amber-400 drop-shadow-md" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z" />
                  </svg>
                </div>
                <div class="w-full">
                  <div class="text-sm md:text-base font-extrabold text-white">{{ sensorData.tvoc.toFixed(0) }}<span class="text-xs text-slate-300 ml-1">ppb</span></div>
                  <div class="text-[10px] md:text-xs font-semibold text-slate-300 uppercase leading-tight mt-0.5">TVOC</div>
                </div>
              </div>
              <!-- pH Volts -->
              <div class="flex-1 min-w-[130px] flex items-center gap-3 px-4 py-3.5 rounded-xl bg-black/20 border border-white/10 shadow-md">
                <div class="w-8 h-8 md:w-10 md:h-10 rounded-xl bg-blue-500/20 flex items-center justify-center flex-shrink-0 border border-blue-500/30">
                  <svg class="w-4 h-4 md:w-5 md:h-5 text-blue-400 drop-shadow-md" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
                  </svg>
                </div>
                <div class="w-full">
                  <div class="text-sm md:text-base font-extrabold text-white">{{ sensorData.ph_volts.toFixed(2) }}<span class="text-xs text-slate-300 ml-1">V</span></div>
                  <div class="text-[10px] md:text-xs font-semibold text-slate-300 uppercase leading-tight mt-0.5">pH Volts</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- RIGHT: Control Panel (Moved back from bottom) -->
        <div class="xl:w-80">
          <ControlPanel
            :pump-status="isPumpOn"
            :oxygen-status="isOxygenOn"
            @toggle-pump="handlePumpToggle"
            @toggle-oxygen="handleOxygenToggle"
          />
        </div>
      </div>
    </div>
  </div>
</template>
