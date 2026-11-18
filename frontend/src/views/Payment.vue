<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">转账付款</h1><p class="page-desc">管理采购付款业务，支持大额付款审核与风险控制</p></div>
    <div class="stat-grid">
      <div class="stat-card" v-for="s in stats" :key="s.label"><div class="label">{{ s.label }}</div><div class="value" :style="{color:s.color}">{{ s.value }}</div></div>
    </div>
    <div class="card mb14" style="border-color:#fde2e2;background:#fffafa" v-if="bigOrder">
      <div class="toolbar" style="padding:14px 18px 0">
        <div><span class="text-danger" style="font-weight:600">● 大额付款待审核</span><span class="card-sub" style="margin-left:8px">高风险 · 需重点关注</span></div>
        <span class="card-sub">12 分钟前</span>
      </div>
      <div style="padding:14px 18px">
        <el-row :gutter="16" align="middle">
          <el-col :span="4"><div class="big-no">{{ bigOrder.pay_no }}</div><div class="card-sub">{{ bigOrder.biz_type }}</div></el-col>
          <el-col :span="6"><div class="card-sub">付款方</div><div>穗丰粮仓平台账户</div></el-col>
          <el-col :span="6"><div class="card-sub">收款方 / 账号</div><div>{{ bigOrder.payee_name }}</div><div class="card-sub">{{ bigOrder.payee_account }} {{ bigOrder.bank_name }}</div></el-col>
          <el-col :span="4"><div class="card-sub">付款金额</div><div class="big-amt">¥ {{ Number(bigOrder.amount).toLocaleString('zh-CN') }}</div></el-col>
          <el-col :span="4" style="text-align:right"><el-button size="small">查看</el-button><el-button size="small" type="primary" @click="approve">通过</el-button><el-button size="small">拒绝</el-button></el-col>
        </el-row>
      </div>
    </div>
    <div class="card card-pad">
      <div class="toolbar"><div class="card-title">全部付款单据</div><div style="display:flex;gap:8px"><el-button :icon="Upload">导入批量付款</el-button><el-button type="primary" :icon="Plus">新建付款</el-button></div></div>
      <el-table :data="rows" size="small" stripe v-loading="loading" style="width:100%">
        <el-table-column prop="pay_no" label="付款单号" width="150" />
        <el-table-column prop="payee_name" label="收款方" min-width="180" />
        <el-table-column prop="biz_type" label="业务类型" width="110" />
        <el-table-column prop="applicant" label="申请人" width="90" />
        <el-table-column prop="amount" label="金额" width="130" align="right"><template #default="{row}"><span class="text-danger">¥{{ Number(row.amount).toFixed(2) }}</span></template></el-table-column>
        <el-table-column prop="status" label="状态" width="95"><template #default="{row}"><el-tag size="small" :type="row.status==='已通过'||row.status==='已付款'?'success':row.status==='审核拒绝'?'danger':'warning'" effect="light">{{ row.status }}</el-tag></template></el-table-column>
        <el-table-column prop="risk_level" label="风险等级" width="90"><template #default="{row}"><span :class="row.risk_level==='高'?'text-danger':row.risk_level==='中'?'text-warn':'text-success'">{{ row.risk_level }}</span></template></el-table-column>
        <el-table-column prop="bank_name" label="开户行" width="140" />
        <el-table-column prop="execute_time" label="执行时间" width="140" />
      </el-table>
      <div class="pagination-bar"><el-pagination background layout="total, prev, pager, next" :total="total" v-model:current-page="pageNum" :page-size="10" @current-change="load" /></div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Upload } from '@element-plus/icons-vue'
import { pageData, getStats } from '@/api'
const loading=ref(false),rows=ref([]),total=ref(0),pageNum=ref(1),bigOrder=ref(null),s=ref({})
const stats=computed(()=>[
  {label:'付款总金额',value:'¥'+fmt(s.value.totalAmount),color:'#c8462f'},
  {label:'待审核',value:(s.value.pendingCount||0)+' 笔',color:'#e6a23c'},
  {label:'审核中',value:(s.value.reviewingCount||0)+' 笔',color:'#d9a441'},
  {label:'付款成功率',value:(s.value.successRate||0).toFixed(1)+'%',color:'#16a34a'}
])
function fmt(v){if(v==null)return '0';v=Number(v);if(v>=1e8)return (v/1e8).toFixed(2)+'亿';if(v>=1e4)return (v/1e4).toFixed(1)+'万';return v.toLocaleString('zh-CN',{maximumFractionDigits:2})}
async function load(){loading.value=true;try{const r=await pageData('paymentOrder',{pageNum:pageNum.value});rows.value=r.data.list;total.value=r.data.total;bigOrder.value=r.data.list.find(x=>x.risk_level==='高'&&x.status==='待审核')||null}finally{loading.value=false}}
function approve(){ElMessage.success('已通过该付款申请')}
onMounted(()=>{load();getStats('payment').then(r=>s.value=r.data)})
</script>
<style scoped>
.big-no{font-weight:700;font-size:13px}.big-amt{font-size:20px;font-weight:700;color:#e64545}
</style>
