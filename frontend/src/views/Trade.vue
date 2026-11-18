<template>
  <div class="page-container">
    <div class="page-head">
      <h1 class="page-title">交易中心</h1>
      <p class="page-desc">查询和管理所有交易记录，支持多维度筛选与导出</p>
    </div>
    <div class="stat-grid sub">
      <div class="stat-card" v-for="s in stats" :key="s.label">
        <div class="label">{{ s.label }}</div>
        <div class="value" :style="{color:s.color}">{{ s.value }}</div>
      </div>
    </div>
    <div class="card card-pad">
      <el-tabs v-model="activeTab" @tab-change="onTab">
        <el-tab-pane label="全部交易" name="all" />
        <el-tab-pane label="销售收款" name="销售收款" />
        <el-tab-pane label="退款" name="退款" />
        <el-tab-pane label="已结算" name="已结算" />
      </el-tabs>
      <div class="search-bar">
        <el-date-picker v-model="dateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" value-format="YYYY-MM-DD" style="width:260px" />
        <el-input v-model="keyword" placeholder="搜索订单号 / 客户名称" :prefix-icon="Search" clearable />
        <el-select v-model="payMethod" placeholder="支付方式" clearable style="width:140px">
          <el-option v-for="m in ['微信支付','支付宝','银行卡','现金','挂账']" :key="m" :label="m" :value="m" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load(1)">查询</el-button>
        <el-button :icon="Refresh" @click="reset">重置</el-button>
        <el-button style="margin-left:auto" :icon="Download">导出明细</el-button>
      </div>
      <div class="card-sub" style="margin-bottom:10px">共 <b>{{ total }}</b> 笔交易，总金额 <b class="text-primary">¥{{ fmt(sumAmount) }}</b></div>
      <el-table :data="rows" size="small" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="trans_time" label="交易时间" width="140" />
        <el-table-column prop="trans_no" label="交易流水号" width="160" />
        <el-table-column prop="customer_name" label="客户 / 商户" min-width="160" />
        <el-table-column prop="trans_type" label="交易类型" width="110" />
        <el-table-column prop="pay_method" label="支付方式" width="100" />
        <el-table-column prop="amount" label="金额 (¥)" width="120" align="right">
          <template #default="{row}"><span :class="row.amount>=0?'text-danger':'text-success'">{{ row.amount>=0?'+':'' }}{{ Number(row.amount).toFixed(2) }}</span></template>
        </el-table-column>
        <el-table-column prop="fee" label="手续费" width="90" align="right"><template #default="{row}">¥{{ Number(row.fee).toFixed(2) }}</template></el-table-column>
        <el-table-column prop="status" label="状态" width="85">
          <template #default="{row}"><el-tag size="small" :type="row.status==='成功'?'success':'danger'" effect="light">{{ row.status }}</el-tag></template>
        </el-table-column>
        <el-table-column prop="settle_status" label="结算状态" width="95">
          <template #default="{row}"><span :class="row.settle_status==='已结算'?'text-success':'text-warn'">{{ row.settle_status }}</span></template>
        </el-table-column>
        <el-table-column label="操作" width="70" fixed="right"><template #default><el-button link type="primary" size="small">详情</el-button></template></el-table-column>
      </el-table>
      <div class="pagination-bar">
        <el-pagination background layout="total, sizes, prev, pager, next" :total="total" v-model:current-page="pageNum" v-model:page-size="pageSize" :page-sizes="[10,20,50]" @current-change="load()" @size-change="load(1)" />
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { Search, Refresh, Download } from '@element-plus/icons-vue'
import { pageData, getStats } from '@/api'

const loading = ref(false), rows = ref([]), total = ref(0), sumAmount = ref(0)
const keyword = ref(''), payMethod = ref(''), dateRange = ref([])
const activeTab = ref('all'), pageNum = ref(1), pageSize = ref(10)
const statData = ref({})

const stats = computed(() => [
  { label:'交易总笔数', value:fmt(statData.value.totalCount) },
  { label:'交易总金额', value:'¥'+fmt(statData.value.totalAmount), color:'#c8462f' },
  { label:'成功交易', value:fmt(statData.value.successCount), color:'#16a34a' },
  { label:'失败交易', value:fmt(statData.value.failedCount), color:'#e64545' },
  { label:'退款订单', value:fmt(statData.value.refundCount), color:'#e6a23c' }
])
function fmt(v){ if(v==null)return '0'; v=Number(v); if(v>=1e8)return (v/1e8).toFixed(2)+'亿'; if(v>=1e4)return (v/1e4).toFixed(1)+'万'; return v.toLocaleString('zh-CN',{maximumFractionDigits:2}) }

async function load(p) {
  if (p) pageNum.value = p
  loading.value = true
  const params = { pageNum:pageNum.value, pageSize:pageSize.value, keyword:keyword.value }
  if (payMethod.value) params.pay_method = payMethod.value
  if (dateRange.value?.length === 2) { params.startDate = dateRange.value[0]; params.endDate = dateRange.value[1]; params.dateCol = 'trans_time' }
  if (activeTab.value === '销售收款') params.trans_type = '销售收款'
  else if (activeTab.value === '退款') params.trans_type = '退款'
  else if (activeTab.value === '已结算') params.settle_status = '已结算'
  try {
    const r = await pageData('payment', params)
    rows.value = r.data.list; total.value = r.data.total
    sumAmount.value = rows.value.reduce((s,x)=>s+Math.abs(Number(x.amount)),0)
  } finally { loading.value = false }
}
function onTab(){ load(1) }
function reset(){ keyword.value=''; payMethod.value=''; dateRange.value=[]; activeTab.value='all'; load(1) }
onMounted(async () => { load(1); const r = await getStats('trade'); statData.value = r.data })
</script>
