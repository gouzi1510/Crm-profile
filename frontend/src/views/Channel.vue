<template>
  <DataTable ref="table" module="channel" title="渠道中心" desc="统一管理销售渠道，实时监控各渠道交易表现与稳定性"
    :stats="stats" :columns="columns" keyword="搜索渠道名称 / 编号 / 类型"
    :tabs="tabs" :actions="[{label:'配置',key:'config'}]" :creatable="true"
    @create="dialog=true" @action="onAction" @loaded="onLoaded" />
  <el-dialog v-model="dialog" title="新增渠道" width="480px">
    <el-form :model="form" label-width="90px">
      <el-form-item label="渠道名称"><el-input v-model="form.channel_name" /></el-form-item>
      <el-form-item label="渠道类型"><el-select v-model="form.channel_type"><el-option v-for="t in ['批发档口','商超','餐饮','线上','团购','零售']" :key="t" :label="t" :value="t" /></el-select></el-form-item>
      <el-form-item label="渠道编号"><el-input v-model="form.merchant_no" /></el-form-item>
    </el-form>
    <template #footer><el-button @click="dialog=false">取消</el-button><el-button type="primary" @click="save">确定</el-button></template>
  </el-dialog>
</template>
<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import DataTable from '@/components/DataTable.vue'
import { getStats, createData } from '@/api'

const table = ref(), dialog = ref(false), s = ref({})
const form = ref({ channel_name:'', channel_type:'批发档口', merchant_no:'' })
const stats = computed(()=>[
  {label:'接入渠道总数', value:s.value.channelCount||0, up:true, tip:'↑ 较上月 +2'},
  {label:'渠道可用率', value:(s.value.availability||0).toFixed(2)+'%', color:'#16a34a'},
  {label:'平均响应', value:Math.round(s.value.avgResponse||0)+'ms', color:'#2b2f36'},
  {label:'异常告警', value:s.value.alertCount||0, color:'#e6a23c'}
])
const columns = [
  {prop:'channel_name',label:'渠道名称',minWidth:130},
  {prop:'channel_type',label:'渠道类型',width:100},
  {prop:'merchant_no',label:'渠道编号',width:130},
  {prop:'trade_ratio',label:'交易占比',width:100,type:'progress'},
  {prop:'today_count',label:'今日交易',width:100},
  {prop:'today_amount',label:'今日金额',width:130,type:'money'},
  {prop:'availability',label:'可用率',width:100},
  {prop:'response_ms',label:'响应(ms)',width:100},
  {prop:'trend',label:'趋势',width:90},
  {prop:'status',label:'状态',width:90,type:'tag'}
]
const tabs = [
  {label:'全部渠道',value:'all'},
  {label:'正常',value:'正常',filterKey:'status'},
  {label:'对接中',value:'对接中',filterKey:'status'}
]
function onLoaded(){}
function onAction({action,row}){ if(action==='config') ElMessage.info('配置渠道：'+row.channel_name) }
async function save(){ await createData('channel',form.value); dialog.value=false; ElMessage.success('新增成功'); table.value.load(1) }
getStats('channel').then(r=>s.value=r.data)
</script>
