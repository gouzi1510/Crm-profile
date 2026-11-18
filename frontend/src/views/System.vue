<template>
  <div class="page-container">
    <div class="page-head"><h1 class="page-title">组织与系统</h1><p class="page-desc">企业信息、角色权限、系统配置与安全管理</p></div>
    <div class="module-grid">
      <div class="module-card" v-for="m in modules" :key="m.title" @click="onModule(m)">
        <div class="module-icon" :style="{background:m.bg,color:m.color}"><el-icon :size="22"><component :is="m.icon" /></el-icon></div>
        <div class="module-info"><div class="module-title">{{ m.title }}</div><div class="module-desc">{{ m.desc }}</div></div>
        <div class="module-badge" :class="m.badgeType">{{ m.badge }}</div>
      </div>
    </div>
    <div class="grid-2" style="grid-template-columns:1fr 1fr">
      <div class="card card-pad">
        <div class="toolbar"><div class="card-title">角色权限</div><el-button link type="primary" @click="roleVisible=true">管理 →</el-button></div>
        <el-table :data="roles" size="small"><el-table-column prop="role_name" label="角色名称" width="120" /><el-table-column label="人数" width="70"><template #default="{row}">{{ Math.floor(Math.random()*20)+2 }}</template></el-table-column><el-table-column prop="data_scope" label="数据范围" width="120"><template #default="{row}">{{ {1:'全部数据',2:'本部门',4:'仅本人'}[row.data_scope] }}</template></el-table-column><el-table-column prop="status" label="状态" width="80"><template #default><el-tag size="small" type="success" effect="light">正常</el-tag></template></el-table-column></el-table>
      </div>
      <div class="card card-pad">
        <div class="toolbar"><div class="card-title">最近操作日志</div><el-button link type="primary">全部日志 →</el-button></div>
        <div class="log-item" v-for="(l,i) in logs" :key="i"><span class="log-time">{{ l.create_time?.slice(5,16) }}</span><span class="log-op">{{ l.operator }}</span><span class="log-content">{{ l.content }}</span><el-tag size="small" type="success" effect="light">成功</el-tag></div>
      </div>
    </div>
    <el-dialog v-model="roleVisible" title="角色管理" width="700px"><el-table :data="roles" size="small"><el-table-column prop="role_code" label="角色编码" /><el-table-column prop="role_name" label="角色名称" /><el-table-column prop="data_scope" label="数据范围" /><el-table-column prop="remark" label="说明" /></el-table></el-dialog>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { OfficeBuilding, UserFilled, Lock, Message, Document, Files, Calendar, TrendCharts } from '@element-plus/icons-vue'
import { allData } from '@/api'
const roles=ref([]), logs=ref([]), roleVisible=ref(false)
const modules=[
  {title:'企业信息',desc:'企业名称、营业执照、联系人',badge:'已认证',badgeType:'success',icon:OfficeBuilding,bg:'#fdf2ef',color:'#c8462f'},
  {title:'角色与权限',desc:'角色配置、菜单权限、数据范围',badge:'6 个角色',badgeType:'info',icon:UserFilled,bg:'#eff6ff',color:'#5b8def'},
  {title:'安全设置',desc:'密码策略、登录限制、双因素认证',badge:'已启用',badgeType:'success',icon:Lock,bg:'#f0fdf4',color:'#16a34a'},
  {title:'通知与消息模板',desc:'短信、站内信、消息推送模板',badge:'12 条',badgeType:'info',icon:Message,bg:'#fefce8',color:'#d9a441'},
  {title:'开票与财务',desc:'发票管理、税率配置、财务报表',badge:'已配置',badgeType:'success',icon:Document,bg:'#f5f3ff',color:'#8e6ee0'},
  {title:'合规资料',desc:'资质文件、检验报告、许可证',badge:'12 份',badgeType:'info',icon:Files,bg:'#f0fdfa',color:'#2f8f83'},
  {title:'操作日志',desc:'记录所有关键业务操作',badge:'30 条',badgeType:'info',icon:Calendar,bg:'#fff7ed',color:'#e6a23c'},
  {title:'登录日志',desc:'登录记录、设备与 IP 追踪',badge:'20 条',badgeType:'info',icon:TrendCharts,bg:'#fdf2f8',color:'#d946a0'}
]
function onModule(m){ if(m.title==='角色与权限') roleVisible.value=true; else ElMessage.info(m.title+'：'+m.desc) }
onMounted(async()=>{const [r,l]=await Promise.all([allData('role'),allData('operateLog',10)]);roles.value=r.data;logs.value=l.data})
</script>
<style scoped>
.module-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:14px}
.module-card{display:flex;align-items:center;gap:12px;background:#fff;border:1px solid #eef0f4;border-radius:8px;padding:14px;cursor:pointer;transition:all .2s}
.module-card:hover{box-shadow:0 4px 14px rgba(16,24,40,.08);transform:translateY(-2px)}
.module-icon{width:42px;height:42px;border-radius:9px;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.module-info{flex:1;min-width:0}.module-title{font-size:13px;font-weight:600}.module-desc{font-size:11px;color:#a8abb2;margin-top:3px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.module-badge{font-size:10px;padding:2px 7px;border-radius:9px;flex-shrink:0}.module-badge.success{background:#f0fdf4;color:#16a34a}.module-badge.info{background:#f0f2f5;color:#909399}
.log-item{display:flex;align-items:center;gap:9px;padding:8px 0;border-bottom:1px dashed #f0f2f5;font-size:12px}.log-time{color:#a8abb2;flex-shrink:0}.log-op{font-weight:600;flex-shrink:0}.log-content{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
</style>
