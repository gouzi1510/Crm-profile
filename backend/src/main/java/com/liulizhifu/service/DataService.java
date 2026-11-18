package com.liulizhifu.service;

import com.liulizhifu.common.PageResult;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Service;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * 通用数据服务：白名单驱动，所有业务表通过 /api/data/{module} 统一增删改查。
 * 前端字段名即数据库列名；支持 keyword 模糊搜索 + 任意列等值筛选 + 日期区间。
 */
@Service
public class DataService {
    private final JdbcTemplate jdbc;

    /** module -> 表名 */
    private static final Map<String, String> TABLES = new LinkedHashMap<>();
    static {
        TABLES.put("warehouse", "ml_warehouse");
        TABLES.put("terminal", "ml_terminal");
        TABLES.put("goodsCategory", "ml_goods_category");
        TABLES.put("goods", "ml_goods");
        TABLES.put("customer", "ml_customer");
        TABLES.put("supplier", "ml_supplier");
        TABLES.put("member", "ml_member");
        TABLES.put("memberLevel", "ml_member_level");
        TABLES.put("channel", "ml_channel");
        TABLES.put("order", "ml_sales_order");
        TABLES.put("orderItem", "ml_sales_order_item");
        TABLES.put("payment", "ml_payment");
        TABLES.put("account", "ml_account");
        TABLES.put("accountFlow", "ml_account_flow");
        TABLES.put("shareRule", "ml_profit_share_rule");
        TABLES.put("shareDetail", "ml_profit_share_detail");
        TABLES.put("settlementBatch", "ml_settlement_batch");
        TABLES.put("settlement", "ml_settlement");
        TABLES.put("paymentOrder", "ml_payment_order");
        TABLES.put("purchaseOrder", "ml_purchase_order");
        TABLES.put("riskRule", "ml_risk_rule");
        TABLES.put("riskAlert", "ml_risk_alert");
        TABLES.put("openApi", "ml_open_api");
        TABLES.put("openApp", "ml_open_app");
        TABLES.put("notice", "ml_notice");
        TABLES.put("businessFlow", "ml_business_flow");
        TABLES.put("revenueRank", "ml_revenue_rank");
        TABLES.put("systemStatus", "ml_system_status");
        TABLES.put("dept", "sys_dept");
        TABLES.put("employee", "sys_employee");
        TABLES.put("role", "sys_role");
        TABLES.put("menu", "sys_menu");
        TABLES.put("accountAdmin", "sys_account");
        TABLES.put("operateLog", "sys_operate_log");
        TABLES.put("loginLog", "sys_login_log");
    }

    /** keyword 模糊搜索列 */
    private static final Map<String, List<String>> SEARCH_COLS = new HashMap<>();

    /** 允许被前端等值筛选的列（防止注入） */
    private static final Set<String> FILTER_COLS = new HashSet<>(Arrays.asList(
        "status", "pay_status", "ship_status", "settle_status", "trans_type", "pay_method", "order_type",
        "category", "store_type", "region", "level", "customer_type", "goods_name", "channel_type",
        "risk_level", "alert_type", "rule_type", "api_group", "notice_type", "account_type",
        "supply_type", "flow_type", "share_rate", "term_type"
    ));

    static {
        SEARCH_COLS.put("warehouse", List.of("store_no", "store_name", "region", "manager"));
        SEARCH_COLS.put("terminal", List.of("terminal_no", "terminal_type", "store_name"));
        SEARCH_COLS.put("goods", List.of("goods_no", "goods_name", "category", "spec", "brand"));
        SEARCH_COLS.put("customer", List.of("customer_no", "customer_name", "contact", "phone", "region"));
        SEARCH_COLS.put("supplier", List.of("supplier_no", "supplier_name", "region", "contact"));
        SEARCH_COLS.put("member", List.of("member_no", "member_name", "phone", "store_name"));
        SEARCH_COLS.put("channel", List.of("channel_name", "channel_type", "merchant_no"));
        SEARCH_COLS.put("order", List.of("order_no", "customer_name", "goods_name", "owner"));
        SEARCH_COLS.put("payment", List.of("trans_no", "customer_name", "order_no"));
        SEARCH_COLS.put("account", List.of("account_no", "account_name", "owner_name"));
        SEARCH_COLS.put("shareDetail", List.of("share_no", "order_no", "customer_name"));
        SEARCH_COLS.put("settlementBatch", List.of("batch_no", "partner_name"));
        SEARCH_COLS.put("settlement", List.of("settle_no", "partner_name"));
        SEARCH_COLS.put("paymentOrder", List.of("pay_no", "payee_name", "bank_name", "biz_type"));
        SEARCH_COLS.put("riskAlert", List.of("alert_no", "alert_type", "target_name"));
        SEARCH_COLS.put("riskRule", List.of("rule_name", "rule_type"));
        SEARCH_COLS.put("openApi", List.of("api_group", "api_name", "path"));
        SEARCH_COLS.put("openApp", List.of("app_name", "app_key"));
        SEARCH_COLS.put("notice", List.of("title", "notice_type"));
        SEARCH_COLS.put("employee", List.of("emp_no", "emp_name", "phone", "position"));
        SEARCH_COLS.put("dept", List.of("dept_name", "dept_code", "leader"));
        SEARCH_COLS.put("role", List.of("role_code", "role_name"));
        SEARCH_COLS.put("accountAdmin", List.of("username", "real_name"));
        SEARCH_COLS.put("operateLog", List.of("operator", "module", "content"));
        SEARCH_COLS.put("loginLog", List.of("username", "device"));
    }

