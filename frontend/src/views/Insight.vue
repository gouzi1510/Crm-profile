<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">数据洞察</h1><p class="page-desc">多维数据分析，洞察经营趋势与业务表现</p></div>
    <el-tabs v-model="tab" class="mb14" type="card">
      <el-tab-pane label="交易分析" name="trade" /><el-tab-pane label="渠道分析" name="channel" /><el-tab-pane label="门店分析" name="store" /><el-tab-pane label="客户分析" name="customer" /><el-tab-pane label="分账分析" name="share" /><el-tab-pane label="结算分析" name="settlement" /><el-tab-pane label="风控分析" name="risk" />
    </el-tabs>
    <div class="stat-grid">
      <div class="stat-card" v-for="s in stats" :key="s.label"><div class="label">{{ s.label }}</div><div class="value" :style="{color:s.color}">{{ s.value }}</div><div class="trend" :class="s.up?'up':'down'">{{ s.tip }}</div><SparkLine class="spark" :data="s.spark" :color="s.up?'#e64545':'#16a34a'" /></div>
    </div>
    <div class="grid-2">
      <div class="card card-pad"><div class="toolbar"><div><div class="card-title">交易金额趋势</div><div class="card-sub">近 30 天 · 本期 vs 上期</div></div></div><div class="big-amount">¥{{ fmt(data.kpi?.gmv) }} <span class="growth">↑ 12.5%</span></div><LineChart :labels="labels" :values="vals" :values2="vals2" v-if="vals.length" /></div>
      <div class="card card-pad"><div class="card-title mb14">渠道交易占比</div><div class="donut-wrap"><div class="donut" :style="{background:donutBg}"><div class="donut-inner"><div class="donut-total">¥{{ fmt(data.kpi?.gmv) }}</div><div class="card-sub">总 GMV</div></div></div><div class="donut-legend"><div class="dl-item" v-for="(p,i) in methods" :key="i"><i :style="{background:colors[i]}"></i><span>{{ p.name }}</span><b>{{ p.ratio }}%</b></div></div></div></div>
    </div>
    <div class="grid-2">
      <div class="card card-pad"><div class="card-title mb14">门店交易排名 TOP 10</div><div class="bar-item" v-for="(r,i) in data.warehouseRank||[]" :key="i"><div class="bar-label"><span class="bar-rank">{{ String(i+1).padStart(2,'0') }}</span><span class="bar-name">{{ r.storeName }}</span><b>¥{{ fmt(r.amount) }}</b></div><el-progress :percentage="barPercent(r.amount)" :stroke-width="11" :show-text="false" :color="i===0?'#c8462f':i<3?'#d9a441':'#2f8f83'" /></div></div>
      <div class="card card-pad"><div class="card-title mb14">各环节成功率</div><div class="rate-item" v-for="(r,i) in data.successRate||[]" :key="i"><div class="rate-top"><span>{{ r.name }}</span><b>{{ r.uptime }}</b></div><el-progress :percentage="parseFloat(r.uptime)" :stroke-width="9" :show-text="false" :color="i===0?'#c8462f':'#2f8f83'" /><div class="rate-sub">{{ (parseFloat(r.uptime)*12568).toFixed(0) }} 笔 · {{ r.status }}</div></div></div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { getInsight } from '@/api'
import SparkLine from '@/components/SparkLine.vue'
import LineChart from '@/components/LineChart.vue'
const tab=ref('trade'), data=ref({})
const colors=['#2f8f83','#d9a441','#c8462f','#5b8def']
const stats=computed(()=>{const k=data.value.kpi||{};return[
  {label:'总 GMV',value:'¥'+fmt(k.gmv),tip:'↑ 12.5% 较上月',up:true,spark:[3,4,5,4,6,7,6,8,9,10]},
  {label:'客单价',value:'¥'+fmt(k.avgPrice),tip:'↑ +2.3 元',up:true,spark:[5,5,6,5,6,7,6,7,7,8]},
  {label:'退款率',value:(k.refundRate||0).toFixed(2)+'%',tip:'↓ -0.08%',up:false,spark:[8,7,7,6,6,5,5,4,4,3]},
  {label:'失败率',value:(100-(k.successRate||0)).toFixed(2)+'%',tip:'↓ -0.02%',up:false,color:'#16a34a',spark:[7,6,6,5,5,4,4,3,3,2]}
]})
const labels=computed(()=>(data.value.trend||[]).map(t=>t.label))
const vals=computed(()=>(data.value.trend||[]).map(t=>t.gmv))
const vals2=computed(()=>(data.value.trend||[]).map(t=>t.gmvLast))
const methods=computed(()=>data.value.payMethods||[])
const maxAmt=computed(()=>Math.max(...(data.value.warehouseRank||[]).map(r=>r.amount),1))
const donutBg=computed(()=>{let p=0;const seg=methods.value.map((m,i)=>{const c=colors[i%colors.length];const s=p;p+=Number(m.ratio)||0;return `${c} ${s}% ${p}%`});return `conic-gradient(${seg.join(',')})`})
function barPercent(v){return Math.round(v/maxAmt.value*100)}
function fmt(v){if(v==null)return '0';v=Number(v);if(v>=1e8)return (v/1e8).toFixed(2)+'亿';if(v>=1e4)return (v/1e4).toFixed(1)+'万';return v.toLocaleString('zh-CN',{maximumFractionDigits:2})}
onMounted(()=>getInsight().then(r=>data.value=r.data))
</script>
<style scoped>
.big-amount{font-size:22px;font-weight:700;margin-bottom:8px}.growth{color:#e64545;font-size:13px}
.donut-wrap{display:flex;align-items:center;justify-content:center;gap:30px;padding:20px 0}
.donut{width:170px;height:170px;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.donut-inner{width:120px;height:120px;border-radius:50%;background:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center}
.donut-total{font-size:17px;font-weight:700}
.donut-legend{flex:1;max-width:180px}.dl-item{display:flex;align-items:center;gap:8px;font-size:12px;padding:6px 0}.dl-item i{width:9px;height:9px;border-radius:2px}.dl-item span{flex:1}.dl-item b{font-weight:600}
.bar-item{margin-bottom:12px}.bar-label{display:flex;align-items:center;gap:8px;font-size:12px;margin-bottom:5px}.bar-rank{color:#c8462f;font-weight:700}.bar-name{flex:1}.bar-label b{color:#c8462f}
.rate-item{margin-bottom:15px}.rate-top{display:flex;justify-content:space-between;font-size:12px;margin-bottom:6px}.rate-sub{font-size:11px;color:#a8abb2;margin-top:4px}
</style>
