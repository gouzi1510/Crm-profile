# 穗丰粮仓 · 米面杂粮批发管理平台

基于现有 SpringBoot 项目架构（Spring Boot 3.5 + JdbcTemplate/MyBatis 风格 + MySQL + Vue3 + Element Plus）构建，参照所提供截图的界面样式，行业改为**米面杂粮批发售卖**。所有页面数据全部真实建表存储。

## 仓库说明

本仓库为**纯源码**工程仓库。以下内容**不入库**（见 `.gitignore`）：

- 业务数据 `02_data.sql` —— 由 `backend/.../db/gen_data.py` 本地生成
- 账号数据 `sys_account`（含登录密码）—— 部署脚本现场创建
- 构建产物 `backend/target/`、`frontend/dist/`、`frontend/node_modules/`
- 本地部署产物目录 `liulizhifu/app|web|db`

`03_base_config.sql` 入库，但它只含**应用配置**（角色 / 菜单 / 角色-菜单关联），不含业务数据或账号。

## 快速启动（本地开发）

```bash
# 0. 生成种子数据（需要本地 MySQL，root/root）
python backend/src/main/resources/db/gen_data.py

# 1. 建库 + 灌数据
mysql -uroot -proot < backend/src/main/resources/db/01_schema.sql
mysql -uroot -proot liulizhifu < backend/src/main/resources/db/02_data.sql
mysql -uroot -proot liulizhifu < backend/src/main/resources/db/03_base_config.sql

# 2. 后端（端口 8081）
cd backend && mvn -DskipTests package && java -jar target/liulizhifu-backend-1.0.0.jar

# 3. 前端（端口 5180）
cd frontend && npm install && npm run dev
```

浏览器访问 **http://localhost:5180**。首次用 `gen_data.py` 生成的演示账号登录（默认 `admin / admin123`）。

## Linux 生产部署

克隆仓库后，`liulizhifu/install.sh` 会**自动从源码构建**前后端并部署（详见 `liulizhifu/README.md`）：

```bash
git clone https://github.com/gouzi1510/Ram.git && cd Ram
sudo ADMIN_PWD='你的强密码' bash liulizhifu/install.sh
```

## 模块与数据表对照

| 页面模块 | 主要数据表 |
|---|---|
| 仪表盘 | ml_daily_stat / ml_payment / ml_revenue_rank / ml_notice / ml_system_status |
| 交易中心 | ml_payment（交易流水）、ml_sales_order / ml_sales_order_item |
| 渠道中心 | ml_channel / ml_channel_stat |
| 账户与分账 | ml_account / ml_account_flow / ml_profit_share_rule / ml_profit_share_detail |
| 清结算中心 | ml_settlement_batch / ml_settlement |
| 转账付款 | ml_payment_order / ml_purchase_order |
| 门店与终端 | ml_warehouse / ml_terminal |
| 会员与商品 | ml_member / ml_member_level / ml_goods / ml_goods_category |
| 数据洞察 | ml_daily_stat / ml_channel_stat / ml_warehouse_rank |
| 风控预警 | ml_risk_rule / ml_risk_alert |
| 开放平台 | ml_open_api / ml_open_app |
| 组织与系统 | sys_dept / sys_employee / sys_role / sys_menu / sys_account / sys_operate_log / sys_login_log |
| 业务流程说明 | ml_business_flow |

共 **39 张表**，种子数据 1339 条 INSERT（客户、商品、订单、流水、结算、预警等均可分页/筛选/新增/编辑/删除）。

## 接口设计

- `POST /api/auth/login` 登录（返回 token）
- `GET /api/auth/menus` 菜单树
- `GET /api/dashboard/overview` 仪表盘聚合
- `GET /api/dashboard/insight` 数据洞察聚合
- `GET /api/dashboard/stats/{module}` 各页统计卡
- `GET /api/data/{module}?keyword=&pageNum=&pageSize=&任意筛选列=&startDate=&endDate=` 通用分页查询
- `POST /api/data/{module}` / `PUT /api/data/{module}/{id}` / `DELETE /api/data/{module}/{id}` 通用增删改

后端采用白名单驱动的通用数据服务（与现有项目 CrmService 同思路），新增业务表只需在 `DataService.TABLES` 注册即可复用全部 CRUD。

## 目录结构

```
.
├── start.bat                     # Windows 本地一键启动
├── backend/
│   ├── pom.xml
│   ├── src/main/java/com/liulizhifu/   # common / config / security / controller / service
│   ├── src/main/resources/application.yml
│   └── src/main/resources/db/
│       ├── 01_schema.sql         # 39 张表结构
│       ├── 03_base_config.sql    # 角色/菜单配置（入库）
│       └── gen_data.py           # 种子数据生成器 → 输出 02_data.sql（不入库）
├── frontend/
│   ├── src/views/                # 13 个页面
│   ├── src/components/           # DataTable / LineChart / SparkLine
│   └── vite.config.js            # 代理 /api -> 8081
└── liulizhifu/
    ├── install.sh                # Linux 一键部署（可从源码构建）
    └── README.md                 # 部署说明
```
