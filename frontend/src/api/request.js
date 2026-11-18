import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const request = axios.create({ baseURL: '/api', timeout: 15000 })

request.interceptors.request.use((config) => {
  const token = localStorage.getItem('ll_token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

request.interceptors.response.use(
  (res) => {
    const r = res.data
    if (r.code === 200) return r
    if (r.code === 401) {
      localStorage.removeItem('ll_token')
      localStorage.removeItem('ll_user')
      ElMessage.error(r.message || '登录已过期')
      router.push('/login')
    } else {
      ElMessage.error(r.message || '请求失败')
    }
    return Promise.reject(new Error(r.message))
  },
  (err) => {
    ElMessage.error(err.message || '网络异常')
    return Promise.reject(err)
  }
)

export default request
