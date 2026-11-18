<template>
  <DataTable ref="table" module="riskAlert" title="风控预警" desc="实时监控交易风险，快速响应异常预警"
    :stats="stats" :columns="columns" keyword="搜索预警编号 / 类型 / 对象"
    :searchFields="[{key:'level',label:'预警等级',options:['P0','P1','P2']},{key:'status',label:'处理状态',options:['未处理','处理中','已处理','已忽略']}]"
    :tabs="tabs" :actions="[{label:'处理',key:'handle'}]" @action="onAction">
    <template #toolbar><el-button :icon="Setting" @click="ruleVisible=true">风控规则</el-button><el-button type="primary" :icon="Refresh" @click="table.load()">刷新</el-button></template>
    <template #extra>
      <div class="grid-2" style="grid-template-columns:1.3fr 1fr;margin:0 0 14px">
        <div class="card card-pad"><div class="card-title mb14">风控规则命中（近7天）</div><div class="rule-item" v-for="(r,i) in rules" :key="i"><div class="rule-top"><span>{{ r.rule_name }}</span><span><b class="text-danger">{{ r.hit_count }}</b> 次 · <span :class="r.level==='高'?'text-danger':r.level==='中'?'text-warn':'text-info'">{{ r.level }}</span></span></div><el-progress :percentage="r.percent" :stroke-width="6" :show-text="false" :color="r.level==='高'?'#e64545':r.level==='中'?'#d9a441':'#909399'" /></div></div>
        <div class="card card-pad"><div class="card-title mb14">风控态势（最近14天）</div><div class="trend-bars"><div class="tb-item" v-for="(h,i) in bars" :key="i" :style="{height:h+'%'}"></div></div><div class="trend-sum"><div><b>46</b><span>风控拦截</span></div><div><b>98.6%</b><span>拦截准确率</span></div><div><b>0</b><span>重大风险事件</span></div></div></div>
      </div>
    </template>
  </DataTable>
  <el-dialog v-model="ruleVisible" title="风控规则" width="700px"><el-table :data="rules" size="small"><el-table-column prop="rule_name" label="规则名称" /><el-table-column prop="rule_type" label="类型" width="100" /><el-table-column prop="hit_count" label="命中次数" width="100" /><el-table-column prop="level" label="等级" width="80" /><el-table-column prop="status" label="状态" width="80" /></el-table></el-dialog>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Setting, Refresh } from '@element-plus/icons-vue'
import DataTable from '@/components/DataTable.vue'
import { getStats, allData, updateData } from '@/api'
const table=ref(), s=ref({}), rules=ref([]), ruleVisible=ref(false)
const stats=computed(()=>[
  {label:'今日待处理',value:fmt(s.value.pending),color:'#c8462f'},
  {label:'高风险预警',value:fmt(s.value.highRisk),color:'#e64545'},
  {label:'监控对象',value:fmt(s.value.queryMerchants)},
  {label:'涉及金额',value:'¥'+fmt(s.value.amount),color:'#e6a23c'}
])
const columns=[
  {prop:'alert_no',label:'预警编号',width:140},
  {prop:'level',label:'等级',width:80,type:'tag'},
  {prop:'alert_type',label:'预警类型',width:110},
  {prop:'target_name',label:'预警对象',minWidth:160},
  {prop:'detail',label:'预警详情',minWidth:230},
  {prop:'amount',label:'涉及金额',width:120,type:'money'},
  {prop:'alert_time',label:'触发时间',width:140},
  {prop:'status',label:'状态',width:90,type:'tag'},
  {prop:'handler',label:'处理人',width:90}
]
const tabs=[{label:'全部',value:'all'},{label:'P0 紧急',value:'P0',filterKey:'level'},{label:'P1 高',value:'P1',filterKey:'level'},{label:'P2 中',value:'P2',filterKey:'level'},{label:'未处理',value:'未处理',filterKey:'status'}]
const bars=[32,45,28,60,38,72,45,55,88,42,66,35,58,48]
function fmt(v){if(v==null)return '0';v=Number(v);if(v>=1e8)return (v/1e8).toFixed(2)+'亿';if(v>=1e4)return (v/1e4).toFixed(1)+'万';return v.toLocaleString('zh-CN',{maximumFractionDigits:2})}
async function onAction({action,row}){if(action==='handle'){await updateData('riskAlert',row.id,{status:'已处理',handler:'周建国'});ElMessage.success('预警已处理');table.value.load()}}
onMounted(async()=>{const [st,rl]=await Promise.all([getStats('risk'),allData('riskRule')]);s.value=st.data;const max=Math.max(...rl.data.map(x=>x.hit_count),1);rules.value=rl.data.map(x=>({...x,percent:Math.round(x.hit_count/max*100)}))})
</script>
<style scoped>
.rule-item{margin-bottom:12px}.rule-top{display:flex;justify-content:space-between;font-size:12px;margin-bottom:5px}
.trend-bars{height:110px;display:flex;align-items:flex-end;gap:4px;padding:0 4px}.tb-item{flex:1;background:linear-gradient(180deg,#c8462f,#e8a08f);border-radius:3px 3px 0 0;min-height:8px}
.trend-sum{display:flex;justify-content:space-around;margin-top:14px;text-align:center}.trend-sum b{display:block;font-size:16px;color:#c8462f}.trend-sum span{font-size:11px;color:#909399}
</style>
