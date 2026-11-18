<template>
  <div class="login-page">
    <div class="login-left">
      <div class="brand">
        <div class="brand-icon">穗</div>
        <div>
          <div class="brand-name">穗丰粮仓</div>
          <div class="brand-en">SUIFENG GRAIN DEPOT</div>
        </div>
      </div>
      <div class="slogan">
        <h1>米面杂粮批发<br/>数字化管理平台</h1>
        <p>从采购入库到销售结算，一站式打通粮食批发全链路业务</p>
      </div>
      <div class="features">
        <div class="feature"><span class="fnum">01</span><div><b>交易全流程可追溯</b><small>销售订单、收款流水、发货状态实时同步</small></div></div>
        <div class="feature"><span class="fnum">02</span><div><b>资金结算清晰透明</b><small>账户分账、供应商结算、对账一目了然</small></div></div>
        <div class="feature"><span class="fnum">03</span><div><b>风险智能预警</b><small>信用超限、库存异常、大额交易实时监控</small></div></div>
      </div>
      <div class="copyright">© 2026 穗丰粮仓 · 米面杂粮批发管理平台</div>
    </div>
    <div class="login-right">
      <div class="login-box">
        <h2>欢迎登录</h2>
        <p class="sub">请输入账号和密码进入管理平台</p>
        <el-form ref="formRef" :model="form" :rules="rules" size="large" @keyup.enter="onLogin">
          <el-form-item prop="username">
            <el-input v-model="form.username" placeholder="请输入账号" :prefix-icon="User" />
          </el-form-item>
          <el-form-item prop="password">
            <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" :prefix-icon="Lock" />
          </el-form-item>
          <el-button type="primary" class="login-btn" :loading="loading" @click="onLogin">登 录</el-button>
        </el-form>
        <div class="tips">
          <span>演示账号：</span>
          <el-tag size="small" class="clickable" @click="fill('admin','admin123')">管理员 admin / admin123</el-tag>
          <el-tag size="small" class="clickable" @click="fill('finance','123456')">财务 finance / 123456</el-tag>
          <el-tag size="small" class="clickable" @click="fill('sales','123456')">销售 sales / 123456</el-tag>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { User, Lock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const store = useUserStore()
const formRef = ref()
const loading = ref(false)
const form = reactive({ username: 'admin', password: 'admin123' })
const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}
function fill(u, p) { form.username = u; form.password = p }
async function onLogin() {
  await formRef.value.validate()
  loading.value = true
  try {
    await store.doLogin({ ...form })
    ElMessage.success('登录成功')
    router.push(route.query.redirect || '/dashboard')
  } catch (e) {
    ElMessage.error(e.response?.data?.message || e.message || '登录失败')
  } finally { loading.value = false }
}
</script>
<style scoped>
.login-page { display: flex; height: 100vh; }
.login-left { width: 52%; background: linear-gradient(150deg,#1d4d3c 0%,#2d6b4f 45%,#c8462f 140%); color: #fff; padding: 48px 60px; display: flex; flex-direction: column; position: relative; overflow: hidden; }
.login-left::after { content:''; position:absolute; right:-120px; top:-120px; width:420px; height:420px; border:1px solid rgba(255,255,255,.12); border-radius:50%; }
.brand { display:flex; align-items:center; gap:14px; }
.brand-icon { width:48px; height:48px; border-radius:12px; background:#fff; color:#c8462f; font-size:26px; font-weight:800; display:flex; align-items:center; justify-content:center; }
.brand-name { font-size:22px; font-weight:700; letter-spacing:2px; }
.brand-en { font-size:10px; letter-spacing:2px; opacity:.6; margin-top:2px; }
.slogan { margin-top:100px; }
.slogan h1 { font-size:40px; line-height:1.4; margin:0 0 18px; font-weight:700; }
.slogan p { font-size:15px; opacity:.8; margin:0; }
.features { margin-top:60px; display:flex; flex-direction:column; gap:22px; }
.feature { display:flex; gap:16px; align-items:flex-start; }
.fnum { font-size:14px; opacity:.5; font-weight:700; padding-top:2px; }
.feature b { display:block; font-size:15px; margin-bottom:4px; }
.feature small { opacity:.7; font-size:12px; }
.copyright { position:absolute; bottom:26px; left:60px; font-size:11px; opacity:.5; }
.login-right { flex:1; display:flex; align-items:center; justify-content:center; background:#fff; }
.login-box { width:380px; }
.login-box h2 { font-size:26px; margin:0 0 6px; }
.login-box .sub { color:#909399; margin:0 0 30px; font-size:13px; }
.login-btn { width:100%; height:44px; font-size:15px; letter-spacing:4px; }
.tips { margin-top:20px; font-size:12px; color:#909399; display:flex; flex-wrap:wrap; gap:6px; align-items:center; }
.clickable { cursor:pointer; }
</style>
