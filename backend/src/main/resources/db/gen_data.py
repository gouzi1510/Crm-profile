# -*- coding: utf-8 -*-
"""生成 liulizhifu 种子数据 SQL。纯标准库，无第三方依赖。"""
import random
from datetime import datetime, timedelta, date

random.seed(20261117)
NOW = datetime(2026, 11, 17, 15, 30, 0)
TODAY = NOW.date()

OUT = []
def w(line=""):
    OUT.append(line)

def esc(s):
    if s is None:
        return "NULL"
    return "'" + str(s).replace("\\", "\\\\").replace("'", "''") + "'"

def val(v):
    if v is None:
        return "NULL"
    if isinstance(v, (int, float)):
        return str(v)
    return esc(v)

def insert(table, cols, rows):
    if not rows:
        return
    col_str = ",".join(cols)
    for r in rows:
        w("INSERT INTO %s (%s) VALUES (%s);" % (table, col_str, ",".join(val(x) for x in r)))

# ---------------------------------------------------------------- 组织权限
depts = [
    (1, 0, '0', '穗丰粮仓集团', 'SFL', 1, 0, '周建国', '020-8888-0001', 1),
    (2, 1, '0,1', '营销中心', 'SFL-MKT', 2, 1, '林晓燕', '020-8888-0012', 1),
    (3, 1, '0,1', '供应链中心', 'SFL-SCM', 2, 2, '陈国强', '020-8888-0021', 1),
    (4, 1, '0,1', '财务中心', 'SFL-FIN', 2, 3, '王慧敏', '020-8888-0031', 1),
    (5, 1, '0,1', '信息技术部', 'SFL-IT', 2, 4, '赵明', '020-8888-0041', 1),
    (6, 2, '0,1,2', '批发业务部', 'SFL-MKT-W', 3, 1, '林晓燕', '020-8888-0112', 1),
    (7, 2, '0,1,2', '商超餐饮部', 'SFL-MKT-R', 3, 2, '黄志强', '020-8888-0113', 1),
    (8, 3, '0,1,3', '仓储物流部', 'SFL-SCM-W', 3, 1, '刘伟', '020-8888-0121', 1),
    (9, 3, '0,1,3', '采购部', 'SFL-SCM-P', 3, 2, '吴海峰', '020-8888-0122', 1),
    (10, 4, '0,1,4', '结算对账部', 'SFL-FIN-S', 3, 1, '王慧敏', '020-8888-0131', 1),
]
insert('sys_dept', ['id','parent_id','ancestors','dept_name','dept_code','level','order_num','leader','phone','status'], depts)

emps = []
enames = ['林晓燕','陈国强','王慧敏','赵明','黄志强','刘伟','吴海峰','周建国','李文静','张海涛','孙丽','郑凯','何秀英','马俊','许燕','冯刚','邓超','曾静','彭辉','吕玲']
positions = ['销售经理','采购主管','财务主管','运维工程师','客户经理','仓储主管','会计','总经理','业务员','数据分析师']
for i, name in enumerate(enames, 1):
    did = random.choice([2,3,4,5,6,7,8,9,10])
    emps.append((i, 'E%03d' % i, name, 1 if i % 3 else 2, '138%08d' % (10000000 + i), did,
                 positions[(i-1) % len(positions)], 'P%d' % (4 + i % 4),
                 (date(2026,11,17) - timedelta(days=random.randint(200,2500))).isoformat(), 1,
                 '', 0, (NOW - timedelta(days=random.randint(1,300))).strftime('%Y-%m-%d %H:%M:%S')))
insert('sys_employee', ['id','emp_no','emp_name','gender','phone','dept_id','position','job_level','hire_date','emp_status','remark','del_flag','create_time'], emps)

roles = [
    (1,'SUPER_ADMIN','超级管理员',1,1,1,'全部权限'),
    (2,'FINANCE','财务管理员',1,2,1,'资金/结算/对账'),
    (3,'SALES_MGR','销售经理',2,3,1,'销售/客户/订单'),
    (4,'WAREHOUSE','仓储管理员',2,4,1,'库存/出入库'),
    (5,'SALES_REP','业务员',4,5,1,'本人客户/订单'),
    (6,'AUDITOR','审计员',1,6,1,'只读权限'),
]
insert('sys_role', ['id','role_code','role_name','data_scope','order_num','status','remark'], roles)

