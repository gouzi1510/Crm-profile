<template>
  <div class="line-chart" ref="wrap">
    <svg :viewBox="`0 0 ${W} ${H}`" preserveAspectRatio="none" class="chart-svg">
      <defs>
        <linearGradient :id="gradId" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" :stop-color="color1" stop-opacity="0.28" />
          <stop offset="100%" :stop-color="color1" stop-opacity="0.01" />
        </linearGradient>
      </defs>
      <!-- 网格线 -->
      <line v-for="i in 5" :key="'g'+i" :x1="pad" :y1="pad + (i-1)*(chartH/4)" :x2="W-pad" :y2="pad + (i-1)*(chartH/4)" stroke="#eef0f4" stroke-width="1" />
      <!-- 本期面积 + 线 -->
      <polygon :points="area1" :fill="`url(#${gradId})`" />
      <polyline :points="line1" fill="none" :stroke="color1" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" />
      <!-- 上期虚线 -->
      <polyline v-if="line2" :points="line2" fill="none" :stroke="color2" stroke-width="1.6" stroke-dasharray="4 4" stroke-linecap="round" />
      <!-- hover 指示 -->
      <g v-if="hoverIdx >= 0">
        <line :x1="xAt(hoverIdx)" :y1="pad" :x2="xAt(hoverIdx)" :y2="H-pad" stroke="#cbd5e1" stroke-width="1" stroke-dasharray="3 3" />
        <circle :cx="xAt(hoverIdx)" :cy="y1At(hoverIdx)" r="4.5" fill="#fff" :stroke="color1" stroke-width="2.5" />
      </g>
      <rect v-for="(p,i) in pointsX" :key="'h'+i" :x="p - stepX/2" :y="pad" :width="stepX" :height="chartH" fill="transparent"
            @mouseenter="hoverIdx=i" @mouseleave="hoverIdx=-1" />
    </svg>
    <div v-if="hoverIdx>=0" class="tooltip" :style="{ left: (xAt(hoverIdx)/W*100)+'%', top: (y1At(hoverIdx)/H*100)+'%' }">
      <div class="tt-label">{{ labels[hoverIdx] }}</div>
      <div class="tt-row"><span :style="{background:color1}"></span>本期 <b>{{ fmt(v1[hoverIdx]) }}</b></div>
      <div class="tt-row" v-if="v2.length"><span :style="{background:color2}"></span>上期 <b>{{ fmt(v2[hoverIdx]) }}</b></div>
    </div>
    <div class="x-labels">
      <span v-for="(l,i) in labelSample" :key="i">{{ l }}</span>
    </div>
  </div>
</template>
<script setup>
import { computed, ref } from 'vue'
const props = defineProps({
  labels: { type: Array, default: () => [] },
  values: { type: Array, default: () => [] },
  values2: { type: Array, default: () => [] },
  color1: { type: String, default: '#2f8f83' },
  color2: { type: String, default: '#d9a441' }
})
const W = 800, H = 260, pad = 30
const chartW = W - pad * 2, chartH = H - pad * 2
const hoverIdx = ref(-1)
const gradId = 'lg' + Math.random().toString(36).slice(2, 8)

const v1 = computed(() => props.values.map(v => Number(v) || 0))
const v2 = computed(() => (props.values2 || []).map(v => Number(v) || 0))
const all = computed(() => [...v1.value, ...v2.value])
const maxV = computed(() => Math.max(...all.value, 1) * 1.1)
const stepX = computed(() => chartW / Math.max(v1.value.length - 1, 1))
const xAt = (i) => pad + i * stepX.value
const yOf = (v) => pad + chartH - (v / maxV.value) * chartH
const y1At = (i) => yOf(v1.value[i])
const pointsX = computed(() => v1.value.map((_, i) => xAt(i)))
const line1 = computed(() => v1.value.map((v, i) => `${xAt(i).toFixed(1)},${yOf(v).toFixed(1)}`).join(' '))
const line2 = computed(() => v2.value.length ? v2.value.map((v, i) => `${xAt(i).toFixed(1)},${yOf(v).toFixed(1)}`).join(' ') : '')
const area1 = computed(() => `${pad},${pad+chartH} ` + line1.value + ` ${xAt(v1.value.length-1)},${pad+chartH}`)
const labelSample = computed(() => {
  const n = props.labels.length
  if (n <= 8) return props.labels
  const step = Math.ceil(n / 7)
  return props.labels.filter((_, i) => i % step === 0 || i === n - 1)
})
function fmt(v) {
  if (v == null) return '-'
  if (v >= 1e8) return (v/1e8).toFixed(2) + '亿'
  if (v >= 1e4) return (v/1e4).toFixed(1) + '万'
  return Number(v).toFixed(0)
}
</script>
<style scoped>
.line-chart { position:relative; width:100%; height:260px; }
.chart-svg { width:100%; height:230px; overflow:visible; }
.x-labels { display:flex; justify-content:space-between; padding:4px 20px 0; font-size:11px; color:#a8abb2; }
.tooltip { position:absolute; transform:translate(-50%,-115%); background:rgba(30,41,59,.94); color:#fff; border-radius:6px; padding:8px 11px; font-size:11px; white-space:nowrap; pointer-events:none; z-index:5; box-shadow:0 4px 12px rgba(0,0,0,.15); }
.tt-label { opacity:.7; margin-bottom:5px; }
.tt-row { display:flex; align-items:center; gap:5px; line-height:18px; }
.tt-row span { width:7px; height:7px; border-radius:50%; display:inline-block; }
.tt-row b { margin-left:auto; padding-left:12px; }
</style>