    public DataService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    private String table(String module) {
        String t = TABLES.get(module);
        if (t == null) throw new IllegalArgumentException("未知数据模块：" + module);
        return t;
    }

    /** 分页查询 */
    public PageResult<Map<String, Object>> page(String module, String keyword, Map<String, String> filters,
                                                String startDate, String endDate,
                                                String dateCol, Integer pageNum, Integer pageSize, String sort) {
        String t = table(module);
        int pn = (pageNum == null || pageNum < 1) ? 1 : pageNum;
        int ps = (pageSize == null || pageSize < 1) ? 10 : Math.min(pageSize, 200);

        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> args = new ArrayList<>();

        // 逻辑删除
        if (hasColumn(t, "del_flag")) where.append(" AND del_flag = 0 ");

        // 关键字模糊
        List<String> searchCols = SEARCH_COLS.getOrDefault(module, List.of());
        if (keyword != null && !keyword.isBlank() && !searchCols.isEmpty()) {
            where.append(" AND ( ");
            for (int i = 0; i < searchCols.size(); i++) {
                if (i > 0) where.append(" OR ");
                where.append(" ").append(searchCols.get(i)).append(" LIKE ? ");
                args.add("%" + keyword.trim() + "%");
            }
            where.append(" ) ");
        }

        // 等值筛选（白名单列）
        if (filters != null) {
            for (Map.Entry<String, String> e : filters.entrySet()) {
                String col = e.getKey();
                String v = e.getValue();
                if (v == null || v.isBlank() || "all".equalsIgnoreCase(v) || "全部".equals(v)) continue;
                if (!FILTER_COLS.contains(col) || !hasColumn(t, col)) continue;
                where.append(" AND ").append(col).append(" = ? ");
                args.add(v);
            }
        }

        // 日期区间
        String dc = (dateCol != null && hasColumn(t, dateCol)) ? dateCol
                 : (hasColumn(t, "create_time") ? "create_time" : null);
        if (dc != null) {
            if (startDate != null && !startDate.isBlank()) {
                where.append(" AND ").append(dc).append(" >= ? ");
                args.add(normalizeDate(startDate, true));
            }
            if (endDate != null && !endDate.isBlank()) {
                where.append(" AND ").append(dc).append(" <= ? ");
                args.add(normalizeDate(endDate, false));
            }
        }

        String cntSql = "SELECT COUNT(*) FROM " + t + where;
        Long total = jdbc.queryForObject(cntSql, Long.class, args.toArray());

        String orderBy = " ORDER BY id DESC ";
        if (sort != null && !sort.isBlank()) {
            // sort 形如 "amount desc" 或 "order_time asc"
            String[] parts = sort.trim().split("\\s+");
            String col = parts[0];
            String dir = parts.length > 1 && "asc".equalsIgnoreCase(parts[1]) ? "ASC" : "DESC";
            // 只允许已存在的列，防止注入
            if (hasColumn(t, col)) orderBy = " ORDER BY " + col + " " + dir + " ";
        }

        String sql = "SELECT * FROM " + t + where + orderBy + " LIMIT ? OFFSET ?";
        List<Object> qargs = new ArrayList<>(args);
        qargs.add(ps);
        qargs.add((pn - 1) * ps);
        List<Map<String, Object>> list = jdbc.queryForList(sql, qargs.toArray());

        return new PageResult<>(list, total == null ? 0 : total, pn, ps);
    }

