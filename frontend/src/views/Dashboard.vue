<template>
  <div class="page-container">
    <div class="page-head">
      <h1 class="page-title">仪表盘</h1>
      <p class="page-desc">实时掌握平台交易动态，数据一目了然</p>
    </div>

    <!-- 四个 KPI 卡 -->
    <div class="stat-grid" v-loading="loading">
      <div class="stat-card" v-for="k in kpiCards" :key="k.label">
        <div class="label">{{ k.label }}</div>
        <div class="value" :style="{color:k.color}">{{ k.value }}<span class="unit" v-if="k.unit">{{ k.unit }}</span></div>
        <div class="trend" :class="k.up ? 'up':'down'">
          {{ k.up ? '↑' : '↓' }} {{ k.growth }}% <span style="color:#a8abb2;font-weight:400">较昨日</span>
        </div>
        <SparkLine class="spark" :data="k.spark" :color="k.up ? '#e64545':'#16a34a'" />
      </div>
    </div>

    <!-- 5 个次级指标 -->
    <div class="card mb14">
      <div class="sub-stats">
        <div class="sub-item" v-for="s in subStats" :key="s.label">
          <div class="sub-label">{{ s.label }}</div>
          <div class="sub-value" :style="{color:s.color}">{{ s.value }}</div>
        </div>
      </div>
    </div>

    <!-- 趋势图 + 支付方式占比 -->
    <div class="grid-2">
      <div class="card card-pad">
        <div class="toolbar">
          <div>
            <div class="card-title">交易金额趋势</div>
            <div class="card-sub">近 30 天交易金额变化</div>
          </div>
          <div class="legend">
            <span><i style="background:#2f8f83"></i>本期</span>
            <span><i style="background:#d9a441"></i>上期</span>
          </div>
        </div>
        <div class="big-amount">{{ fmt(data.kpi?.gmv) }} <span class="growth">↑ {{ data.kpi?.gmvGrowth || 0 }}%</span></div>
        <LineChart :labels="trendLabels" :values="trendVals" :values2="trendLast" v-if="trendVals.length" />
        <div class="empty-hint" v-else>暂无趋势数据</div>
      </div>

      <div class="card">
        <div class="section-title">支付方式占比</div>
        <div class="pay-list">
          <div class="pay-item" v-for="(p,i) in data.payMethods || []" :key="i">
            <div class="pay-row">
              <span class="pay-name"><i :style="{background:payColors[i%payColors.length]}"></i>{{ p.name }}</span>
              <span class="pay-amt">¥{{ fmt(p.amount) }}</span>
              <span class="pay-ratio">{{ p.ratio }}%</span>
            </div>
            <el-progress :percentage="Number(p.ratio)" :stroke-width="7" :show-text="false" :color="payColors[i%payColors.length]" />
          </div>
        </div>
      </div>
    </div>

    <!-- 实时交易流水 -->
    <div class="card mb14">
      <div class="toolbar" style="padding:14px 18px 0">
        <div><div class="card-title">实时交易流水</div><div class="card-sub">最近交易实时更新</div></div>
        <el-button link type="primary" @click="$router.push('/trade')">查看全部 →</el-button>
      </div>
      <el-table :data="data.realtime || []" size="small" stripe style="width:100%">
        <el-table-column prop="transTime" label="时间" width="110" />
        <el-table-column prop="transNo" label="订单号" width="150" />
        <el-table-column prop="customerName" label="客户 / 商户" min-width="150" />
        <el-table-column prop="payMethod" label="支付方式" width="100" />
        <el-table-column prop="amount" label="金额 (¥)" width="120" align="right">
          <template #default="{row}"><span class="text-danger">+{{ Number(row.amount).toFixed(2) }}</span></template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="90">
          <template #default="{row}"><el-tag size="small" :type="row.status==='成功'?'success':'danger'" effect="light">{{ row.status }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="settleStatus" label="结算状态" width="100">
          <template #default="{row}"><span :class="row.settleStatus==='已结算'?'text-success':'text-warn'">{{ row.settleStatus }}</span></template>
        </el-table-column>
        <el-table-column label="操作" width="70" fixed="right"><template #default><el-button link type="primary" size="small">详情</el-button></template></el-table-column>
      </el-table>
    </div>

    <!-- 营收榜 + 系统状态 + 公告 -->
    <div class="grid-3">
      <div class="card">
        <div class="section-title">营收榜单 TOP 5</div>
        <div class="rank-list">
          <div class="rank-item" v-for="(r,i) in data.revenueTop || []" :key="i">
            <span class="rank-no" :class="'r'+(i+1)">{{ i+1 }}</span>
            <span class="rank-name">{{ r.customerName }}</span>
            <span class="rank-amt">¥{{ fmt(r.amount) }}</span>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="section-title">系统运行状态</div>
        <div class="sys-list">
          <div class="sys-item" v-for="s in data.systemStatus || []" :key="s.moduleName">
            <div class="sys-top">
              <span>{{ s.moduleName }}</span>
              <span class="tag-dot text-success" style="font-size:12px">{{ s.status }}</span>
            </div>
            <el-progress :percentage="parseFloat(s.uptime)" :stroke-width="6" :show-text="false" color="#2f8f83" />
            <div class="sys-sub">{{ s.uptime }} · {{ s.remark }}</div>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="section-title">最新公告</div>
        <div class="notice-list">
          <div class="notice-item" v-for="(n,i) in data.notices || []" :key="i">
            <span class="notice-tag" :class="n.topFlag ? 'top':''">{{ n.noticeType }}</span>
            <span class="notice-title">{{ n.title }}</span>
            <span class="notice-time">{{ n.publishTime }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { getOverview } from '@/api'
import SparkLine from '@/components/SparkLine.vue'
import LineChart from '@/components/LineChart.vue'

const loading = ref(false)
const data = ref({})
const payColors = ['#2f8f83','#d9a441','#c8462f','#5b8def','#8e6ee0']

const kpiCards = computed(() => {
  const k = data.value.kpi || {}
  const sparks = [
    [3,4,3,5,6,5,7,8,7,9], [4,5,5,6,5,7,8,7,9,10],
    [7,7,6,6,5,5,4,4,3,3], [4,3,4,3,5,4,6,5,7,6]
  ]
  return [
    { label:'今日交易金额', value:fmt(k.gmv), unit:'', growth:k.gmvGrowth||0, up:(k.gmvGrowth||0)>=0, color:'#2b2f36', spark:sparks[0] },
    { label:'交易笔数', value:fmt(k.orderCount), growth:8.2, up:true, color:'#2b2f36', spark:sparks[1] },
    { label:'活跃客户数', value:fmt(k.customerCount), growth:3.1, up:false, color:'#2b2f36', spark:sparks[2] },
    { label:'退款订单数', value:fmt(k.refundCount), growth:5.4, up:true, color:'#2b2f36', spark:sparks[3] }
  ]
})
const subStats = computed(() => {
  const s = data.value.sub || {}
  return [
    { label:'交易成功率', value:(s.successRate||0)+'%', color:'#16a34a' },
    { label:'手续费收入', value:'¥'+fmt(s.feeIncome), color:'#2b2f36' },
    { label:'待结算金额', value:'¥'+fmt(s.pendingSettle), color:'#2b2f36' },
    { label:'异常订单', value:fmt(s.abnormalCount)+' 笔', color:'#e6a23c' },
    { label:'涉及金额', value:'¥'+fmt(s.abnormalAmount), color:'#e64545' }
  ]
})
const trendLabels = computed(() => (data.value.trend||[]).map(t=>t.label))
const trendVals = computed(() => (data.value.trend||[]).map(t=>t.gmv))
const trendLast = computed(() => (data.value.trend||[]).map(t=>t.gmvLast))

function fmt(v) {
  if (v == null) return '0'
  v = Number(v)
  if (v >= 1e8) return (v/1e8).toFixed(2)+'亿'
  if (v >= 1e4) return (v/1e4).toFixed(1)+'万'
  return v.toLocaleString('zh-CN',{maximumFractionDigits:2})
}
onMounted(async () => {
  loading.value = true
  try { const r = await getOverview(); data.value = r.data }
  finally { loading.value = false }
})
</script>
<style scoped>
.sub-stats { display:grid; grid-template-columns:repeat(5,1fr); }
.sub-item { padding:14px 18px; border-right:1px solid #f0f2f5; }
.sub-item:last-child { border-right:none; }
.sub-label { font-size:12px; color:#909399; }
.sub-value { font-size:19px; font-weight:700; margin-top:6px; }
.legend { display:flex; gap:14px; font-size:12px; color:#909399; }
.legend span { display:flex; align-items:center; gap:5px; }
.legend i { width:10px; height:3px; border-radius:2px; display:inline-block; }
.big-amount { font-size:22px; font-weight:700; margin:6px 0 4px; }
.growth { font-size:13px; color:#e64545; }
.pay-list { padding:6px 18px 18px; }
.pay-item { margin-bottom:14px; }
.pay-row { display:flex; align-items:center; margin-bottom:6px; font-size:12px; }
.pay-name { flex:1; display:flex; align-items:center; gap:7px; }
.pay-name i { width:8px; height:8px; border-radius:2px; }
.pay-amt { width:90px; text-align:right; font-weight:600; }
.pay-ratio { width:48px; text-align:right; color:#909399; }
.rank-list, .sys-list, .notice-list { padding:4px 18px 16px; }
.rank-item { display:flex; align-items:center; gap:10px; padding:7px 0; border-bottom:1px dashed #f0f2f5; font-size:12px; }
.rank-no { width:20px; height:20px; border-radius:5px; background:#f0f2f5; color:#909399; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; }
.rank-no.r1 { background:#c8462f; color:#fff; } .rank-no.r2 { background:#e6a23c; color:#fff; } .rank-no.r3 { background:#d9a441; color:#fff; }
.rank-name { flex:1; }
.rank-amt { font-weight:600; color:#c8462f; }
.sys-item { margin-bottom:13px; }
.sys-top { display:flex; justify-content:space-between; font-size:12px; margin-bottom:6px; }
.sys-sub { font-size:11px; color:#a8abb2; margin-top:4px; }
.notice-item { display:flex; align-items:center; gap:8px; padding:8px 0; border-bottom:1px dashed #f0f2f5; font-size:12px; }
.notice-tag { flex-shrink:0; font-size:10px; padding:2px 6px; border-radius:4px; background:#f0f2f5; color:#909399; }
.notice-tag.top { background:#fdf2ef; color:#c8462f; }
.notice-title { flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.notice-time { color:#a8abb2; flex-shrink:0; }
</style>
