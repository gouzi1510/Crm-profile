<template>
  <div class="page-container">
    <div class="page-head">
      <h1 class="page-title">{{ title }}</h1>
      <p class="page-desc">{{ desc }}</p>
    </div>

    <!-- 统计卡 -->
    <div class="stat-grid" :class="{sub: stats.length >= 5}" v-if="stats.length">
      <div class="stat-card" v-for="s in stats" :key="s.label">
        <div class="label">{{ s.label }}</div>
        <div class="value" :style="{color:s.color||'#2b2f36'}">{{ s.value }}</div>
        <div class="trend" v-if="s.tip" :class="s.up?'up':'down'">{{ s.tip }}</div>
      </div>
    </div>

    <div class="card card-pad">
      <!-- tabs -->
      <el-tabs v-if="tabs.length" v-model="activeTab" @tab-change="load(1)">
        <el-tab-pane v-for="t in tabs" :key="t.value" :label="t.label" :name="t.value" />
      </el-tabs>

      <!-- 搜索栏 -->
      <div class="search-bar" v-if="searchFields.length || keyword">
        <el-input v-if="keyword" v-model="kw" :placeholder="keyword" :prefix-icon="Search" clearable />
        <el-select v-for="f in searchFields" :key="f.key" v-model="filters[f.key]" :placeholder="f.label" clearable :style="{width:(f.width||140)+'px'}">
          <el-option v-for="o in f.options" :key="o" :label="o" :value="o" />
        </el-select>
        <el-button type="primary" :icon="Search" @click="load(1)">查询</el-button>
        <el-button :icon="Refresh" @click="reset">重置</el-button>
        <slot name="toolbar">
          <el-button v-if="creatable" type="primary" style="margin-left:auto" :icon="Plus" @click="$emit('create')">新增</el-button>
        </slot>
      </div>

      <slot name="extra" />

      <el-table :data="rows" size="small" stripe v-loading="loading" style="width:100%" @row-dblclick="(r)=>$emit('row-dblclick',r)">
        <el-table-column v-for="c in columns" :key="c.prop" :prop="c.prop" :label="c.label"
                         :width="c.width" :min-width="c.minWidth" :align="c.align"
                         :fixed="c.fixed" :sortable="c.sortable">
          <template #default="{row}" v-if="c.type">
            <span v-if="c.type==='money'" :class="c.moneyClass || (row[c.prop]>=0?'text-danger':'')">{{ Number(row[c.prop]).toFixed(2) }}</span>
            <el-tag v-else-if="c.type==='tag'" size="small" :type="tagType(row[c.prop])" effect="light">{{ row[c.prop] }}</el-tag>
            <span v-else-if="c.type==='dot'" class="tag-dot" :class="statusClass(row[c.prop])">{{ row[c.prop] }}</span>
            <span v-else-if="c.type==='level'" :class="levelClass(row[c.prop])">{{ levelText(row[c.prop]) }}</span>
            <el-progress v-else-if="c.type==='progress'" :percentage="Number(row[c.prop])" :stroke-width="6" :show-text="false" color="#2f8f83" />
            <span v-else>{{ row[c.prop] }}</span>
          </template>
        </el-table-column>
        <el-table-column v-if="actions.length" label="操作" :width="actions.length*56+20" fixed="right">
          <template #default="{row}">
            <el-button v-for="a in actions" :key="a.label" link type="primary" size="small" @click="$emit('action',{action:a.key,row})">{{ a.label }}</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-bar">
        <el-pagination background layout="total, sizes, prev, pager, next" :total="total"
                       v-model:current-page="pageNum" v-model:page-size="pageSize"
                       :page-sizes="[10,20,50]" @current-change="load()" @size-change="load(1)" />
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted, watch } from 'vue'
import { Search, Refresh, Plus } from '@element-plus/icons-vue'
import { pageData } from '@/api'

const props = defineProps({
  title: String, desc: String, module: String,
  stats: { type:Array, default:()=>[] },
  columns: { type:Array, default:()=>[] },
  keyword: { type:String, default:'' },
  searchFields: { type:Array, default:()=>[] },
  tabs: { type:Array, default:()=>[] },
  defaultSort: String,
  extraFilters: { type:Object, default:()=>({}) },
  actions: { type:Array, default:()=>[] },
  creatable: Boolean
})
const emit = defineEmits(['create','action','row-dblclick','loaded'])

const loading = ref(false), rows = ref([]), total = ref(0)
const kw = ref(''), filters = ref({})
const activeTab = ref(props.tabs.length ? props.tabs[0].value : 'all')
const pageNum = ref(1), pageSize = ref(10)

function tagType(v) {
  const m = { '成功':'success','正常':'success','已结算':'success','已完成':'success','已通过':'success','已付款':'success','在线':'success','启用':'success','在售':'success','已开放':'success','运营中':'success',
    '待结算':'warning','待审核':'warning','审核中':'warning','待收发货':'warning','待发货':'warning','进行中':'warning','处理中':'warning','未处理':'warning','筹备中':'warning','结算中':'warning','退款中':'warning','待收款':'warning','支付中':'warning',
    '失败':'danger','已取消':'danger','审核拒绝':'danger','故障':'danger','停用':'danger','停售':'danger','异常':'danger','冻结':'danger','已处理':'info','离线':'info','已送达':'info' }
  return m[v] || 'info'
}
function statusClass(v) { return tagType(v)==='success'?'text-success': tagType(v)==='danger'?'text-danger':'text-warn' }
function levelText(v){ return v || '普通' }
function levelClass(v){ const m={'钻石':'text-danger','金卡':'text-warn','银卡':'text-info','VIP':'text-danger'}; return m[v]||'text-info' }

async function load(p) {
  if (p) pageNum.value = p
  loading.value = true
  const params = { pageNum:pageNum.value, pageSize:pageSize.value, keyword:kw.value, ...props.extraFilters }
  Object.entries(filters.value).forEach(([k,v])=>{ if(v) params[k]=v })
  if (props.tabs.length && activeTab.value !== 'all') {
    const t = props.tabs.find(x=>x.value===activeTab.value)
    if (t?.filterKey) params[t.filterKey] = t.filterValue !== undefined ? t.filterValue : activeTab.value
  }
  if (props.defaultSort) params.sort = props.defaultSort
  try {
    const r = await pageData(props.module, params)
    rows.value = r.data.list; total.value = r.data.total
    emit('loaded', r.data)
  } finally { loading.value = false }
}
function reset(){ kw.value=''; filters.value={}; activeTab.value = props.tabs.length?props.tabs[0].value:'all'; load(1) }
watch(()=>props.module, ()=>load(1))
onMounted(()=>load(1))
defineExpose({ load, rows })
</script>