# 菜单：父子两级，覆盖截图左侧菜单
menus = [
    (1,0,'工作台','/dashboard','DataLine',2,'dashboard:view',1,1),
    (2,0,'交易管理','/trade','ShoppingCart',1,'trade:view',2,1),
    (21,2,'交易中心','/trade','List',2,'trade:list',1,1),
    (3,0,'销售渠道','/channel','Connection',1,'channel:view',3,1),
    (31,3,'渠道中心','/channel','Share',2,'channel:list',1,1),
    (4,0,'资金中心','/fund','Wallet',1,'fund:view',4,1),
    (41,4,'账户与分账','/account','Coin',2,'account:list',1,1),
    (42,4,'清结算中心','/settlement','Document',2,'settlement:list',2,1),
    (43,4,'转账付款','/payment','Money',2,'payment:list',3,1),
    (5,0,'门店与终端','/store','Shop',1,'store:view',5,1),
    (51,5,'门店与终端','/store','Location',2,'store:list',1,1),
    (6,0,'会员与商品','/member','User',1,'member:view',6,1),
    (61,6,'会员与商品','/member','Goods',2,'member:list',1,1),
    (7,0,'数据洞察','/insight','TrendCharts',2,'insight:view',7,1),
    (8,0,'风控预警','/risk','Warning',2,'risk:view',8,1),
    (9,0,'开放平台','/open','Platform',2,'open:view',9,1),
    (10,0,'组织与系统','/system','Setting',1,'system:view',10,1),
    (101,10,'组织与系统','/system','Tools',2,'system:list',1,1),
    (11,0,'业务流程说明','/flow','Document',2,'flow:view',11,1),
]
insert('sys_menu', ['id','parent_id','menu_name','path','icon','type','perm','order_num','status'], menus)

rms = [(rid, mid) for rid in range(1,7) for mid in [m[0] for m in menus]]
insert('sys_role_menu', ['role_id','menu_id'], rms)

# 密码 admin123（存明文简化，登录接口比较）
accounts = [(1, 1, 'admin', 'admin123', '周建国', 1, NOW.strftime('%Y-%m-%d %H:%M:%S')),
            (2, 4, 'finance', '123456', '王慧敏', 1, None),
            (3, 6, 'sales', '123456', '林晓燕', 1, None)]
insert('sys_account', ['id','emp_id','username','password','real_name','status','last_login'], accounts)

# ---------------------------------------------------------------- 基础资料
warehouses = []
wdata = [
    ('SFL-W001','穗丰粮仓·广州白云批发部','批发门店','华南·广州','广州市白云区太和镇物流大道88号','林晓燕',4,86420.50,'运营中'),
    ('SFL-W002','穗丰粮仓·广州番禺仓','中心仓','华南·广州','广州市番禺区化龙镇兴业路26号','陈国强',6,62180.00,'运营中'),
    ('SFL-W003','穗丰粮仓·深圳龙岗批发部','批发门店','华南·深圳','深圳市龙岗区平湖街道粮食市场A栋','黄志强',5,72140.00,'运营中'),
    ('SFL-W004','穗丰粮仓·东莞厚街仓','前置仓','华南·东莞','东莞市厚街镇博览大道中段','刘伟',3,34220.00,'运营中'),
    ('SFL-W005','穗丰粮仓·佛山南海批发部','批发门店','华南·佛山','佛山市南海区大沥镇盐步粮食市场','吴海峰',4,18932.50,'运营中'),
    ('SFL-W006','穗丰粮仓·中山火炬仓','前置仓','华南·中山','中山市火炬开发区沿江东路','郑凯',2,15790.00,'运营中'),
    ('SFL-W007','穗丰粮仓·惠州江北批发部','批发门店','华南·惠州','惠州市惠城区江北街道粮油市场','李文静',3,12408.00,'运营中'),
    ('SFL-W008','穗丰粮仓·清远清城仓','中心仓','华南·清远','清远市清城区源潭镇物流园','马俊',4,8612.00,'运营中'),
    ('SFL-W009','穗丰粮仓·江门蓬江批发部','批发门店','华南·江门','江门市蓬江区棠下镇粮食市场','许燕',2,5480.00,'筹备中'),
    ('SFL-W010','穗丰粮仓·肇庆端州仓','前置仓','华南·肇庆','肇庆市端州区城东街道','冯刚',2,3120.00,'运营中'),
]
for i, (no, name, typ, region, addr, mgr, tc, amt, st) in enumerate(wdata, 1):
    warehouses.append((i, no, name, typ, region, addr, mgr, '020-%08d' % (88880000+i), tc, amt, st))
insert('ml_warehouse', ['id','store_no','store_name','store_type','region','address','manager','phone','terminal_count','today_amount','status'], warehouses)

terminals = []
ttypes = ['POS一体机','扫码枪','电子秤','手持PDA']
stores = [w[1] for w in warehouses]
for i in range(1, 61):
    terminals.append((i, 'T%05d' % i, random.choice(ttypes), random.choice(stores),
                      '在线' if random.random() > 0.12 else ('离线' if random.random() > 0.5 else '故障'),
                      round(random.uniform(120, 9800), 2)))
insert('ml_terminal', ['id','terminal_no','terminal_type','store_name','status','today_amount'], terminals)

cats = [
    ('大米','LM-DM',1,'东北大米/南方籼米/泰国香米'),
    ('面粉','LM-MF',2,'高筋粉/中筋粉/低筋粉'),
    ('杂粮','LM-ZL',3,'小米/玉米/燕麦/荞麦'),
    ('食用油','LM-OIL',4,'花生油/菜籽油/调和油'),
    ('挂面','LM-HN',5,'鸡蛋面/龙须面/刀削面'),
    ('豆类','LM-BEAN',6,'黄豆/绿豆/红豆/黑豆'),
]
insert('ml_goods_category', ['category_name','category_code','order_num','remark'], cats)

