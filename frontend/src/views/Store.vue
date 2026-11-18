<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">门店与终端</h1><p class="page-desc">统一管理批发门店、仓库与终端设备，实时掌握运行状态</p></div>
    <div class="stat-grid">
      <div class="stat-card" v-for="s in stats" :key="s.label"><div class="label">{{ s.label }}</div><div class="value" :style="{color:s.color}">{{ s.value }}</div><div class="trend" v-if="s.tip">{{ s.tip }}</div></div>
    </div>
    <div class="grid-2" style="grid-template-columns:1fr 320px">
      <div class="card card-pad">
        <el-tabs v-model="tab"><el-tab-pane label="门店列表" name="warehouse" /><el-tab-pane label="终端设备" name="terminal" /></el-tabs>
        <div class="search-bar"><el-input v-model="kw" :placeholder="tab==='warehouse'?'搜索门店编号 / 名称 / 区域':'搜索终端编号 / 类型 / 门店'" :prefix-icon="Search" clearable /><el-button type="primary" :icon="Search" @click="load">查询</el-button><el-button v-if="tab==='warehouse'" style="margin-left:auto" type="primary" :icon="Plus">新增门店</el-button></div>
        <el-table :data="rows" size="small" stripe v-loading="loading" style="width:100%">
          <template v-if="tab==='warehouse'">
            <el-table-column prop="store_no" label="门店编号" width="115" />
            <el-table-column prop="store_name" label="门店名称" min-width="190" />
            <el-table-column prop="store_type" label="类型" width="100" />
            <el-table-column prop="region" label="区域" width="110" />
            <el-table-column prop="manager" label="负责人" width="90" />
            <el-table-column prop="today_amount" label="今日交易" width="115" align="right"><template #default="{row}">¥{{ Number(row.today_amount).toFixed(0) }}</template></el-table-column>
            <el-table-column prop="terminal_count" label="终端数" width="75" />
            <el-table-column prop="status" label="状态" width="90"><template #default="{row}"><el-tag size="small" :type="row.status==='运营中'?'success':'warning'" effect="light">{{ row.status }}</el-tag></template></el-table-column>
          </template>
          <template v-else>
            <el-table-column prop="terminal_no" label="终端编号" width="120" />
            <el-table-column prop="terminal_type" label="终端类型" width="130" />
            <el-table-column prop="store_name" label="所属门店" min-width="200" />
            <el-table-column prop="today_amount" label="今日交易" width="115" align="right"><template #default="{row}">¥{{ Number(row.today_amount).toFixed(0) }}</template></el-table-column>
            <el-table-column prop="status" label="状态" width="90"><template #default="{row}"><span class="tag-dot" :class="row.status==='在线'?'text-success':row.status==='故障'?'text-danger':'text-info'">{{ row.status }}</span></template></el-table-column>
          </template>
        </el-table>
        <div class="pagination-bar"><el-pagination background layout="total, prev, pager, next" :total="total" v-model:current-page="pageNum" :page-size="10" @current-change="load" /></div>
      </div>
      <div>
        <div class="card mb14"><div class="section-title">终端类型分布</div><div style="padding:0 18px 16px"><div class="dist-item" v-for="(d,i) in terminalDist" :key="i"><div class="dist-top"><span><i :style="{background:colors[i]}"></i>{{ d.name }}</span><b>{{ d.count }} 台</b></div><el-progress :percentage="d.percent" :stroke-width="7" :show-text="false" :color="colors[i]" /></div></div></div>
        <div class="card"><div class="section-title">区域分布</div><div style="padding:0 18px 16px"><div class="region-grid"><div class="region-item" v-for="r in regions" :key="r.name"><div class="region-num">{{ r.count }}</div><div class="region-name">{{ r.name }}</div></div></div></div></div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { Search, Plus } from '@element-plus/icons-vue'
import { pageData, getStats } from '@/api'
const loading=ref(false),rows=ref([]),total=ref(0),kw=ref(''),tab=ref('warehouse'),pageNum=ref(1),s=ref({})
const colors=['#2f8f83','#c8462f','#d9a441','#5b8def']
const terminalDist=[{name:'POS一体机',count:266,percent:78},{name:'扫码枪',count:68,percent:20},{name:'电子秤',count:48,percent:14},{name:'手持PDA',count:36,percent:11}]
const regions=[{name:'华南·广州',count:128},{name:'华南·深圳',count:86},{name:'华南·东莞',count:48},{name:'华南·佛山',count:34}]
const stats=computed(()=>[
  {label:'门店/仓库总数',value:fmt(s.value.storeCount),tip:'↑ 较上月 +12 家',up:true},
  {label:'终端总数',value:fmt(s.value.terminalTotal)},
  {label:'在线终端',value:fmt(s.value.terminalOnline),color:'#16a34a'},
  {label:'今日交易额',value:'¥'+fmt(s.value.todayAmount),color:'#c8462f'}
])
function fmt(v){if(v==null)return '0';v=Number(v);if(v>=1e4)return (v/1e4).toFixed(1)+'万';return v.toLocaleString('zh-CN',{maximumFractionDigits:2})}
async function load(){loading.value=true;try{const r=await pageData(tab.value,{pageNum:pageNum.value,keyword:kw.value});rows.value=r.data.list;total.value=r.data.total}finally{loading.value=false}}
watch(tab,()=>{pageNum.value=1;load()})
onMounted(()=>{load();getStats('store').then(r=>s.value=r.data)})
</script>
<style scoped>
.dist-item{margin-bottom:13px}.dist-top{display:flex;justify-content:space-between;font-size:12px;margin-bottom:6px}.dist-top i{display:inline-block;width:8px;height:8px;border-radius:2px;margin-right:7px}
.region-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}.region-item{background:#f8f9fb;border-radius:6px;padding:10px;text-align:center}.region-num{font-size:18px;font-weight:700;color:#c8462f}.region-name{font-size:11px;color:#909399;margin-top:3px}
</style>
