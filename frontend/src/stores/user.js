import { defineStore } from 'pinia'
import { login as apiLogin, logout as apiLogout, getMenus } from '@/api'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('ll_token') || '',
    userInfo: JSON.parse(localStorage.getItem('ll_user') || 'null'),
    menus: []
  }),
  getters: {
    isLogin: (s) => !!s.token,
    displayName: (s) => s.userInfo?.realName || s.userInfo?.username || '管理员'
  },
  actions: {
    async doLogin(data) {
      const res = await apiLogin(data)
      this.token = res.data.token
      this.userInfo = res.data.userInfo
      localStorage.setItem('ll_token', this.token)
      localStorage.setItem('ll_user', JSON.stringify(this.userInfo))
      await this.loadMenus()
      return res
    },
    async loadMenus() {
      const res = await getMenus()
      this.menus = res.data
    },
    async doLogout() {
      try { await apiLogout() } catch (e) {}
      this.token = ''
      this.userInfo = null
      this.menus = []
      localStorage.removeItem('ll_token')
      localStorage.removeItem('ll_user')
    }
  }
})
