-- ============================================================================
--  穗丰粮仓 · 米面杂粮批发管理平台  数据库设计
--  数据库：liulizhifu   引擎：InnoDB   字符集：utf8mb4
--  MySQL 5.7 / 8.0 兼容（排序规则用 utf8mb4_general_ci）
-- ============================================================================
CREATE DATABASE IF NOT EXISTS liulizhifu DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE liulizhifu;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 一、组织与权限
-- ============================================================================
CREATE TABLE IF NOT EXISTS sys_dept (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  parent_id BIGINT NOT NULL DEFAULT 0 COMMENT '父部门',
  ancestors VARCHAR(500) NOT NULL DEFAULT '0' COMMENT '祖级路径',
  dept_name VARCHAR(50) NOT NULL COMMENT '部门名称',
  dept_code VARCHAR(30) NOT NULL COMMENT '部门编码',
  level TINYINT NOT NULL DEFAULT 1 COMMENT '层级',
  order_num INT NOT NULL DEFAULT 0 COMMENT '排序',
  leader VARCHAR(30) DEFAULT NULL COMMENT '负责人',
  phone VARCHAR(20) DEFAULT NULL COMMENT '电话',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1正常0停用',
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_dept_code (dept_code, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

CREATE TABLE IF NOT EXISTS sys_employee (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '员工ID',
  emp_no VARCHAR(20) NOT NULL COMMENT '工号',
  emp_name VARCHAR(30) NOT NULL COMMENT '姓名',
  gender TINYINT NOT NULL DEFAULT 1 COMMENT '1男2女',
  phone VARCHAR(20) DEFAULT NULL COMMENT '手机',
  dept_id BIGINT NOT NULL COMMENT '部门ID',
  position VARCHAR(40) DEFAULT NULL COMMENT '岗位',
  job_level VARCHAR(20) DEFAULT NULL COMMENT '职级',
  hire_date DATE DEFAULT NULL COMMENT '入职日期',
  emp_status TINYINT NOT NULL DEFAULT 1 COMMENT '1在职3离职',
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_emp_no (emp_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表';

CREATE TABLE IF NOT EXISTS sys_role (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  role_code VARCHAR(40) NOT NULL COMMENT '角色编码',
  role_name VARCHAR(50) NOT NULL COMMENT '角色名称',
  data_scope TINYINT NOT NULL DEFAULT 1 COMMENT '数据范围1全部2本部门4仅本人',
  order_num INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_role_code (role_code, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

CREATE TABLE IF NOT EXISTS sys_menu (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  parent_id BIGINT NOT NULL DEFAULT 0,
  menu_name VARCHAR(50) NOT NULL COMMENT '菜单名称',
  path VARCHAR(100) DEFAULT NULL COMMENT '前端路由',
  icon VARCHAR(50) DEFAULT NULL COMMENT '图标',
  type TINYINT NOT NULL DEFAULT 2 COMMENT '1目录2菜单3按钮',
  perm VARCHAR(80) DEFAULT NULL COMMENT '权限标识',
  order_num INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单表';

CREATE TABLE IF NOT EXISTS sys_role_menu (
  id BIGINT NOT NULL AUTO_INCREMENT,
  role_id BIGINT NOT NULL,
  menu_id BIGINT NOT NULL,
  PRIMARY KEY (id), UNIQUE KEY uk_rm (role_id, menu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色菜单关联';

CREATE TABLE IF NOT EXISTS sys_account (
  id BIGINT NOT NULL AUTO_INCREMENT COMMENT '账号ID',
  emp_id BIGINT DEFAULT NULL COMMENT '员工ID',
  username VARCHAR(30) NOT NULL COMMENT '登录账号',
  password VARCHAR(100) NOT NULL COMMENT '密码(加密)',
  real_name VARCHAR(30) DEFAULT NULL COMMENT '姓名',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1正常0停用',
  last_login DATETIME DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_username (username, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录账号表';

CREATE TABLE IF NOT EXISTS sys_operate_log (
  id BIGINT NOT NULL AUTO_INCREMENT,
  operator VARCHAR(30) NOT NULL COMMENT '操作人',
  module VARCHAR(50) DEFAULT NULL COMMENT '模块',
  content VARCHAR(300) NOT NULL COMMENT '操作内容',
  ip VARCHAR(40) DEFAULT NULL COMMENT 'IP',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1成功0失败',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), KEY idx_ol_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志';

CREATE TABLE IF NOT EXISTS sys_login_log (
  id BIGINT NOT NULL AUTO_INCREMENT,
  username VARCHAR(30) NOT NULL,
  ip VARCHAR(40) DEFAULT NULL,
  device VARCHAR(50) DEFAULT NULL,
  status TINYINT NOT NULL DEFAULT 1,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), KEY idx_ll_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录日志';

-- ============================================================================
-- 二、基础资料
-- ============================================================================
CREATE TABLE IF NOT EXISTS ml_warehouse (
  id BIGINT NOT NULL AUTO_INCREMENT,
  store_no VARCHAR(30) NOT NULL COMMENT '门店/仓编号',
  store_name VARCHAR(80) NOT NULL COMMENT '名称',
  store_type VARCHAR(20) DEFAULT '批发门店' COMMENT '批发门店/中心仓/前置仓',
  region VARCHAR(40) DEFAULT NULL COMMENT '区域',
  address VARCHAR(200) DEFAULT NULL COMMENT '地址',
  manager VARCHAR(30) DEFAULT NULL COMMENT '负责人',
  phone VARCHAR(20) DEFAULT NULL COMMENT '电话',
  terminal_count INT DEFAULT 0 COMMENT '终端数',
  today_amount DECIMAL(14,2) DEFAULT 0 COMMENT '今日交易额',
  status VARCHAR(10) NOT NULL DEFAULT '运营中' COMMENT '运营中/筹备中/停用',
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_store_no (store_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='门店与仓库';

CREATE TABLE IF NOT EXISTS ml_terminal (
  id BIGINT NOT NULL AUTO_INCREMENT,
  terminal_no VARCHAR(30) NOT NULL COMMENT '终端编号',
  terminal_type VARCHAR(30) DEFAULT NULL COMMENT '终端类型:POS一体机/扫码枪/电子秤/手持PDA',
  store_name VARCHAR(80) DEFAULT NULL COMMENT '所属门店',
  status VARCHAR(10) NOT NULL DEFAULT '在线' COMMENT '在线/离线/故障',
  today_amount DECIMAL(14,2) DEFAULT 0,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_terminal_no (terminal_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='终端设备';

CREATE TABLE IF NOT EXISTS ml_goods_category (
  id BIGINT NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(40) NOT NULL COMMENT '分类名:大米/面粉/杂粮/食用油/挂面/豆类',
  category_code VARCHAR(30) NOT NULL,
  order_num INT DEFAULT 0,
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_cat_code (category_code, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类';

CREATE TABLE IF NOT EXISTS ml_goods (
  id BIGINT NOT NULL AUTO_INCREMENT,
  goods_no VARCHAR(30) NOT NULL COMMENT 'SKU编码',
  goods_name VARCHAR(100) NOT NULL COMMENT '商品名称',
  category VARCHAR(30) DEFAULT NULL COMMENT '分类',
  spec VARCHAR(40) DEFAULT NULL COMMENT '规格:25kg/袋',
  unit VARCHAR(10) DEFAULT '袋' COMMENT '单位',
  brand VARCHAR(40) DEFAULT NULL COMMENT '品牌/产地',
  purchase_price DECIMAL(12,2) DEFAULT 0 COMMENT '进价',
  sale_price DECIMAL(12,2) DEFAULT 0 COMMENT '批发价',
  stock_qty DECIMAL(14,2) DEFAULT 0 COMMENT '库存量',
  warning_qty DECIMAL(14,2) DEFAULT 0 COMMENT '预警库存',
  sales_count INT DEFAULT 0 COMMENT '累计销量',
  status VARCHAR(10) NOT NULL DEFAULT '在售' COMMENT '在售/停售',
  remark VARCHAR(300) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_goods_no (goods_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SKU';

CREATE TABLE IF NOT EXISTS ml_customer (
  id BIGINT NOT NULL AUTO_INCREMENT,
  customer_no VARCHAR(30) NOT NULL COMMENT '客户编号',
  customer_name VARCHAR(100) NOT NULL COMMENT '客户名称',
  customer_type VARCHAR(30) DEFAULT '批发商' COMMENT '批发商/商超/餐饮/食堂/零售',
  level VARCHAR(20) DEFAULT '普通' COMMENT 'VIP/钻石/金卡/银卡/普通',
  contact VARCHAR(30) DEFAULT NULL COMMENT '联系人',
  phone VARCHAR(20) DEFAULT NULL COMMENT '电话',
  region VARCHAR(40) DEFAULT NULL COMMENT '区域',
  address VARCHAR(200) DEFAULT NULL,
  credit_limit DECIMAL(14,2) DEFAULT 0 COMMENT '授信额度',
  receivable DECIMAL(14,2) DEFAULT 0 COMMENT '应收余额',
  total_amount DECIMAL(16,2) DEFAULT 0 COMMENT '累计交易额',
  status VARCHAR(10) NOT NULL DEFAULT '正常' COMMENT '正常/冻结/潜在',
  owner VARCHAR(30) DEFAULT NULL COMMENT '归属业务员',
  remark VARCHAR(300) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_customer_no (customer_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户';

CREATE TABLE IF NOT EXISTS ml_supplier (
  id BIGINT NOT NULL AUTO_INCREMENT,
  supplier_no VARCHAR(30) NOT NULL COMMENT '供应商编号',
  supplier_name VARCHAR(100) NOT NULL COMMENT '供应商名称',
  supply_type VARCHAR(30) DEFAULT NULL COMMENT '供货类型:产地粮农/面粉厂/油厂',
  region VARCHAR(40) DEFAULT NULL COMMENT '产地',
  contact VARCHAR(30) DEFAULT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  payable DECIMAL(14,2) DEFAULT 0 COMMENT '应付余额',
  settle_cycle VARCHAR(20) DEFAULT '月结30天' COMMENT '结算周期',
  status VARCHAR(10) NOT NULL DEFAULT '合作中',
  remark VARCHAR(300) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_supplier_no (supplier_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商';

CREATE TABLE IF NOT EXISTS ml_member (
  id BIGINT NOT NULL AUTO_INCREMENT,
  member_no VARCHAR(30) NOT NULL COMMENT '会员编号',
  member_name VARCHAR(60) NOT NULL COMMENT '会员名称',
  level VARCHAR(20) DEFAULT '普通' COMMENT '会员等级',
  phone VARCHAR(20) DEFAULT NULL,
  region VARCHAR(40) DEFAULT NULL,
  total_amount DECIMAL(14,2) DEFAULT 0 COMMENT '累计消费',
  order_count INT DEFAULT 0 COMMENT '订单数',
  points INT DEFAULT 0 COMMENT '积分',
  last_order DATETIME DEFAULT NULL COMMENT '最近下单',
  store_name VARCHAR(80) DEFAULT NULL COMMENT '所属门店',
  status VARCHAR(10) NOT NULL DEFAULT '正常',
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_member_no (member_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员';

CREATE TABLE IF NOT EXISTS ml_member_level (
  id BIGINT NOT NULL AUTO_INCREMENT,
  level_name VARCHAR(20) NOT NULL COMMENT '等级名',
  member_count INT DEFAULT 0 COMMENT '人数',
  avg_consume DECIMAL(12,2) DEFAULT 0 COMMENT '人均消费',
  discount VARCHAR(20) DEFAULT NULL COMMENT '折扣权益',
  color VARCHAR(20) DEFAULT NULL,
  order_num INT DEFAULT 0,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员等级';

CREATE TABLE IF NOT EXISTS ml_channel (
  id BIGINT NOT NULL AUTO_INCREMENT,
  channel_name VARCHAR(50) NOT NULL COMMENT '渠道名称',
  channel_type VARCHAR(30) DEFAULT NULL COMMENT '批发档口/商超/餐饮/线上/团购',
  merchant_no VARCHAR(40) DEFAULT NULL COMMENT '渠道编号',
  trade_ratio DECIMAL(6,2) DEFAULT 0 COMMENT '交易占比%',
  today_count INT DEFAULT 0 COMMENT '今日交易笔数',
  today_amount DECIMAL(14,2) DEFAULT 0 COMMENT '今日交易额',
  availability DECIMAL(6,2) DEFAULT 99.9 COMMENT '可用率%',
  response_ms INT DEFAULT 0 COMMENT '响应毫秒',
  trend VARCHAR(20) DEFAULT '平稳' COMMENT '平稳/上升/下降',
  status VARCHAR(10) NOT NULL DEFAULT '正常' COMMENT '正常/对接中/暂停',
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售渠道';

-- ============================================================================
-- 三、交易（销售订单 + 收款流水）
-- ============================================================================
CREATE TABLE IF NOT EXISTS ml_sales_order (
  id BIGINT NOT NULL AUTO_INCREMENT,
  order_no VARCHAR(40) NOT NULL COMMENT '订单号',
  order_time DATETIME NOT NULL COMMENT '下单时间',
  customer_name VARCHAR(100) NOT NULL COMMENT '客户',
  goods_name VARCHAR(100) DEFAULT NULL COMMENT '主要商品',
  order_type VARCHAR(20) DEFAULT '批发' COMMENT '批发/零售/团购',
  goods_count DECIMAL(14,2) DEFAULT 0 COMMENT '数量',
  amount DECIMAL(14,2) NOT NULL COMMENT '订单金额',
  discount DECIMAL(12,2) DEFAULT 0 COMMENT '优惠',
  pay_method VARCHAR(30) DEFAULT '微信支付' COMMENT '支付方式',
  pay_status VARCHAR(10) DEFAULT '已收款' COMMENT '待收款/已收款/部分收款',
  ship_status VARCHAR(10) DEFAULT '待发货' COMMENT '待发货/配送中/已送达',
  status VARCHAR(10) NOT NULL DEFAULT '已完成' COMMENT '待审核/进行中/已完成/已取消',
  owner VARCHAR(30) DEFAULT NULL COMMENT '业务员',
  remark VARCHAR(300) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_order_no (order_no, del_flag), KEY idx_ot (order_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售订单';

CREATE TABLE IF NOT EXISTS ml_sales_order_item (
  id BIGINT NOT NULL AUTO_INCREMENT,
  order_no VARCHAR(40) NOT NULL COMMENT '订单号',
  goods_name VARCHAR(100) NOT NULL,
  spec VARCHAR(40) DEFAULT NULL,
  qty DECIMAL(14,2) NOT NULL,
  unit VARCHAR(10) DEFAULT '袋',
  price DECIMAL(12,2) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), KEY idx_item_order (order_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='销售订单明细';

CREATE TABLE IF NOT EXISTS ml_payment (
  id BIGINT NOT NULL AUTO_INCREMENT,
  trans_no VARCHAR(40) NOT NULL COMMENT '交易流水号',
  trans_time DATETIME NOT NULL COMMENT '交易时间',
  customer_name VARCHAR(100) NOT NULL COMMENT '客户/商户',
  trans_type VARCHAR(20) DEFAULT '销售收款' COMMENT '销售收款/退款/采购付款',
  pay_method VARCHAR(30) DEFAULT '微信支付' COMMENT '微信支付/支付宝/银行卡/现金/挂账',
  amount DECIMAL(14,2) NOT NULL COMMENT '金额',
  fee DECIMAL(12,2) DEFAULT 0 COMMENT '手续费',
  status VARCHAR(10) NOT NULL DEFAULT '成功' COMMENT '成功/失败/退款中',
  settle_status VARCHAR(10) DEFAULT '已结算' COMMENT '已结算/待结算/结算中',
  order_no VARCHAR(40) DEFAULT NULL COMMENT '关联订单',
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_trans_no (trans_no, del_flag), KEY idx_trans_time (trans_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易流水（交易中心）';

-- ============================================================================
-- 四、资金账户与分账
-- ============================================================================
CREATE TABLE IF NOT EXISTS ml_account (
  id BIGINT NOT NULL AUTO_INCREMENT,
  account_no VARCHAR(40) NOT NULL COMMENT '账户号',
  account_name VARCHAR(100) NOT NULL COMMENT '账户名称',
  account_type VARCHAR(30) DEFAULT '客户账户' COMMENT '客户账户/平台账户/供应商账户',
  balance DECIMAL(16,2) DEFAULT 0 COMMENT '余额',
  available DECIMAL(16,2) DEFAULT 0 COMMENT '可用余额',
  frozen DECIMAL(16,2) DEFAULT 0 COMMENT '冻结金额',
  today_share DECIMAL(14,2) DEFAULT 0 COMMENT '今日分账',
  owner_name VARCHAR(60) DEFAULT NULL COMMENT '所属主体',
  status VARCHAR(10) NOT NULL DEFAULT '正常',
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_account_no (account_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资金账户';

CREATE TABLE IF NOT EXISTS ml_account_flow (
  id BIGINT NOT NULL AUTO_INCREMENT,
  flow_no VARCHAR(40) NOT NULL COMMENT '流水号',
  account_no VARCHAR(40) DEFAULT NULL COMMENT '账户号',
  flow_type VARCHAR(20) DEFAULT NULL COMMENT '收入/支出/分账/冻结',
  amount DECIMAL(14,2) NOT NULL,
  balance_after DECIMAL(16,2) DEFAULT 0 COMMENT '变动后余额',
  counterparty VARCHAR(100) DEFAULT NULL COMMENT '对方',
  summary VARCHAR(200) DEFAULT NULL COMMENT '摘要',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_flow_no (flow_no), KEY idx_flow_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账户流水';

CREATE TABLE IF NOT EXISTS ml_profit_share_rule (
  id BIGINT NOT NULL AUTO_INCREMENT,
  rule_name VARCHAR(60) NOT NULL COMMENT '规则名称',
  rule_type VARCHAR(30) DEFAULT '按订单分账' COMMENT '分账类型',
  platform_rate DECIMAL(6,2) DEFAULT 5 COMMENT '平台服务费率%',
  channel_rate DECIMAL(6,2) DEFAULT 3 COMMENT '渠道费率%',
  supplier_rate DECIMAL(6,2) DEFAULT 0 COMMENT '供应商分成%',
  status VARCHAR(10) NOT NULL DEFAULT '启用',
  remark VARCHAR(300) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分账规则';

CREATE TABLE IF NOT EXISTS ml_profit_share_detail (
  id BIGINT NOT NULL AUTO_INCREMENT,
  share_no VARCHAR(40) NOT NULL COMMENT '分账单号',
  share_time DATETIME NOT NULL COMMENT '分账时间',
  order_no VARCHAR(40) DEFAULT NULL COMMENT '关联订单',
  customer_name VARCHAR(100) DEFAULT NULL COMMENT '客户',
  order_amount DECIMAL(14,2) DEFAULT 0 COMMENT '订单金额',
  platform_fee DECIMAL(12,2) DEFAULT 0 COMMENT '平台服务费',
  channel_fee DECIMAL(12,2) DEFAULT 0 COMMENT '渠道成本',
  merchant_amount DECIMAL(14,2) DEFAULT 0 COMMENT '商户入账',
  share_rate DECIMAL(6,2) DEFAULT 92 COMMENT '分账比例%',
  status VARCHAR(10) NOT NULL DEFAULT '已分账' COMMENT '待分账/已分账/失败',
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_share_no (share_no, del_flag), KEY idx_share_time (share_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分账明细';

-- ============================================================================
-- 五、清结算
-- ============================================================================
CREATE TABLE IF NOT EXISTS ml_settlement_batch (
  id BIGINT NOT NULL AUTO_INCREMENT,
  batch_no VARCHAR(40) NOT NULL COMMENT '结算批次号',
  partner_name VARCHAR(100) NOT NULL COMMENT '结算方',
  settle_cycle VARCHAR(20) DEFAULT 'T+1' COMMENT '结算周期',
  trans_count INT DEFAULT 0 COMMENT '交易笔数',
  amount DECIMAL(16,2) NOT NULL COMMENT '结算金额',
  expect_date DATETIME DEFAULT NULL COMMENT '预计到账',
  status VARCHAR(10) NOT NULL DEFAULT '已结算' COMMENT '待结算/结算中/已结算/失败',
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_batch_no (batch_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='结算批次';

CREATE TABLE IF NOT EXISTS ml_settlement (
  id BIGINT NOT NULL AUTO_INCREMENT,
  settle_no VARCHAR(40) NOT NULL COMMENT '结算单号',
  partner_name VARCHAR(100) NOT NULL COMMENT '结算方',
  settle_type VARCHAR(20) DEFAULT '供应商货款' COMMENT '供应商货款/客户退款/平台分润',
  batch_no VARCHAR(40) DEFAULT NULL COMMENT '批次',
  amount DECIMAL(16,2) NOT NULL COMMENT '结算金额',
  trans_count INT DEFAULT 0,
  cycle VARCHAR(20) DEFAULT 'T+1',
  settle_time DATETIME DEFAULT NULL COMMENT '结算时间',
  status VARCHAR(10) NOT NULL DEFAULT '已结算',
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_settle_no (settle_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='结算单';

CREATE TABLE IF NOT EXISTS ml_payment_order (
  id BIGINT NOT NULL AUTO_INCREMENT,
  pay_no VARCHAR(40) NOT NULL COMMENT '付款单号',
  payee_name VARCHAR(100) NOT NULL COMMENT '收款方',
  payee_account VARCHAR(40) DEFAULT NULL COMMENT '收款账号',
  bank_name VARCHAR(60) DEFAULT NULL COMMENT '开户行',
  biz_type VARCHAR(30) DEFAULT '采购货款' COMMENT '采购货款/运费/仓储费/工资',
  amount DECIMAL(16,2) NOT NULL COMMENT '金额',
  risk_level VARCHAR(10) DEFAULT '低' COMMENT '高/中/低',
  status VARCHAR(10) NOT NULL DEFAULT '待审核' COMMENT '待审核/审核中/已通过/审核拒绝/已付款',
  applicant VARCHAR(30) DEFAULT NULL COMMENT '申请人',
  execute_time DATETIME DEFAULT NULL COMMENT '执行时间',
  remark VARCHAR(300) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_pay_no (pay_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购付款单（转账付款）';

CREATE TABLE IF NOT EXISTS ml_purchase_order (
  id BIGINT NOT NULL AUTO_INCREMENT,
  purchase_no VARCHAR(40) NOT NULL COMMENT '采购单号',
  supplier_name VARCHAR(100) NOT NULL COMMENT '供应商',
  goods_name VARCHAR(100) DEFAULT NULL COMMENT '商品',
  qty DECIMAL(14,2) DEFAULT 0,
  amount DECIMAL(14,2) NOT NULL,
  settle_status VARCHAR(10) DEFAULT '待结算' COMMENT '待结算/已结算',
  status VARCHAR(10) NOT NULL DEFAULT '已入库',
  order_time DATETIME NOT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_purchase_no (purchase_no, del_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购订单';

-- ============================================================================
-- 六、统计 / 风控 / 开放平台 / 其他
-- ============================================================================
CREATE TABLE IF NOT EXISTS ml_daily_stat (
  id BIGINT NOT NULL AUTO_INCREMENT,
  stat_date DATE NOT NULL COMMENT '日期',
  gmv DECIMAL(16,2) DEFAULT 0 COMMENT '成交金额',
  order_count INT DEFAULT 0 COMMENT '订单数',
  customer_count INT DEFAULT 0 COMMENT '客户数',
  refund_count INT DEFAULT 0 COMMENT '退款数',
  avg_price DECIMAL(12,2) DEFAULT 0 COMMENT '客单价',
  success_rate DECIMAL(6,2) DEFAULT 99 COMMENT '成功率%',
  refund_rate DECIMAL(6,2) DEFAULT 0 COMMENT '退款率%',
  gmv_last DECIMAL(16,2) DEFAULT 0 COMMENT '上期同期GMV',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日经营统计';

CREATE TABLE IF NOT EXISTS ml_channel_stat (
  id BIGINT NOT NULL AUTO_INCREMENT,
  channel_name VARCHAR(50) NOT NULL,
  amount DECIMAL(16,2) DEFAULT 0 COMMENT '交易额',
  ratio DECIMAL(6,2) DEFAULT 0 COMMENT '占比%',
  count INT DEFAULT 0,
  stat_date DATE NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道统计';

CREATE TABLE IF NOT EXISTS ml_warehouse_rank (
  id BIGINT NOT NULL AUTO_INCREMENT,
  store_name VARCHAR(80) NOT NULL COMMENT '门店',
  region VARCHAR(40) DEFAULT NULL,
  amount DECIMAL(16,2) DEFAULT 0 COMMENT '交易额',
  order_count INT DEFAULT 0 COMMENT '订单数',
  rank_no INT DEFAULT 0 COMMENT '排名',
  stat_date DATE NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='门店交易排行';

CREATE TABLE IF NOT EXISTS ml_risk_rule (
  id BIGINT NOT NULL AUTO_INCREMENT,
  rule_name VARCHAR(60) NOT NULL COMMENT '规则名称',
  rule_type VARCHAR(30) DEFAULT NULL COMMENT '规则类型',
  hit_count INT DEFAULT 0 COMMENT '命中次数',
  level VARCHAR(10) DEFAULT '中' COMMENT '高/中/低',
  status VARCHAR(10) NOT NULL DEFAULT '启用',
  remark VARCHAR(200) DEFAULT NULL,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控规则';

CREATE TABLE IF NOT EXISTS ml_risk_alert (
  id BIGINT NOT NULL AUTO_INCREMENT,
  alert_no VARCHAR(40) NOT NULL COMMENT '预警编号',
  level VARCHAR(10) NOT NULL COMMENT 'P0/P1/P2',
  alert_type VARCHAR(40) NOT NULL COMMENT '预警类型',
  target_name VARCHAR(100) DEFAULT NULL COMMENT '对象(客户/订单)',
  detail VARCHAR(300) DEFAULT NULL COMMENT '预警详情',
  amount DECIMAL(14,2) DEFAULT 0 COMMENT '涉及金额',
  alert_time DATETIME NOT NULL COMMENT '触发时间',
  status VARCHAR(10) NOT NULL DEFAULT '未处理' COMMENT '未处理/处理中/已处理/已忽略',
  handler VARCHAR(30) DEFAULT NULL COMMENT '处理人',
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id), UNIQUE KEY uk_alert_no (alert_no, del_flag), KEY idx_alert_time (alert_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='风控预警';

CREATE TABLE IF NOT EXISTS ml_open_api (
  id BIGINT NOT NULL AUTO_INCREMENT,
  api_group VARCHAR(40) NOT NULL COMMENT '接口分组',
  api_name VARCHAR(80) NOT NULL COMMENT '接口名称',
  method VARCHAR(10) DEFAULT 'POST' COMMENT '请求方法',
  path VARCHAR(120) DEFAULT NULL COMMENT '接口路径',
  description VARCHAR(200) DEFAULT NULL COMMENT '说明',
  status VARCHAR(10) NOT NULL DEFAULT '已开放',
  order_num INT DEFAULT 0,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='开放平台API';

CREATE TABLE IF NOT EXISTS ml_open_app (
  id BIGINT NOT NULL AUTO_INCREMENT,
  app_name VARCHAR(80) NOT NULL COMMENT '应用名称',
  app_key VARCHAR(60) DEFAULT NULL COMMENT 'AppKey',
  app_secret VARCHAR(120) DEFAULT NULL COMMENT 'AppSecret',
  callback_url VARCHAR(200) DEFAULT NULL COMMENT '回调地址',
  ip_whitelist VARCHAR(200) DEFAULT NULL COMMENT 'IP白名单',
  status VARCHAR(10) NOT NULL DEFAULT '启用',
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='开放平台应用';

CREATE TABLE IF NOT EXISTS ml_notice (
  id BIGINT NOT NULL AUTO_INCREMENT,
  title VARCHAR(120) NOT NULL COMMENT '标题',
  notice_type VARCHAR(20) DEFAULT '平台公告' COMMENT '平台公告/产品动态/系统通知/风控公告',
  content VARCHAR(500) DEFAULT NULL COMMENT '内容',
  publish_time DATETIME NOT NULL COMMENT '发布时间',
  top_flag TINYINT DEFAULT 0 COMMENT '是否置顶',
  status TINYINT NOT NULL DEFAULT 1,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告';

CREATE TABLE IF NOT EXISTS ml_business_flow (
  id BIGINT NOT NULL AUTO_INCREMENT,
  flow_group VARCHAR(40) NOT NULL COMMENT '流程分组',
  step_no INT NOT NULL COMMENT '步骤序号',
  step_name VARCHAR(60) NOT NULL COMMENT '步骤名称',
  step_desc VARCHAR(300) DEFAULT NULL COMMENT '步骤说明',
  icon VARCHAR(40) DEFAULT NULL,
  order_num INT DEFAULT 0,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务流程说明';

CREATE TABLE IF NOT EXISTS ml_revenue_rank (
  id BIGINT NOT NULL AUTO_INCREMENT,
  customer_name VARCHAR(100) NOT NULL COMMENT '客户',
  region VARCHAR(40) DEFAULT NULL,
  amount DECIMAL(16,2) DEFAULT 0 COMMENT '营收金额',
  order_count INT DEFAULT 0,
  rank_no INT DEFAULT 0,
  stat_date DATE NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='营收榜单';

CREATE TABLE IF NOT EXISTS ml_system_status (
  id BIGINT NOT NULL AUTO_INCREMENT,
  module_name VARCHAR(60) NOT NULL COMMENT '模块名称',
  status VARCHAR(10) NOT NULL DEFAULT '正常' COMMENT '正常/异常/维护',
  uptime VARCHAR(20) DEFAULT '99.9%' COMMENT '可用率',
  remark VARCHAR(200) DEFAULT NULL,
  order_num INT DEFAULT 0,
  del_flag TINYINT NOT NULL DEFAULT 0,
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统运行状态';

SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================================
--  表结构创建完成（共 42 张表）
-- ============================================================================