    /** 取全部（不分页），用于下拉选项 / 小榜单 */
    public List<Map<String, Object>> listAll(String module, Integer limit) {
        String t = table(module);
        String sql = "SELECT * FROM " + t + (hasColumn(t, "del_flag") ? " WHERE del_flag = 0 " : "");
        if (hasColumn(t, "order_num")) sql += " ORDER BY order_num ASC ";
        else if (hasColumn(t, "id")) sql += " ORDER BY id DESC ";
        if (limit != null && limit > 0) sql += " LIMIT " + limit;
        return jdbc.queryForList(sql);
    }

    /** 单条 */
    public Map<String, Object> get(String module, Long id) {
        String t = table(module);
        List<Map<String, Object>> list = jdbc.queryForList("SELECT * FROM " + t + " WHERE id = ?", id);
        if (list.isEmpty()) throw new IllegalArgumentException("记录不存在");
        return list.get(0);
    }

    /** 新增，返回带 id 的记录 */
    public Map<String, Object> create(String module, Map<String, Object> body) {
        String t = table(module);
        Map<String, Object> data = sanitize(t, body);
        if (data.isEmpty()) throw new IllegalArgumentException("提交数据为空");
        List<String> cols = new ArrayList<>(data.keySet());
        StringBuilder sql = new StringBuilder("INSERT INTO " + t + " (");
        StringBuilder ph = new StringBuilder();
        for (int i = 0; i < cols.size(); i++) {
            if (i > 0) { sql.append(","); ph.append(","); }
            sql.append(cols.get(i)); ph.append("?");
        }
        sql.append(") VALUES (").append(ph).append(")");
        KeyHolder kh = new GeneratedKeyHolder();
        jdbc.update(con -> {
            PreparedStatement ps = con.prepareStatement(sql.toString(), Statement.RETURN_GENERATED_KEYS);
            for (int i = 0; i < cols.size(); i++) ps.setObject(i + 1, data.get(cols.get(i)));
            return ps;
        }, kh);
        Number key = kh.getKey();
        long id = key == null ? 0 : key.longValue();
        return get(module, id);
    }

    /** 编辑 */
    public Map<String, Object> update(String module, Long id, Map<String, Object> body) {
        String t = table(module);
        Map<String, Object> data = sanitize(t, body);
        if (data.isEmpty()) throw new IllegalArgumentException("提交数据为空");
        StringBuilder sql = new StringBuilder("UPDATE " + t + " SET ");
        List<Object> args = new ArrayList<>();
        boolean first = true;
        for (Map.Entry<String, Object> e : data.entrySet()) {
            if (!first) sql.append(",");
            first = false;
            sql.append(e.getKey()).append("=?");
            args.add(e.getValue());
        }
        if (hasColumn(t, "update_time")) { sql.append(",update_time=NOW()"); }
        sql.append(" WHERE id=?");
        args.add(id);
        jdbc.update(sql.toString(), args.toArray());
        return get(module, id);
    }

    /** 删除（有 del_flag 则逻辑删除） */
    public void delete(String module, Long id) {
        String t = table(module);
        if (hasColumn(t, "del_flag")) {
            jdbc.update("UPDATE " + t + " SET del_flag=1 WHERE id=?", id);
        } else {
            jdbc.update("DELETE FROM " + t + " WHERE id=?", id);
        }
    }

    /** 过滤非法列 + 处理日期字符串 */
    private Map<String, Object> sanitize(String table, Map<String, Object> body) {
        Set<String> cols = columns(table);
        Map<String, Object> out = new LinkedHashMap<>();
        for (Map.Entry<String, Object> e : body.entrySet()) {
            String k = e.getKey();
            if (k == null || k.isBlank() || "id".equals(k)) continue;
            if (!cols.contains(k)) continue;
            Object v = e.getValue();
            if (v instanceof String s && (k.endsWith("_time") || k.endsWith("_date") || "hire_date".equals(k) || "last_login".equals(k))) {
                if (s.matches("\\d{4}-\\d{2}-\\d{2}")) v = s + " 00:00:00";
            }
            out.put(k, v);
        }
        return out;
    }

    /** 获取表所有列 */
    private Set<String> columns(String table) {
        return jdbc.queryForList("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?", String.class, table)
                   .stream().map(String::toLowerCase).collect(java.util.stream.Collectors.toSet());
    }

    /** 是否有某列（带缓存） */
    private final Map<String, Boolean> colCache = new ConcurrentHashMap<>();
    private boolean hasColumn(String table, String col) {
        String key = table + "." + col;
        return colCache.computeIfAbsent(key, k -> columns(table).contains(col.toLowerCase()));
    }

    /** 日期标准化：日期补时间 */
    private Object normalizeDate(String s, boolean startOfDay) {
        if (s.matches("\\d{4}-\\d{2}-\\d{2}")) return s + (startOfDay ? " 00:00:00" : " 23:59:59");
        return s;
    }
}