# 商品
goods_def = [
    ('东北五常大米','大米','25kg/袋','袋','黑龙江五常',118.0,156.0,12500),
    ('盘锦珍珠大米','大米','10kg/袋','袋','辽宁盘锦',52.0,72.0,8600),
    ('泰国香米','大米','25kg/袋','袋','泰国',188.0,238.0,3200),
    ('南方籼米','大米','50kg/袋','袋','湖南',102.0,138.0,15600),
    ('金龙鱼高筋面粉','面粉','25kg/袋','袋','河南',78.0,102.0,9800),
    ('中筋通用面粉','面粉','25kg/袋','袋','山东',68.0,89.0,11200),
    ('面包专用面粉','面粉','50kg/袋','袋','广东',142.0,185.0,4200),
    ('绿色小米','杂粮','5kg/袋','袋','山西',38.0,52.0,6800),
    ('黄金玉米糁','杂粮','10kg/袋','袋','吉林',26.0,38.0,7500),
    ('有机燕麦片','杂粮','2.5kg/袋','袋','内蒙古',32.0,45.0,5400),
    ('荞麦米','杂粮','10kg/袋','袋','四川',42.0,58.0,3900),
    ('鲁花花生油','食用油','5L/桶','桶','山东',128.0,158.0,4600),
    ('非转基因菜籽油','食用油','5L/桶','桶','湖北',68.0,88.0,8200),
    ('调和油','食用油','5L/桶','桶','广东',52.0,69.0,9600),
    ('鸡蛋挂面','挂面','1kg/把','把','广东',6.5,9.5,21000),
    ('龙须面','挂面','500g/把','把','河南',3.8,5.8,18000),
    ('刀削面','挂面','1kg/袋','袋','山西',7.2,10.5,12500),
    ('东北黄豆','豆类','25kg/袋','袋','黑龙江',112.0,145.0,5800),
    ('绿豆','豆类','25kg/袋','袋','河南',138.0,178.0,3400),
    ('红豆','豆类','25kg/袋','袋','吉林',128.0,165.0,2900),
]
goods = []
for i, (name, cat, spec, unit, brand, pp, sp, stock) in enumerate(goods_def, 1):
    goods.append((i, 'SKU%05d' % i, name, cat, spec, unit, brand, pp, sp, stock,
                  round(stock * 0.08), random.randint(500, 18000), '在售', '', 0))
insert('ml_goods', ['id','goods_no','goods_name','category','spec','unit','brand','purchase_price','sale_price','stock_qty','warning_qty','sales_count','status','remark','del_flag'], goods)

# 客户
cust_names = ['广州万佳批发','深圳华强商超','东莞百惠餐饮','佛山顺景食堂','中山广源批发','惠州家家乐超市',
              '广州天虹餐饮','珠海益健食品','江门新联批发','肇庆聚实惠超市','广州白云食品厂','深圳龙岗学校食堂',
              '东莞虎门商贸','佛山南海粮油','中山石岐餐饮','广州番禺九州超市','清远英德批发','惠州惠东便利店',
              '增城新塘粮行','从化街口市场','花都新华批发','南沙万顷沙食堂','韶关市区商超','汕头金平批发']
customer_types = ['批发商','商超','餐饮','食堂','零售']
levels = ['钻石','金卡','银卡','普通']
customers = []
for i, name in enumerate(cust_names, 1):
    ct = customer_types[i % len(customer_types)]
    lv = levels[0] if i <= 4 else (levels[1] if i <= 9 else (levels[2] if i <= 16 else levels[3]))
    cr = random.choice([50000, 100000, 200000, 300000, 500000])
    rc = round(random.uniform(0, cr * 0.8), 2)
    total = round(random.uniform(50000, 2800000), 2)
    customers.append((i, 'KH%05d' % i, name, ct, lv, random.choice(['陈老板','李经理','王总','张主任','刘经理']),
                      '139%08d' % (10000000 + i), random.choice(['华南·广州','华南·深圳','华南·东莞','华南·佛山']),
                      '', cr, rc, total, '正常' if i % 11 else '冻结',
                      random.choice(enames[:12]), '', 0))
insert('ml_customer', ['id','customer_no','customer_name','customer_type','level','contact','phone','region','address','credit_limit','receivable','total_amount','status','owner','remark','del_flag'], customers)

