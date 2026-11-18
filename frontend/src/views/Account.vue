<template>
  <DataTable ref="table" module="account" title="账户与分账" desc="管理客户资金账户、分账规则与资金流转明细"
    :stats="stats" :columns="columns" keyword="搜索账户号 / 名称 / 主体"
    :tabs="tabs" :actions="[{label:'流水',key:'flow'}]" @action="onAction" @loaded="onLoaded">
    <template #toolbar><el-button style="margin-left:auto" :icon="Setting">分账规则</el-button><el-button type="primary" :icon="Plus">新增账户</el-button></template>
    <template #extra>
      <div class="card" style="margin:0 0 14px;padding:14px 18px">
        <div class="card-title" style="margin-bottom:12px">分账引擎 · 实时分账模拟</div>
        <el-row :gutter="16">
          <el-col :span="8"><div class="sim-box"><div class="sim-label">订单收款金额</div><div class="sim-value">¥ 100.00</div><div class="sim-sub">单笔订单 · 可配置分账规则</div></div></el-col>
          <el-col :span="8"><div class="sim-box">
            <div class="sim-label">分账规则配置</div>
            <div class="sim-rule"><span>平台技术服务费</span><b>5%</b></div>
            <div class="sim-rule"><span>渠道成本</span><b>3%</b></div>
            <div class="sim-rule"><span>商户入账</span><b class="text-success">92%</b></div>
          </div></el-col>
          <el-col :span="8"><div class="sim-box">
            <div class="sim-label">分账结果</div>
            <div class="sim-rule"><span>平台服务费</span><b>¥ 5.00</b></div>
            <div class="sim-rule"><span>渠道成本</span><b>¥ 3.00</b></div>
            <div class="sim-rule"><span>商户入账</span><b class="text-success">¥ 92.00</b></div>
          </div></el-col>
        </el-row>
      </div>
    </template>
  </DataTable>
</template>
<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Setting, Plus } from '@element-plus/icons-vue'
import DataTable from '@/components/DataTable.vue'
import { getStats } from '@/api'
const table = ref(), s = ref({})
const stats = computed(()=>[
  {label:'账户总余额', value:'¥'+fmt(s.value.totalBalance), color:'#c8462f'},
  {label:'资金账户数', value:fmt(s.value.accountCount)},
  {label:'今日分账', value:'¥'+fmt(s.value.todayShare)},
  {label:'待处理', value:fmt(s.value.pendingCount)+' 笔', color:'#e6a23c'}
])
const columns = [
  {prop:'account_no',label:'账户号',width:150},
  {prop:'account_name',label:'账户名称',minWidth:180},
  {prop:'account_type',label:'账户类型',width:120,type:'tag'},
  {prop:'balance',label:'余额',width:140,type:'money'},
  {prop:'available',label:'可用余额',width:140,type:'money'},
  {prop:'frozen',label:'冻结金额',width:120,type:'money'},
  {prop:'today_share',label:'今日分账',width:120,type:'money'},
  {prop:'owner_name',label:'所属主体',minWidth:140},
  {prop:'status',label:'状态',width:85,type:'tag'}
]
const tabs = [{label:'全部账户',value:'all'},{label:'客户账户',value:'客户账户',filterKey:'account_type'},{label:'平台账户',value:'平台账户',filterKey:'account_type'},{label:'供应商账户',value:'供应商账户',filterKey:'account_type'}]
function fmt(v){if(v==null)return '0';v=Number(v);if(v>=1e8)return (v/1e8).toFixed(2)+'亿';if(v>=1e4)return (v/1e4).toFixed(1)+'万';return v.toLocaleString('zh-CN',{maximumFractionDigits:2})}
function onLoaded(){} function onAction({row}){ ElMessage.info('查看账户流水：'+row.account_name) }
getStats('account').then(r=>s.value=r.data)
</script>
<style scoped>
.sim-box{background:#f8f9fb;border-radius:8px;padding:14px;min-height:110px}
.sim-label{font-size:12px;color:#909399;margin-bottom:10px}
.sim-value{font-size:24px;font-weight:700;color:#c8462f}
.sim-sub{font-size:11px;color:#a8abb2;margin-top:8px}
.sim-rule{display:flex;justify-content:space-between;font-size:12px;padding:4px 0}
</style>
