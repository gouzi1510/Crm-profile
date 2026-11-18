<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">业务流程说明</h1><p class="page-desc">系统核心业务流程，帮助您快速了解平台运作机制</p></div>
    <div class="card card-pad mb14" style="background:linear-gradient(100deg,#f0fdf4,#fff)">
      <div class="card-title" style="font-size:15px">业务流程总览</div>
      <div class="card-sub">从采购入库到销售结算，米面杂粮批发全链路数字化管理</div>
      <div class="overview-flow">
        <template v-for="(s,i) in overview" :key="i"><div class="of-node"><div class="of-num">{{ String(i+1).padStart(2,'0') }}</div><div class="of-name">{{ s }}</div></div><div class="of-arrow" v-if="i<overview.length-1">→</div></template>
      </div>
    </div>
    <div v-for="(group,gi) in grouped" :key="gi" class="card card-pad mb14">
      <div class="toolbar"><div><div class="card-title">{{ group.name }}</div><div class="card-sub">{{ group.sub }}</div></div></div>
      <div class="flow-steps">
        <template v-for="(s,i) in group.steps" :key="i">
          <div class="step-card"><div class="step-icon"><el-icon :size="19"><component :is="s.icon||'Document'" /></el-icon></div><div class="step-no">0{{ s.step_no }}</div><div class="step-name">{{ s.step_name }}</div><div class="step-desc">{{ s.step_desc }}</div></div>
          <div class="step-arrow" v-if="i<group.steps.length-1">→</div>
        </template>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { allData } from '@/api'
const flows=ref([])
const overview=['供应商采购','到货验收入库','批发销售开单','收款与发货','客户对账','供应商结算','资金分账','经营分析']
const grouped=computed(()=>{
  const map={}
  flows.value.forEach(f=>{ if(!map[f.flow_group])map[f.flow_group]={name:f.flow_group,sub:'',steps:[]}; map[f.flow_group].steps.push(f) })
  const subs={'企业采购入库流程':'从采购申请到财务记账的完整入库链路','平台分账结算流程':'订单收款后的自动分账与资金划转','客户对账流程':'按账期与客户核对往来款项','风险预警处理流程':'风险识别到处置归档的闭环管理'}
  return Object.values(map).map(g=>({...g,sub:subs[g.name]||''}))
})
onMounted(()=>allData('businessFlow').then(r=>flows.value=r.data))
</script>
<style scoped>
.overview-flow{display:flex;align-items:center;gap:6px;margin-top:16px;overflow-x:auto;padding-bottom:6px}
.of-node{flex-shrink:0;text-align:center;background:#fff;border:1px solid #dcfce7;border-radius:8px;padding:10px 12px;min-width:88px}
.of-num{font-size:11px;color:#c8462f;font-weight:700}.of-name{font-size:12px;font-weight:600;margin-top:3px;white-space:nowrap}
.of-arrow{color:#cbd5e1;flex-shrink:0}
.flow-steps{display:flex;align-items:stretch;gap:0;overflow-x:auto;padding:8px 0 12px}
.step-card{flex-shrink:0;width:150px;min-height:118px;border:1px solid #eef0f4;border-radius:8px;padding:12px;background:#fff;position:relative}
.step-icon{width:32px;height:32px;border-radius:8px;background:#fdf2ef;color:#c8462f;display:flex;align-items:center;justify-content:center;margin-bottom:8px}
.step-no{position:absolute;right:10px;top:10px;font-size:11px;color:#c8462f;font-weight:700}
.step-name{font-size:12px;font-weight:600;margin-bottom:5px}
.step-desc{font-size:11px;color:#909399;line-height:1.5}
.step-arrow{display:flex;align-items:center;color:#cbd5e1;padding:0 8px;flex-shrink:0}
</style>
