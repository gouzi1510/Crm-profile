<template>
  <el-container class="layout">
    <el-aside :width="collapsed ? '64px' : '224px'" class="aside">
      <div class="logo">
        <div class="logo-mark">穗</div>
        <div v-show="!collapsed" class="logo-text">
          <div class="logo-name">穗丰粮仓</div>
          <div class="logo-sub">米面杂粮批发管理平台</div>
        </div>
      </div>
      <div class="menu-wrap">
        <el-menu
          :default-active="activeMenu"
          :collapse="collapsed"
          :collapse-transition="false"
          background-color="#ffffff"
          text-color="#5c6570"
          active-text-color="#c8462f"
          router
          unique-opened
        >
          <template v-for="menu in menus" :key="menu.id">
            <el-sub-menu v-if="menu.children && menu.children.length" :index="String(menu.id)">
              <template #title>
                <el-icon><component :is="menu.icon || 'Menu'" /></el-icon>
                <span>{{ menu.name }}</span>
              </template>
              <el-menu-item v-for="child in menu.children" :key="child.id" :index="child.path">
                <el-icon><component :is="child.icon || 'Document'" /></el-icon>
                <template #title>{{ child.name }}</template>
              </el-menu-item>
            </el-sub-menu>
            <el-menu-item v-else :index="menu.path">
              <el-icon><component :is="menu.icon || 'Document'" /></el-icon>
              <template #title>{{ menu.name }}</template>
            </el-menu-item>
          </template>
        </el-menu>
      </div>
      <div class="aside-bottom" v-show="!collapsed">
        <div class="user-mini">
          <el-avatar :size="34" style="background:#c8462f">{{ displayName.charAt(0) }}</el-avatar>
          <div class="user-meta">
            <div class="user-name">{{ displayName }}</div>
            <div class="user-role">{{ store.userInfo?.deptName || '管理员' }}</div>
          </div>
        </div>
      </div>
    </el-aside>

    <el-container>
      <el-header class="header">
        <div class="header-left">
          <el-icon class="collapse-btn" @click="collapsed = !collapsed">
            <Fold v-if="!collapsed" /><Expand v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/dashboard' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="route.meta.title">{{ route.meta.title }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <div class="env-badge"><span class="dot"></span> LIVE · 实时数据</div>
          <span class="date-text">{{ nowText }}</span>
          <el-input v-model="search" placeholder="搜索客户、订单号..." :prefix-icon="Search" class="top-search" size="default" />
          <el-tooltip content="帮助中心"><el-icon class="top-icon"><QuestionFilled /></el-icon></el-tooltip>
          <el-badge :value="6" class="badge"><el-icon class="top-icon"><Bell /></el-icon></el-badge>
          <el-dropdown @command="onCommand">
            <span class="user-info">
              <el-avatar :size="28" style="background:#c8462f">{{ displayName.charAt(0) }}</el-avatar>
              <span class="user-name">{{ displayName }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="main">
        <router-view v-slot="{ Component }">
          <keep-alive :max="5"><component :is="Component" /></keep-alive>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>
<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Fold, Expand, Search, Bell, QuestionFilled, ArrowDown } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import * as icons from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const store = useUserStore()
const collapsed = ref(false)
const search = ref('')
const nowText = ref('')
const activeMenu = computed(() => route.path)
const menus = computed(() => store.menus)
const displayName = computed(() => store.displayName)

let timer = null
function updateTime() {
  const d = new Date()
  const p = (n) => String(n).padStart(2, '0')
  nowText.value = `${d.getFullYear()}-${p(d.getMonth()+1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`
}
onMounted(() => { updateTime(); timer = setInterval(updateTime, 1000) })
onUnmounted(() => clearInterval(timer))

async function onCommand(cmd) {
  if (cmd === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', { type: 'warning' })
      await store.doLogout()
      ElMessage.success('已退出登录')
      router.push('/login')
    } catch (e) {}
  }
}
// 注册图标组件名，供动态 component 使用
for (const [k, v] of Object.entries(icons)) { /* element-plus 全局注册，无需重复 */ }
</script>
<style scoped>
.layout { height: 100vh; }
.aside { background:#fff; border-right:1px solid #eceef2; transition: width .25s; overflow:hidden; display:flex; flex-direction:column; }
.logo { height:64px; display:flex; align-items:center; gap:11px; padding:0 18px; border-bottom:1px solid #f0f2f5; }
.logo-mark { width:36px; height:36px; flex-shrink:0; border-radius:9px; background:#c8462f; color:#fff; font-size:20px; font-weight:800; display:flex; align-items:center; justify-content:center; }
.logo-name { font-size:16px; font-weight:700; color:#2b2f36; letter-spacing:1px; }
.logo-sub { font-size:10px; color:#9aa1ab; margin-top:1px; }
.menu-wrap { flex:1; overflow-y:auto; }
.aside :deep(.el-menu) { border-right:none; }
.aside :deep(.el-menu-item), .aside :deep(.el-sub-menu__title) { height:42px; line-height:42px; font-size:13px; }
.aside :deep(.el-menu-item.is-active) { background:#fdf2ef !important; font-weight:600; border-right:3px solid #c8462f; }
.aside-bottom { padding:14px; border-top:1px solid #f0f2f5; }
.user-mini { display:flex; align-items:center; gap:10px; padding:8px; background:#f8f9fb; border-radius:8px; }
.user-name { font-size:13px; font-weight:600; }
.user-role { font-size:11px; color:#9aa1ab; margin-top:2px; }
.header { height:60px; background:#fff; border-bottom:1px solid #eceef2; display:flex; align-items:center; justify-content:space-between; padding:0 20px; }
.header-left, .header-right { display:flex; align-items:center; gap:14px; }
.collapse-btn { cursor:pointer; font-size:18px; color:#606266; }
.env-badge { font-size:11px; color:#16a34a; background:#f0fdf4; border:1px solid #dcfce7; padding:4px 9px; border-radius:12px; display:flex; align-items:center; gap:5px; }
.env-badge .dot { width:6px; height:6px; border-radius:50%; background:#16a34a; }
.date-text { font-size:12px; color:#909399; }
.top-search { width:210px; }
.top-icon { font-size:18px; color:#606266; cursor:pointer; }
.badge { line-height:1; }
.user-info { display:flex; align-items:center; gap:7px; cursor:pointer; outline:none; }
.main { background:#f4f6f9; padding:0; overflow-y:auto; }
</style>
