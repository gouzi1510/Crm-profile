import request from './request'

export const login = (data) => request.post('/auth/login', data)
export const logout = () => request.post('/auth/logout')
export const getMenus = () => request.get('/auth/menus')

export const getOverview = () => request.get('/dashboard/overview')
export const getInsight = () => request.get('/dashboard/insight')
export const getStats = (module) => request.get(`/dashboard/stats/${module}`)

// 通用数据接口
export const pageData = (module, params) => request.get(`/data/${module}`, { params })
export const allData = (module, limit) => request.get(`/data/${module}/all`, { params: { limit } })
export const getData = (module, id) => request.get(`/data/${module}/${id}`)
export const createData = (module, data) => request.post(`/data/${module}`, data)
export const updateData = (module, id, data) => request.put(`/data/${module}/${id}`, data)
export const deleteData = (module, id) => request.delete(`/data/${module}/${id}`)
