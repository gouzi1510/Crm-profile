import { createRouter, createWebHistory } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const routes = [
  { path: '/login', name: 'Login', component: () => import('@/views/Login.vue'), meta: { public: true, title: '登录' } },
  {
    path: '/',
    component: () => import('@/layout/MainLayout.vue'),
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('@/views/Dashboard.vue'), meta: { title: '仪表盘' } },
      { path: 'trade', name: 'Trade', component: () => import('@/views/Trade.vue'), meta: { title: '交易中心' } },
      { path: 'channel', name: 'Channel', component: () => import('@/views/Channel.vue'), meta: { title: '渠道中心' } },
      { path: 'account', name: 'Account', component: () => import('@/views/Account.vue'), meta: { title: '账户与分账' } },
      { path: 'settlement', name: 'Settlement', component: () => import('@/views/Settlement.vue'), meta: { title: '清结算中心' } },
      { path: 'payment', name: 'Payment', component: () => import('@/views/Payment.vue'), meta: { title: '转账付款' } },
      { path: 'store', name: 'Store', component: () => import('@/views/Store.vue'), meta: { title: '门店与终端' } },
      { path: 'member', name: 'Member', component: () => import('@/views/Member.vue'), meta: { title: '会员与商品' } },
      { path: 'insight', name: 'Insight', component: () => import('@/views/Insight.vue'), meta: { title: '数据洞察' } },
      { path: 'risk', name: 'Risk', component: () => import('@/views/Risk.vue'), meta: { title: '风控预警' } },
      { path: 'open', name: 'Open', component: () => import('@/views/Open.vue'), meta: { title: '开放平台' } },
      { path: 'system', name: 'System', component: () => import('@/views/System.vue'), meta: { title: '组织与系统' } },
      { path: 'flow', name: 'Flow', component: () => import('@/views/Flow.vue'), meta: { title: '业务流程说明' } }
    ]
  },
  { path: '/:pathMatch(.*)*', redirect: '/dashboard' }
]

const router = createRouter({ history: createWebHistory(), routes })

router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  document.title = to.meta.title ? `${to.meta.title} - 穗丰粮仓` : '穗丰粮仓 · 米面杂粮批发管理平台'
  if (to.meta.public) return next()
  if (!userStore.isLogin) return next({ path: '/login', query: { redirect: to.fullPath } })
  next()
})

export default router