suppliers = [
    ('SUP001','黑龙江五常金禾米业','产地粮农','黑龙江五常','王建国','13904510001',238000,'月结30天'),
    ('SUP002','辽宁盘锦鼎丰农业','产地粮农','辽宁盘锦','赵铁柱','13904270002',156000,'月结30天'),
    ('SUP003','河南新乡面粉集团','面粉厂','河南新乡','李新建','13903730003',312000,'月结45天'),
    ('SUP004','山东鲁花油脂','油厂','山东烟台','孙立军','13905350004',189000,'货到付款'),
    ('SUP005','吉林松原杂粮合作社','产地粮农','吉林松原','刘大伟','13904380005',98000,'月结30天'),
    ('SUP006','湖北荆门菜籽油厂','油厂','湖北荆门','周明','13907240006',76000,'月结30天'),
    ('SUP007','山西忻州小米基地','产地粮农','山西忻州','高志强','13903500007',65000,'月结45天'),
    ('SUP008','泰国香米华南总代','进口商','广东广州','陈炳南','13902010008',420000,'月结60天'),
]
insert('ml_supplier', ['id','supplier_no','supplier_name','supply_type','region','contact','phone','payable','settle_cycle','status','remark'],
       [(i, *s, '合作中', '') for i, s in enumerate(suppliers, 1)])

member_levels = [
    ('钻石', 1820, 1520.00, '8.5折', '#f56c6c', 1),
    ('金卡', 8246, 798.00, '9折', '#e6a23c', 2),
    ('银卡', 24688, 298.00, '9.5折', '#909399', 3),
    ('普通', 90160, 62.00, '无折扣', '#67c23a', 4),
]
insert('ml_member_level', ['level_name','member_count','avg_consume','discount','color','order_num'], member_levels)

