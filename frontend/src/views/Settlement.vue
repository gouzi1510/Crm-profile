<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">清结算中心</h1><p class="page-desc">清算结算一体化，支持多周期结算与异常处理</p></div>
    <div class="stat-grid">
      <div class="stat-card" v-for="s in stats" :key="s.label"><div class="label">{{ s.label }}</div><div class="value" :style="{color:s.color}">{{ s.value }}</div><div class="trend" v-if="s.tip">{{ s.tip }}</div></div>
    </div>
    <div class="grid-2" style="grid-template-columns:1fr 340px">
      <div class="card card-pad">
        <el-tabs v-model="tab">
          <el-tab-pane label="结算批次" name="batch" />
          <el-tab-pane label="结算单" name="detail" />
        </el-tabs>
        <div class="search-bar">
          <el-input v-model="kw" placeholder="搜索批次号 / 结算方" :prefix-icon="Search" clearable />
          <el-select v-model="status" placeholder="结算状态" clearable style="width:130px"><el-option v-for="o in ['已结算','结算中','待结算','失败']" :key="o" :label="o" :value="o" /></el-select>
          <el-button type="primary" :icon="Search" @click="load">查询</el-button>
          <el-button style="margin-left:auto">导出明细</el-button><el-button type="primary">生成结算单</el-button>
        </div>
        <el-table :data="rows" size="small" stripe v-loading="loading" style="width:100%">
          <el-table-column :prop="tab==='batch'?'batch_no':'settle_no'" label="单号" width="150" />
          <el-table-column prop="partner_name" label="结算方" min-width="170" />
          <el-table-column prop="settle_cycle" label="周期" width="90" v-if="tab==='batch'" />
          <el-table-column prop="cycle" label="周期" width="90" v-else />
          <el-table-column prop="trans_count" label="笔数" width="80" />
          <el-table-column prop="amount" label="结算金额" width="130" align="right"><template #default="{row}"><span class="text-primary">¥{{ Number(row.amount).toFixed(2) }}</span></template></el-table-column>
          <el-table-column prop="expect_date" label="预计到账" width="140" v-if="tab==='batch'" />
          <el-table-column prop="settle_time" label="结算时间" width="140" v-else />
          <el-table-column prop="status" label="状态" width="90"><template #default="{row}"><el-tag size="small" :type="row.status==='已结算'?'success':row.status==='失败'?'danger':'warning'" effect="light">{{ row.status }}</el-tag></template></el-table-column>
        </el-table>
        <div class="pagination-bar"><el-pagination background layout="total, prev, pager, next" :total="total" v-model:current-page="pageNum" :page-size="10" @current-change="load" /></div>
      </div>
      <div>
        <div class="card mb14">
          <div class="section-title">结算方 · 待结算</div>
          <div style="padding:0 18px 16px">
            <div class="partner-item" v-for="(p,i) in partners" :key="i"><div class="partner-top"><span>{{ p.name }}</span><b>¥{{ p.amount }}</b></div><el-progress :percentage="p.percent" :stroke-width="6" :show-text="false" :color="colors[i%colors.length]" /></div>
          </div>
        </div>
        <div class="card">
          <div class="section-title">结算异常</div>
          <div style="padding:0 18px 16px">
            <div class="alert-item" v-for="(a,i) in alerts" :key="i"><el-icon color="#e64545"><WarningFilled /></el-icon><span>{{ a }}</span></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { pageData, getStats } from '@/api'
const loading=ref(false), rows=ref([]), total=ref(0), kw=ref(''), status=ref(''), tab=ref('batch'), pageNum=ref(1), s=ref({})
const colors=['#c8462f','#d9a441','#2f8f83','#5b8def']
const partners=computed(()=>[{name:'微信支付',amount:'38.50',percent:78},{name:'供应商货款',amount:'28.00',percent:56},{name:'银行转账',amount:'35.00',percent:70},{name:'现金挂账',amount:'3.50',percent:18}])
const alerts=['结算失败：3 笔待重试','账户余额不足：1 笔','信息不匹配：2 笔待核对']
const stats=computed(()=>[
  {label:'待结算金额',value:'¥'+fmt(s.value.pendingAmount),color:'#c8462f'},
  {label:'已结算金额',value:'¥'+fmt(s.value.settledAmount)},
  {label:'结算成功率',value:(s.value.successRate||0).toFixed(2)+'%',color:'#16a34a'},
  {label:'异常笔数',value:(s.value.abnormalCount||0)+' 笔',color:'#e64545'}
])
function fmt(v){if(v==null)return '0';v=Number(v);if(v>=1e8)return (v/1e8).toFixed(2)+'亿';if(v>=1e4)return (v/1e4).toFixed(1)+'万';return v.toLocaleString('zh-CN',{maximumFractionDigits:2})}
async function load(){loading.value=true;const p={pageNum:pageNum.value,keyword:kw.value};if(status.value)p.status=status.value;try{const r=await pageData(tab.value==='batch'?'settlementBatch':'settlement',p);rows.value=r.data.list;total.value=r.data.total}finally{loading.value=false}}
watch(tab,()=>{pageNum.value=1;load()})
onMounted(()=>{load();getStats('settlement').then(r=>s.value=r.data)})
</script>
<style scoped>
.partner-item{margin-bottom:13px}.partner-top{display:flex;justify-content:space-between;font-size:12px;margin-bottom:6px}
.alert-item{display:flex;align-items:center;gap:8px;font-size:12px;padding:7px 0;border-bottom:1px dashed #f0f2f5}
</style>
