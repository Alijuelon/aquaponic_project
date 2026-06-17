<script setup lang="ts">
/**
 * GaugeChart — Futuristic ECharts Gauge component
 * Renders a half-circle/donut gauge with neon glow effects.
 * Uses vue-echarts with Apache ECharts.
 */
import { computed } from 'vue'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { GaugeChart as EGaugeChart } from 'echarts/charts'
import { CanvasRenderer } from 'echarts/renderers'

use([EGaugeChart, CanvasRenderer])

const props = defineProps<{
  title: string
  value: number
  unit: string
  min: number
  max: number
  color?: string
  size?: number
}>()

/**
 * Get neon color based on color prop name
 */
function getNeonColor(c?: string): string {
  switch (c) {
    case 'green': return '#54ff33'
    case 'cyan': return '#33eeff'
    case 'amber': return '#ffbd33'
    case 'rose': return '#ff6699'
    case 'blue': return '#5294ff'
    case 'violet': return '#c4a1ff'
    default: return '#54ff33'
  }
}

const gaugeOption = computed(() => {
  const neonColor = getNeonColor(props.color)
  const pct = Math.min(1, Math.max(0, (props.value - props.min) / (props.max - props.min)))

  return {
    series: [
      {
        type: 'gauge',
        startAngle: 220,
        endAngle: -40,
        radius: '90%',
        center: ['50%', '55%'],
        min: props.min,
        max: props.max,
        splitNumber: 4,
        axisLine: {
          lineStyle: {
            width: 20,
            color: [
              [pct, neonColor],
              [1, 'rgba(255, 255, 255, 0.1)']
            ]
          },
          roundCap: true
        },
        progress: {
          show: true,
          width: 20,
          roundCap: true,
          itemStyle: {
            color: neonColor,
            shadowColor: neonColor,
            shadowBlur: 16
          }
        },
        pointer: { show: false },
        axisTick: { show: false },
        splitLine: { show: false },
        axisLabel: { show: false },
        title: {
          show: true,
          offsetCenter: [0, '80%'],
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: 700,
          color: 'rgba(255, 255, 255, 0.9)'
        },
        detail: {
          valueAnimation: true,
          fontSize: 32,
          fontFamily: 'Inter',
          fontWeight: 800,
          color: neonColor,
          offsetCenter: [0, '25%'],
          formatter: function (value: number) {
            return value.toFixed(1)
          }
        },
        data: [
          {
            value: props.value,
            name: `${props.title} (${props.unit})`
          }
        ]
      }
    ]
  }
})
</script>

<template>
  <div class="relative flex flex-col items-center">
    <div class="echarts-gauge-container" :style="{ width: `${size || 160}px`, height: `${size || 160}px` }">
      <VChart :option="gaugeOption" autoresize :style="{ width: '100%', height: '100%' }" />
    </div>
  </div>
</template>
