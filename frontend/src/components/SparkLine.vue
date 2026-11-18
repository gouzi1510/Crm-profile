<template>
  <svg :viewBox="`0 0 ${width} ${height}`" class="spark" preserveAspectRatio="none">
    <polyline :points="points" fill="none" :stroke="color" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
    <polygon :points="areaPoints" :fill="fillColor" />
  </svg>
</template>
<script setup>
import { computed } from 'vue'
const props = defineProps({
  data: { type: Array, default: () => [] },
  color: { type: String, default: '#c8462f' },
  width: { type: Number, default: 96 },
  height: { type: Number, default: 36 }
})
const vals = computed(() => {
  const arr = props.data.length ? props.data : [3,5,4,7,6,8,7,9,8,10]
  const nums = arr.map(v => Number(v) || 0)
  const min = Math.min(...nums), max = Math.max(...nums)
  const range = (max - min) || 1
  return nums.map((v, i) => ({
    x: (i / Math.max(nums.length - 1, 1)) * props.width,
    y: props.height - 3 - ((v - min) / range) * (props.height - 8)
  }))
})
const points = computed(() => vals.value.map(p => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' '))
const areaPoints = computed(() => {
  const v = vals.value
  if (!v.length) return ''
  return `0,${props.height} ` + v.map(p => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ') + ` ${props.width},${props.height}`
})
const fillColor = computed(() => props.color + '22')
</script>
