<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">会员与商品</h1><p class="page-desc">洞察会员消费行为，优化米面杂粮商品结构与营销策略</p></div>
    <div class="stat-grid">
      <div class="stat-card" v-for="s in stats" :key="s.label"><div class="label">{{ s.label }}</div><div class="value" :style="{color:s.color}">{{ s.value }}</div><div class="trend" v-if="s.tip">{{ s.tip }}</div></div>
    </div>
    <div class="grid-2">
      <div class="card"><div class="section-title">会员等级分布</div><div style="padding:0 18px 16px"><div class="level-item" v-for="(l,i) in levels" :key="i"><div class="level-top"><span><i :style="{background:l.color}"></i>{{ l.level_name }}</span><span class="level-num">{{ fmt(l.member_count) }} 人 <b>· ¥{{ fmt(l.avg_consume) }}/人</b></span></div><el-progress :percentage="l.percent" :stroke-width="9" :show-text="false" :color="l.color" /></div></div></div>
      <div class="card"><div class="section-title">热销商品 TOP 6</div><div class="goods-grid"><div class="goods-item" v-for="(g,i) in hotGoods" :key="i"><div class="goods-img" :style="{background:g.bg}">{{ g.icon }}</div><div class="goods-name">{{ g.name }}</div><div class="goods-sales">销量 {{ g.sales }}</div></div></div></div>
    </div>
    <div class="grid-2" style="grid-template-columns:1fr 1fr">
      <div class="card card-pad">
        <div class="toolbar"><div class="card-title">高价值会员 · 近30天</div><el-button link type="primary">查看全部 →</el-button></div>
        <el-table :data="members" size="small"><el-table-column prop="member_name" label="会员" width="90" /><el-table-column prop="level" label="等级" width="80"><template #default="{row}"><span :class="levelClass(row.level)">{{ row.level }}</span></template></el-table-column><el-table-column prop="total_amount" label="消费金额" width="110" align="right"><template #default="{row}">¥{{ Number(row.total_amount).toFixed(0) }}</template></el-table-column><el-table-column prop="order_count" label="订单数" width="80" /><el-table-column prop="store_name" label="所属门店" min-width="150" /></el-table>
      </div>
      <div class="card card-pad">
        <div class="toolbar"><div class="card-title">商品库存 TOP</div><el-button link type="primary">商品管理 →</el-button></div>
        <el-table :data="goods" size="small"><el-table-column prop="goods_name" label="商品名称" min-width="150" /><el-table-column prop="category" label="分类" width="80" /><el-table-column prop="spec" label="规格" width="100" /><el-table-column prop="sale_price" label="批发价" width="90" align="right"><template #default="{row}">¥{{ Number(row.sale_price).toFixed(0) }}</template></el-table-column><el-table-column prop="stock_qty" label="库存" width="90"><template #default="{row}"><span :class="row.stock_qty<row.warning_qty?'text-danger':''">{{ row.stock_qty }}</span></template></el-table-column></el-table>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { allData, getStats, pageData } from '@/api'
const s=ref({}), levels=ref([]), members=ref([]), goods=ref([])
const stats=computed(()=>[
  {label:'会员总数',value:fmt(s.value.memberCount),tip:'↑ 较上月 +3.2%',up:true},
  {label:'会员消费额',value:'¥'+fmt(s.value.memberAmount),color:'#c8462f'},
  {label:'商品种类',value:fmt(s.value.goodsCount)},
  {label:'复购率',value:(s.value.repurchaseRate||0).toFixed(1)+'%',color:'#16a34a',tip:'↑ 较上月 +1.2%',up:true}
])
const hotGoods=[
  {name:'东北五常大米',sales:'12,480',icon:'米',bg:'linear-gradient(135deg,#e8d5b7,#c9a876)'},
  {name:'高筋面粉',sales:'9,856',icon:'面',bg:'linear-gradient(135deg,#f0e6d2,#d9c39a)'},
  {name:'绿色小米',sales:'8,240',icon:'谷',bg:'linear-gradient(135deg,#e8dc9a,#c9b84e)'},
  {name:'鲁花花生油',sales:'6,780',icon:'油',bg:'linear-gradient(135deg,#f5d99a,#d9a441)'},
  {name:'鸡蛋挂面',sales:'5,420',icon:'面',bg:'linear-gradient(135deg,#f0dfc0,#d0b078)'},
  {name:'有机燕麦',sales:'4,180',icon:'燕',bg:'linear-gradient(135deg,#d9e0b0,#a8b860)'}
]
function fmt(v){if(v==null)return '0';v=Number(v);if(v>=1e8)return (v/1e8).toFixed(2)+'亿';if(v>=1e4)return (v/1e4).toFixed(1)+'万';return v.toLocaleString('zh-CN',{maximumFractionDigits:2})}
function levelClass(v){const m={'钻石':'text-danger','金卡':'text-warn','银卡':'text-info','VIP':'text-danger'};return m[v]||'text-info'}
onMounted(async()=>{
  const [st,lv,me,go]=await Promise.all([getStats('member'),allData('memberLevel'),pageData('member',{pageNum:1,pageSize:6}),pageData('goods',{pageNum:1,pageSize:6,sort:'stock_qty asc'})])
  s.value=st.data
  const max=Math.max(...lv.data.map(x=>x.member_count),1)
  levels.value=lv.data.map(x=>({...x,percent:Math.round(x.member_count/max*100),color:({'钻石':'#c8462f','金卡':'#d9a441','银卡':'#909399','普通':'#2f8f83'}[x.level_name] || '#2f8f83')}))
  members.value=me.data.list; goods.value=go.data.list
})
</script>
<style scoped>
.level-item{margin-bottom:14px}.level-top{display:flex;justify-content:space-between;font-size:12px;margin-bottom:6px}.level-top i{display:inline-block;width:9px;height:9px;border-radius:2px;margin-right:8px}.level-num b{color:#909399;font-weight:400}
.goods-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;padding:6px 18px 16px}
.goods-item{border:1px solid #eef0f4;border-radius:8px;overflow:hidden;text-align:center}
.goods-img{height:70px;display:flex;align-items:center;justify-content:center;font-size:28px;color:#fff;font-weight:700}
.goods-name{font-size:12px;font-weight:600;margin-top:7px;padding:0 4px}
.goods-sales{font-size:11px;color:#909399;margin:3px 0 8px}
</style>
