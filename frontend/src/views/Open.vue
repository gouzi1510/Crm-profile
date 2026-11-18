<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">开放平台</h1><p class="page-desc">提供标准化 API 接口与开发者工具，助力业务系统快速对接</p></div>
    <div class="card card-pad mb14">
      <div class="toolbar"><div><div class="card-title">API 接口总览</div><div class="card-sub">共 {{ apis.length }} 个接口 · OpenAPI 2.0</div></div><div><el-button :icon="Download">下载 SDK</el-button><el-button type="primary" :icon="Plus">创建应用</el-button></div></div>
      <div class="api-grid">
        <div class="api-group" v-for="g in groups" :key="g">
          <div class="api-group-title"><el-icon><Folder /></el-icon>{{ g }} <span class="api-count">{{ apis.filter(a=>a.api_group===g).length }} 个接口</span></div>
          <div class="api-item" v-for="a in apis.filter(x=>x.api_group===g)" :key="a.id"><el-tag size="small" :type="a.method==='POST'?'primary':'success'" effect="plain">{{ a.method }}</el-tag><span class="api-name">{{ a.api_name }}</span><span class="api-path">{{ a.path }}</span></div>
        </div>
      </div>
    </div>
    <div class="grid-2" style="grid-template-columns:1fr 1fr">
      <div class="card card-pad">
        <div class="card-title mb14">开发者密钥</div>
        <el-descriptions :column="1" border size="small">
          <el-descriptions-item label="应用名称">{{ app?.app_name||'-' }}</el-descriptions-item>
          <el-descriptions-item label="App Key"><code>{{ app?.app_key||'-' }}</code></el-descriptions-item>
          <el-descriptions-item label="App Secret"><code>{{ showSecret?app?.app_secret:'••••••••••••••••' }}</code><el-button link size="small" @click="showSecret=!showSecret">{{ showSecret?'隐藏':'显示' }}</el-button></el-descriptions-item>
          <el-descriptions-item label="回调地址">{{ app?.callback_url||'-' }}</el-descriptions-item>
          <el-descriptions-item label="IP 白名单">{{ app?.ip_whitelist||'-' }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <div class="card card-pad">
        <div class="card-title mb14">接口调用示例</div>
        <div class="code-block"><pre><code>POST /api/v1/orders
Content-Type: application/json
Authorization: Bearer &lt;token&gt;

{
  "customer_name": "广州万佳批发",
  "goods_name": "东北五常大米",
  "qty": 50,
  "amount": 7800.00,
  "pay_method": "微信支付"
}</code></pre></div>
      </div>
    </div>
    <div class="card card-pad mt14"><div class="card-title mb14">SDK 支持</div><div class="sdk-list"><div class="sdk-item" v-for="(s,i) in sdks" :key="i"><div class="sdk-icon">{{ s.icon }}</div><div><b>{{ s.name }}</b><div class="card-sub">版本 {{ s.ver }}</div></div></div></div></div>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { Download, Plus, Folder } from '@element-plus/icons-vue'
import { allData } from '@/api'
const apis=ref([]), apps=ref([]), showSecret=ref(false)
const app=computed(()=>apps.value[0])
const groups=computed(()=>[...new Set(apis.value.map(a=>a.api_group))])
const sdks=[{name:'Java SDK',ver:'v1.2.0',icon:'J'},{name:'Python SDK',ver:'v1.2.0',icon:'P'},{name:'Node.js SDK',ver:'v1.0.0',icon:'N'},{name:'Go SDK',ver:'v1.0.0',icon:'G'},{name:'PHP SDK',ver:'v1.2.0',icon:'PHP'}]
onMounted(async()=>{const [a,b]=await Promise.all([allData('openApi'),allData('openApp')]);apis.value=a.data;apps.value=b.data})
</script>
<style scoped>
.api-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}.api-group{border:1px solid #eef0f4;border-radius:8px;overflow:hidden}
.api-group-title{display:flex;align-items:center;gap:7px;padding:11px 13px;background:#f8f9fb;font-weight:600;font-size:13px}
.api-count{margin-left:auto;font-size:11px;color:#909399;font-weight:400}
.api-item{display:flex;align-items:center;gap:8px;padding:9px 13px;border-top:1px solid #f0f2f5;font-size:12px}
.api-name{font-weight:500}.api-path{color:#a8abb2;margin-left:auto;font-family:monospace;font-size:11px}
code{font-family:'Courier New',monospace;font-size:12px;color:#c8462f}
.code-block{background:#1e293b;border-radius:8px;padding:14px;overflow:auto}.code-block code{color:#a5d6c8;font-size:12px;line-height:1.7}
.mt14{margin-top:14px}.sdk-list{display:flex;gap:14px;flex-wrap:wrap}.sdk-item{display:flex;align-items:center;gap:10px;border:1px solid #eef0f4;border-radius:8px;padding:10px 16px;min-width:140px}.sdk-icon{width:34px;height:34px;border-radius:8px;background:#fdf2ef;color:#c8462f;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:13px}.sdk-item b{font-size:13px}
</style>