members = []
msurnames = ['林','王','苏','周','陈','黄','李','张','刘','吴','郑','何','徐','孙','马','朱','胡','郭','罗','梁']
for i in range(1, 81):
    name = random.choice(msurnames) + random.choice(['先生','女士','老板','师傅','经理'])
    lv = levels[0] if i <= 5 else (levels[1] if i <= 18 else (levels[2] if i <= 40 else levels[3]))
    total = round(random.uniform(300, 28000), 2)
    members.append((i, 'HY%06d' % i, name, lv, '138%08d' % (20000000 + i),
                    random.choice(['华南·广州','华南·深圳','华南·东莞','华南·佛山']),
                    total, random.randint(2, 60), int(total // 10),
                    (NOW - timedelta(days=random.randint(0, 90))).strftime('%Y-%m-%d %H:%M:%S'),
                    random.choice(stores[:6]), '正常'))
insert('ml_member', ['id','member_no','member_name','level','phone','region','total_amount','order_count','points','last_order','store_name','status'], members)

channels = [
    ('批发档口','批发','SFL-CH-001',32.6,1284,875932.00,99.98,42,'上升','正常'),
    ('商超供货','商超','SFL-CH-002',28.4,1120,430445.00,99.97,38,'平稳','正常'),
    ('餐饮渠道','餐饮','SFL-CH-003',16.6,256,209141.00,99.95,56,'上升','正常'),
    ('线上商城','线上','SFL-CH-004',12.5,364,158200.00,99.92,128,'上升','正常'),
    ('团购渠道','团购','SFL-CH-005',6.5,88,82140.00,99.88,66,'平稳','正常'),
    ('社区零售','零售','SFL-CH-006',3.4,142,43180.00,99.91,52,'下降','正常'),
]
insert('ml_channel', ['channel_name','channel_type','merchant_no','trade_ratio','today_count','today_amount','availability','response_ms','trend','status'], channels)

# ---------------------------------------------------------------- 交易
methods = ['微信支付','支付宝','银行卡','现金','挂账']
order_statuses = ['已完成','已完成','已完成','进行中','待审核','已完成','已完成','已取消']
orders = []
order_items = []
payments = []
for i in range(1, 161):
    ot = NOW - timedelta(days=random.randint(0, 29), hours=random.randint(0, 20), minutes=random.randint(0, 59))
    cust = random.choice(customers)
    gd = random.choice(goods)
    qty = random.randint(2, 80)
    amount = round(gd[8] * qty, 2)
    disc = round(amount * random.choice([0, 0, 0.02, 0.05]), 2)
    order_no = 'DD2026%07d' % (1000000 + i)
    ost = random.choice(order_statuses)
    pay_status = '已收款' if ost in ('已完成', '进行中') else ('待收款' if ost == '待审核' else '已退款')
    ship = random.choice(['待发货','配送中','已送达'])
    orders.append((i, order_no, ot.strftime('%Y-%m-%d %H:%M:%S'), cust[2], gd[2], random.choice(['批发','零售','团购']),
                   qty, amount, disc, random.choice(methods), pay_status, ship, ost,
                   random.choice(enames[:12]), '', 0))
    order_items.append((order_no, gd[2], gd[4], qty, gd[3], gd[8], amount))
    # 交易流水
    pay_st = '成功' if ost in ('已完成','进行中') else ('退款中' if ost == '已取消' else '成功')
    payments.append((i, 'LS2026%08d' % (20000000 + i), ot.strftime('%Y-%m-%d %H:%M:%S'), cust[2],
                     '销售收款' if ost != '已取消' else '退款', random.choice(methods),
                     amount if ost != '已取消' else -round(amount*0.3, 2),
                     round(amount * 0.006, 2), pay_st,
                     '已结算' if random.random() > 0.18 else '待结算', order_no, '', 0))
insert('ml_sales_order', ['id','order_no','order_time','customer_name','goods_name','order_type','goods_count','amount','discount','pay_method','pay_status','ship_status','status','owner','remark','del_flag'], orders)
insert('ml_sales_order_item', ['order_no','goods_name','spec','qty','unit','price','amount'], order_items)
insert('ml_payment', ['id','trans_no','trans_time','customer_name','trans_type','pay_method','amount','fee','status','settle_status','order_no','remark','del_flag'], payments)

# ---------------------------------------------------------------- 资金
accounts = []
for i, c in enumerate(customers[:20], 1):
    bal = round(random.uniform(20000, 1800000), 2)
    accounts.append((i, 'ACC%06d' % i, c[2] + '-货款账户', '客户账户', bal, round(bal*0.9,2), round(bal*0.1,2),
                     round(random.uniform(1000, 58000),2), c[4], '正常', '', 0))
accounts.append((21, 'ACC-PLATFORM', '穗丰粮仓平台总账户', '平台账户', 8420500.00, 8200000.00, 220500.00, 1224602.00, '穗丰粮仓集团', '正常', '', 0))
for j, s in enumerate(suppliers[:6], 22):
    accounts.append((j, 'ACC-SUP%03d' % j, s[2] + '-结算账户', '供应商账户', round(random.uniform(50000,500000),2),
                     round(random.uniform(40000,400000),2), 0, 0, s[2], '正常', '', 0))
insert('ml_account', ['id','account_no','account_name','account_type','balance','available','frozen','today_share','owner_name','status','remark','del_flag'], accounts)

flows = []
for i in range(1, 61):
    t = NOW - timedelta(hours=random.randint(0, 72), minutes=random.randint(0,59))
    ft = random.choice(['收入','支出','分账','冻结'])
    amt = round(random.uniform(500, 98000), 2)
    flows.append(('FL%06d' % i, random.choice(accounts)[1], ft, amt, round(random.uniform(100000,2000000),2),
                  random.choice(cust_names), '%s %s' % (ft, random.choice(['货款','服务费','结算款'])), t.strftime('%Y-%m-%d %H:%M:%S')))
insert('ml_account_flow', ['flow_no','account_no','flow_type','amount','balance_after','counterparty','summary','create_time'], flows)

share_rules = [
    ('标准订单分账规则','按订单分账',5.00,3.00,0.00,'启用','平台5% + 渠道3%，商户实收92%'),
    ('商超渠道分账规则','按订单分账',3.00,2.00,0.00,'启用','商超渠道专属费率'),
    ('团购大客户规则','按订单分账',2.00,0.00,0.00,'启用','大客户优惠费率'),
]
insert('ml_profit_share_rule', ['rule_name','rule_type','platform_rate','channel_rate','supplier_rate','status','remark'], share_rules)

share_details = []
for i in range(1, 51):
    t = NOW - timedelta(hours=random.randint(0, 24), minutes=random.randint(0,59))
    oa = round(random.uniform(500, 58000), 2)
    plat = round(oa * 0.05, 2)
    ch = round(oa * 0.03, 2)
    share_details.append(('FZ2026%07d' % (3000000+i), t.strftime('%Y-%m-%d %H:%M:%S'),
                          random.choice(orders)[1], random.choice(cust_names), oa, plat, ch, round(oa-plat-ch,2), 92.00, '已分账', 0))
insert('ml_profit_share_detail', ['share_no','share_time','order_no','customer_name','order_amount','platform_fee','channel_fee','merchant_amount','share_rate','status','del_flag'], share_details)

# ---------------------------------------------------------------- 结算
batches = []
for i in range(1, 31):
    t = NOW - timedelta(days=random.randint(0, 20), hours=random.randint(0,20))
    batches.append(('JSPC2026%06d' % (400000+i), random.choice(suppliers)[2] + ' / ' + random.choice(cust_names),
                    random.choice(['T+1','T+3','周结','月结']), random.randint(20, 380),
                    round(random.uniform(5000, 420000),2), (t+timedelta(days=1)).strftime('%Y-%m-%d %H:%M:%S'),
                    random.choice(['已结算','已结算','已结算','结算中','待结算','失败']), '', 0))
insert('ml_settlement_batch', ['batch_no','partner_name','settle_cycle','trans_count','amount','expect_date','status','remark','del_flag'], batches)

settles = []
for i in range(1, 26):
    t = NOW - timedelta(days=random.randint(0, 15), hours=random.randint(0,20))
    settles.append(('JSD2026%06d' % (500000+i), random.choice(suppliers)[2],
                    random.choice(['供应商货款','客户退款','平台分润']), 'JSPC2026%06d' % (400000+random.randint(1,30)),
                    round(random.uniform(8000, 380000),2), random.randint(10,260), random.choice(['T+1','T+3','周结']),
                    t.strftime('%Y-%m-%d %H:%M:%S'), '已结算', 0))
insert('ml_settlement', ['settle_no','partner_name','settle_type','batch_no','amount','trans_count','cycle','settle_time','status','del_flag'], settles)

pay_orders = []
payees = ['黑龙江五常金禾米业','河南新乡面粉集团','山东鲁花油脂','吉林松原杂粮合作社','湖北荆门菜籽油厂',
          '广州白云物流公司','穗丰仓储服务有限公司','东莞市运输车队','深圳市装卸服务部']
biz_types = ['采购货款','运费','仓储费','装卸费','工资']
# 大额待审核
pay_orders.append(('FK2026%07d' % 6000001, '黑龙江五常金禾米业', '6222****3345', '中国农业银行五常支行',
                   '采购货款', 2800000.00, '高', '待审核', '王慧敏', None, '年末大米集中采购款，需财务总监审批', 0))
for i in range(2, 36):
    t = NOW - timedelta(days=random.randint(0, 20), hours=random.randint(0,20))
    st = random.choice(['待审核','审核中','已通过','已通过','已通过','审核拒绝','已付款'])
    pay_orders.append(('FK2026%07d' % (6000000+i), random.choice(payees), '6222****%04d' % random.randint(1000,9999),
                       random.choice(['中国农业银行','中国工商银行','中国建设银行','中国银行']),
                       random.choice(biz_types), round(random.uniform(8000, 880000),2),
                       random.choice(['高','中','低','低','低']), st, random.choice(enames[:10]),
                       t.strftime('%Y-%m-%d %H:%M:%S'), '', 0))
insert('ml_payment_order', ['pay_no','payee_name','payee_account','bank_name','biz_type','amount','risk_level','status','applicant','execute_time','remark','del_flag'], pay_orders)

purchase = []
for i in range(1, 41):
    s = random.choice(suppliers)
    g = random.choice(goods)
    qty = random.randint(10, 200)
    t = NOW - timedelta(days=random.randint(0, 30), hours=random.randint(0,20))
    purchase.append(('CG2026%06d' % (700000+i), s[2], g[2], qty, round(g[7]*qty,2),
                     random.choice(['已结算','待结算']), '已入库', t.strftime('%Y-%m-%d %H:%M:%S'), 0))
insert('ml_purchase_order', ['purchase_no','supplier_name','goods_name','qty','amount','settle_status','status','order_time','del_flag'], purchase)

# ---------------------------------------------------------------- 统计
daily = []
for d in range(29, -1, -1):
    day = TODAY - timedelta(days=d)
    base = 980000 + d * 9800 + random.randint(-120000, 160000)
    cnt = 38000 + d * 220 + random.randint(-4000, 6000)
    daily.append((day.isoformat(), round(base,2), cnt, random.randint(95, 165), random.randint(8, 22),
                  round(random.uniform(22, 34),2), round(random.uniform(99.2, 99.99),2),
                  round(random.uniform(0.1, 0.9),2), round(base * random.uniform(0.82, 0.95),2)))
# 让今日数据与仪表盘文案一致
daily[-1] = (TODAY.isoformat(), 1258402.50, 45210, 128, 342, 28.60, 99.97, 0.42, 1115000.00)
insert('ml_daily_stat', ['stat_date','gmv','order_count','customer_count','refund_count','avg_price','success_rate','refund_rate','gmv_last'], daily)

channel_stat = [
    ('微信支付', 18432000.00, 48, 58920, TODAY.isoformat()),
    ('支付宝', 10752000.00, 28, 34210, TODAY.isoformat()),
    ('银行卡', 7680000.00, 20, 24680, TODAY.isoformat()),
    ('现金/挂账', 1536000.00, 4, 1980, TODAY.isoformat()),
]
insert('ml_channel_stat', ['channel_name','amount','ratio','count','stat_date'], channel_stat)

wrank = []
for i in range(1, 11):
    wh = warehouses[(i-1) % 8]
    wrank.append((wh[2], wh[4], round(2640520 - (i-1)*118000 + random.randint(-20000,20000),2),
                  random.randint(280, 1250), i, TODAY.isoformat()))
insert('ml_warehouse_rank', ['store_name','region','amount','order_count','rank_no','stat_date'], wrank)

revrank = []
for i in range(1, 11):
    c = customers[(i-1) % len(customers)]
    revrank.append((c[2], c[7], round(86520 - (i-1)*8300 + random.randint(-3000,3000),2),
                    random.randint(30, 260), i, TODAY.isoformat()))
insert('ml_revenue_rank', ['customer_name','region','amount','order_count','rank_no','stat_date'], revrank)

# ---------------------------------------------------------------- 风控
risk_rules = [
    ('大额交易监控','交易金额',186,'高','启用','单笔超过10万元触发'),
    ('高频退款','退款行为',124,'高','启用','短时间多笔退款'),
    ('异地登录','账户安全',88,'中','启用','非常用地区登录'),
    ('异常时段交易','交易时间',62,'中','启用','凌晨大额交易'),
    ('信用额度超限','客户信用',43,'中','启用','应收超过授信额度'),
    ('库存异常预警','库存管理',31,'低','启用','库存低于安全线'),
    ('价格异常','商品价格',18,'低','启用','售价偏离均价过大'),
    ('频繁撤销','订单行为',12,'低','启用','短时间多次撤单'),
]
insert('ml_risk_rule', ['rule_name','rule_type','hit_count','level','status','remark'], risk_rules)

alert_types = ['大额交易','高频退款','信用超限','库存预警','异常时段','异地登录','价格异常']
alerts = []
for i in range(1, 37):
    t = NOW - timedelta(hours=random.randint(0, 72), minutes=random.randint(0,59))
    lvl = random.choice(['P0','P1','P2','P2','P2'])
    at = random.choice(alert_types)
    target = random.choice(customers[:15])[2] if i % 3 else random.choice(goods)[2]
    detail = '%s触发：%s' % (at, random.choice(['金额超出日均3倍','短时间内连续多笔','应收余额超过授信额度','库存低于预警值','与历史行为差异较大']))
    alerts.append(('YJ2026%06d' % (800000+i), lvl, at, target, detail,
                   round(random.uniform(1000, 380000),2), t.strftime('%Y-%m-%d %H:%M:%S'),
                   random.choice(['未处理','未处理','处理中','已处理','已处理']),
                   random.choice(enames[:10]) if i % 2 else None, 0))
insert('ml_risk_alert', ['alert_no','level','alert_type','target_name','detail','amount','alert_time','status','handler','del_flag'], alerts)

apis = [
    ('销售与订单','创建销售订单','POST','/api/v1/orders','新建批发销售订单',1),
    ('销售与订单','查询订单列表','GET','/api/v1/orders','分页查询订单',2),
    ('销售与订单','订单发货','POST','/api/v1/orders/{id}/ship','更新发货状态',3),
    ('客户管理','创建客户','POST','/api/v1/customers','新建批发客户',1),
    ('客户管理','查询客户','GET','/api/v1/customers','分页查询客户',2),
    ('客户管理','更新授信额度','PUT','/api/v1/customers/{id}/credit','调整客户授信',3),
    ('商品库存','查询商品','GET','/api/v1/goods','查询商品SKU',1),
    ('商品库存','库存查询','GET','/api/v1/stock','查询实时库存',2),
    ('商品库存','库存预警','GET','/api/v1/stock/warning','查询预警库存',3),
    ('资金结算','账户余额','GET','/api/v1/accounts/{no}','查询账户余额',1),
    ('资金结算','发起结算','POST','/api/v1/settlements','发起结算单',2),
    ('资金结算','分账明细','GET','/api/v1/profit-shares','查询分账明细',3),
    ('消息通知','订单状态通知','POST','/api/v1/notify/order','推送订单状态',1),
    ('消息通知','结算结果通知','POST','/api/v1/notify/settlement','推送结算结果',2),
]
insert('ml_open_api', ['api_group','api_name','method','path','description','status','order_num'],
       [(a[0],a[1],a[2],a[3],a[4],'已开放',a[5]) for a in apis])

apps = [
    ('穗丰粮仓商家App','AK2026SF0001','SK2026sf_secret_0001','https://api.suifenggrain.com/callback','192.168.1.*,10.0.0.*','启用'),
    ('万佳批发对接系统','AK2026WJ0002','SK2026wj_secret_0002','https://www.wanjia.com/cb','*','启用'),
    ('线上商城小程序','AK2026XS0003','SK2026xs_secret_0003','https://shop.suifeng.cn/notify','172.16.*','启用'),
]
insert('ml_open_app', ['app_name','app_key','app_secret','callback_url','ip_whitelist','status'], apps)

notices = [
    ('关于2026年新粮上市收购价格调整的通知','平台公告','2026年新粮陆续上市，各品类收购价格自11月20日起调整，请各批发门店及时关注。', NOW - timedelta(hours=2), 1),
    ('仓储管理系统V2.0升级完成','产品动态','仓储管理系统完成V2.0升级，新增批次追溯与智能盘点功能。', NOW - timedelta(days=2), 0),
    ('系统维护通知：11月20日凌晨2:00-4:00','系统通知','系统将进行月度维护，期间部分功能不可用，请提前安排业务。', NOW - timedelta(days=3), 0),
    ('风控规则升级：新增信用额度监控模型','风控公告','新增客户信用额度实时监控，超额自动预警并冻结下单。', NOW - timedelta(days=5), 0),
    ('关于年末结算周期调整的说明','平台公告','年末供应商货款结算周期调整为T+3，请各供应商留意到账时间。', NOW - timedelta(days=7), 0),
]
insert('ml_notice', ['title','notice_type','content','publish_time','top_flag'], notices)

flows = []
flow_groups = [
    ('企业采购入库流程', [
        ('发起采购申请','采购部根据库存与销售预测提交采购申请'),
        ('主管审批','采购主管审核采购品类和数量'),
        ('供应商发货','供应商按单发货并上传物流信息'),
        ('到货验收','仓库核对数量与质量，扫码入库'),
        ('入库上架','系统更新库存，生成入库单'),
        ('财务记账','应付账款入账，按账期结算'),
    ]),
    ('平台分账结算流程', [
        ('订单支付成功','客户完成货款支付'),
        ('匹配分账规则','系统自动匹配对应的分账规则'),
        ('生成分账任务','按规则计算平台服务费与渠道成本'),
        ('执行分账','资金划转至各账户'),
        ('各方到账','商户/平台/渠道账户余额更新'),
        ('分账通知','推送分账结果通知'),
    ]),
    ('客户对账流程', [
        ('生成对账单','按账期生成客户对账单'),
        ('发送客户确认','推送对账单给客户核对'),
        ('客户确认/异议','客户确认或提出异议'),
        ('差异处理','财务核实差异并调整'),
        ('对账完成','双方确认，锁定对账结果'),
        ('应收入账','应收账款更新'),
    ]),
    ('风险预警处理流程', [
        ('风险识别','风控引擎实时监测交易与库存'),
        ('触发预警','命中规则自动生成预警'),
        ('分级派单','按P0/P1/P2分级派给处理人'),
        ('人工核查','核实预警真实性与影响'),
        ('处置反馈','采取冻结/放行/调额等措施'),
        ('归档复盘','预警归档，规则优化复盘'),
    ]),
]
flowsicons = ['CreditCard','Stamp','Truck','Box','FolderOpened','Money','Bell','Refresh']
fid = 1
fg = 1
for gname, steps in flow_groups:
    for sn, (sname, sdesc) in enumerate(steps, 1):
        flows.append((gname, sn, sname, sdesc, flowsicons[(sn-1) % len(flowsicons)], fg))
        fid += 1
    fg += 1
insert('ml_business_flow', ['flow_group','step_no','step_name','step_desc','icon','order_num'], flows)

sys_status = [
    ('核心交易系统','正常','99.99%','订单/支付主链路',1),
    ('仓储管理系统','正常','99.95%','库存/出入库',2),
    ('资金结算引擎','正常','100.00%','分账/结算',3),
    ('风控监测引擎','正常','99.98%','实时预警',4),
    ('数据同步服务','正常','99.92%','数据分析',5),
]
insert('ml_system_status', ['module_name','status','uptime','remark','order_num'], sys_status)

# 操作日志 / 登录日志
oplogs = []
ops = ['新增客户','编辑商品','审核付款单','生成结算单','处理风控预警','调整授信额度','订单发货','库存盘点','导出报表','新增供应商']
for i in range(1, 31):
    t = NOW - timedelta(hours=random.randint(0, 120), minutes=random.randint(0,59))
    oplogs.append((random.choice(enames[:10]), random.choice(['客户管理','商品管理','资金中心','风控中心','仓储管理']),
                   random.choice(ops), '192.168.1.%d' % random.randint(2,250), 1, t.strftime('%Y-%m-%d %H:%M:%S')))
insert('sys_operate_log', ['operator','module','content','ip','status','create_time'], oplogs)

loginlogs = []
for i in range(1, 21):
    t = NOW - timedelta(hours=random.randint(0, 72), minutes=random.randint(0,59))
    loginlogs.append((random.choice(['admin','finance','sales']), '192.168.1.%d' % random.randint(2,250),
                      random.choice(['Chrome / Windows','Edge / Windows','微信内置浏览器','Safari / iOS']), 1, t.strftime('%Y-%m-%d %H:%M:%S')))
insert('sys_login_log', ['username','ip','device','status','create_time'], loginlogs)

# ---------------------------------------------------------------- 输出
header = """-- ============================================================================
--  穗丰粮仓 · 米面杂粮批发管理平台  种子数据
--  由 tools/gen_data.py 生成（随机种子固定，可重复生成）
-- ============================================================================
USE liulizhifu;
SET FOREIGN_KEY_CHECKS = 0;
"""
# 清空表（按依赖顺序）
clear = "\n-- 清空业务表\n"
tables = ['ml_sales_order_item','ml_sales_order','ml_payment','ml_profit_share_detail','ml_profit_share_rule',
          'ml_account_flow','ml_account','ml_settlement','ml_settlement_batch','ml_payment_order','ml_purchase_order',
          'ml_daily_stat','ml_channel_stat','ml_warehouse_rank','ml_revenue_rank','ml_risk_alert','ml_risk_rule',
          'ml_open_api','ml_open_app','ml_notice','ml_business_flow','ml_system_status','sys_operate_log','sys_login_log',
          'sys_role_menu','sys_account','sys_menu','sys_role','sys_employee','sys_dept',
          'ml_member','ml_member_level','ml_channel','ml_goods','ml_goods_category','ml_terminal','ml_warehouse',
          'ml_customer','ml_supplier']
for t in tables:
    clear += "DELETE FROM %s;\n" % t
clear += "SET FOREIGN_KEY_CHECKS = 1;\n"

import os
OUT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '02_data.sql')
with open(OUT_PATH, 'w', encoding='utf-8') as f:
    f.write(header + clear + "\n" + "\n".join(OUT) + "\n")

print("Generated 02_data.sql with %d INSERT statements" % sum(1 for x in OUT if x.startswith('INSERT')))
