package com.liulizhifu.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

/** 首页 / 统计聚合服务：驱动仪表盘、数据洞察等页面的 KPI 与图表 */
@Service
public class DashboardService {
    private final JdbcTemplate jdbc;
    public DashboardService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    private Map<String, Object> one(String sql, Object... args) {
        List<Map<String, Object>> l = jdbc.queryForList(sql, args);
        return l.isEmpty() ? new LinkedHashMap<>() : l.get(0);
    }
    private static double d(Object v) { return v == null ? 0 : ((Number) v).doubleValue(); }

    /** 工作台仪表盘 */
    public Map<String, Object> dashboard() {
        Map<String, Object> out = new LinkedHashMap<>();

        // KPI 四卡：今日交易额、交易笔数、活跃客户、退款订单
        String today = "CURDATE()";
        Map<String, Object> kpi = one(
            "SELECT COALESCE(gmv,0) gmv, COALESCE(order_count,0) orderCount, " +
            "COALESCE(customer_count,0) customerCount, COALESCE(refund_count,0) refundCount, " +
            "COALESCE(avg_price,0) avgPrice, COALESCE(success_rate,0) successRate, " +
            "COALESCE(refund_rate,0) refundRate, COALESCE(gmv_last,0) gmvLast " +
            "FROM ml_daily_stat WHERE stat_date = " + today);
        out.put("kpi", kpi);
        double gmv = d(kpi.get("gmv"));
        double gmvLast = d(kpi.get("gmvLast"));
        kpi.put("gmvGrowth", gmvLast > 0 ? Math.round((gmv - gmvLast) / gmvLast * 10000) / 100.0 : 0);

        // 5 个次级指标
        Map<String, Object> sub = new LinkedHashMap<>();
        sub.put("successRate", kpi.get("successRate"));
        Map<String, Object> fee = one("SELECT COALESCE(SUM(fee),0) v FROM ml_payment WHERE trans_time >= CURDATE()");
        sub.put("feeIncome", fee.get("v"));
        Map<String, Object> pending = one("SELECT COALESCE(SUM(amount),0) v FROM ml_settlement_batch WHERE status='待结算'");
        sub.put("pendingSettle", pending.get("v"));
        Map<String, Object> abnormal = one("SELECT COUNT(*) v FROM ml_risk_alert WHERE status='未处理'");
        sub.put("abnormalCount", abnormal.get("v"));
        Map<String, Object> riskAmt = one("SELECT COALESCE(SUM(amount),0) v FROM ml_risk_alert WHERE status='未处理'");
        sub.put("abnormalAmount", riskAmt.get("v"));
        out.put("sub", sub);

        // 交易趋势（近 30 天）
        List<Map<String, Object>> trend = jdbc.queryForList(
            "SELECT DATE_FORMAT(stat_date,'%m-%d') label, gmv, gmv_last gmvLast, order_count orderCount " +
            "FROM ml_daily_stat ORDER BY stat_date ASC");
        out.put("trend", trend);

        // 支付方式占比
        out.put("payMethods", jdbc.queryForList(
            "SELECT channel_name name, amount, ratio, count FROM ml_channel_stat ORDER BY ratio DESC"));

        // 实时交易流水（最近 8 条）
        out.put("realtime", jdbc.queryForList(
            "SELECT trans_no transNo, DATE_FORMAT(trans_time,'%m-%d %H:%i') transTime, customer_name customerName, " +
            "trans_type transType, pay_method payMethod, amount, status, settle_status settleStatus " +
            "FROM ml_payment WHERE del_flag=0 ORDER BY trans_time DESC LIMIT 8"));

        // 营收榜 TOP5
        out.put("revenueTop", jdbc.queryForList(
            "SELECT customer_name customerName, amount, order_count orderCount FROM ml_revenue_rank ORDER BY rank_no ASC LIMIT 5"));

        // 系统运行状态
        out.put("systemStatus", jdbc.queryForList(
            "SELECT module_name moduleName, status, uptime, remark FROM ml_system_status WHERE del_flag=0 ORDER BY order_num ASC"));

        // 最新公告
        out.put("notices", jdbc.queryForList(
            "SELECT title, notice_type noticeType, DATE_FORMAT(publish_time,'%m-%d') publishTime, top_flag topFlag " +
            "FROM ml_notice WHERE del_flag=0 ORDER BY top_flag DESC, publish_time DESC LIMIT 5"));

        return out;
    }

    /** 数据洞察 */
    public Map<String, Object> insight() {
        Map<String, Object> out = new LinkedHashMap<>();
        Map<String, Object> kpi = one(
            "SELECT COALESCE(SUM(gmv),0) gmv, COALESCE(SUM(order_count),0) orderCount, " +
            "COALESCE(AVG(avg_price),0) avgPrice, COALESCE(AVG(success_rate),0) successRate, " +
            "COALESCE(AVG(refund_rate),0) refundRate " +
            "FROM ml_daily_stat WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 29 DAY)");
        out.put("kpi", kpi);
        out.put("trend", jdbc.queryForList(
            "SELECT DATE_FORMAT(stat_date,'%m-%d') label, gmv, gmv_last gmvLast FROM ml_daily_stat ORDER BY stat_date ASC"));
        out.put("payMethods", jdbc.queryForList(
            "SELECT channel_name name, amount, ratio FROM ml_channel_stat ORDER BY ratio DESC"));
        out.put("warehouseRank", jdbc.queryForList(
            "SELECT store_name storeName, amount, order_count orderCount FROM ml_warehouse_rank ORDER BY rank_no ASC LIMIT 10"));
        out.put("successRate", jdbc.queryForList(
            "SELECT module_name name, uptime, status FROM ml_system_status WHERE del_flag=0 ORDER BY order_num ASC"));
        return out;
    }

    /** 各页面顶部统计小卡（通用：按模块返回 count / sum） */
    public Map<String, Object> stats(String module) {
        Map<String, Object> out = new LinkedHashMap<>();
        switch (module) {
            case "trade": {
                Map<String, Object> a = one("SELECT COUNT(*) cnt, COALESCE(SUM(amount),0) amt FROM ml_payment WHERE del_flag=0");
                Map<String, Object> b = one("SELECT COUNT(*) cnt FROM ml_payment WHERE del_flag=0 AND status='成功'");
                Map<String, Object> c = one("SELECT COUNT(*) cnt FROM ml_payment WHERE del_flag=0 AND status='失败'");
                Map<String, Object> e = one("SELECT COUNT(*) cnt FROM ml_payment WHERE del_flag=0 AND trans_type='退款'");
                out.put("totalCount", a.get("cnt")); out.put("totalAmount", a.get("amt"));
                out.put("successCount", b.get("cnt")); out.put("failedCount", c.get("cnt")); out.put("refundCount", e.get("cnt"));
                break;
            }
            case "channel": {
                Map<String, Object> a = one("SELECT COUNT(*) cnt FROM ml_channel WHERE del_flag=0");
                Map<String, Object> b = one("SELECT COALESCE(AVG(availability),0) v FROM ml_channel WHERE del_flag=0");
                Map<String, Object> c = one("SELECT COALESCE(AVG(response_ms),0) v FROM ml_channel WHERE del_flag=0");
                out.put("channelCount", a.get("cnt")); out.put("availability", b.get("v")); out.put("avgResponse", c.get("v"));
                out.put("alertCount", 0);
                break;
            }
            case "account": {
                Map<String, Object> a = one("SELECT COALESCE(SUM(balance),0) bal, COUNT(*) cnt FROM ml_account WHERE del_flag=0");
                Map<String, Object> b = one("SELECT COALESCE(SUM(today_share),0) v FROM ml_account WHERE del_flag=0");
                out.put("totalBalance", a.get("bal")); out.put("accountCount", a.get("cnt")); out.put("todayShare", b.get("v"));
                Map<String, Object> c = one("SELECT COUNT(*) v FROM ml_share_detail WHERE status='待分账'".replace("ml_share_detail", "ml_profit_share_detail"));
                out.put("pendingCount", c.get("v"));
                break;
            }
            case "settlement": {
                Map<String, Object> a = one("SELECT COALESCE(SUM(amount),0) v FROM ml_settlement_batch WHERE status IN ('待结算','结算中')");
                Map<String, Object> b = one("SELECT COALESCE(SUM(amount),0) v FROM ml_settlement_batch WHERE status='已结算'");
                Map<String, Object> c = one("SELECT COUNT(*) v FROM ml_settlement_batch WHERE status='失败'");
                out.put("pendingAmount", a.get("v")); out.put("settledAmount", b.get("v")); out.put("abnormalCount", c.get("v"));
                out.put("successRate", 99.94);
                break;
            }
            case "payment": {
                Map<String, Object> a = one("SELECT COALESCE(SUM(amount),0) v FROM ml_payment_order WHERE del_flag=0");
                Map<String, Object> b = one("SELECT COUNT(*) v FROM ml_payment_order WHERE status='待审核'");
                Map<String, Object> c = one("SELECT COUNT(*) v FROM ml_payment_order WHERE status='审核中'");
                out.put("totalAmount", a.get("v")); out.put("pendingCount", b.get("v")); out.put("reviewingCount", c.get("v"));
                out.put("successRate", 99.5);
                break;
            }
            case "store": {
                Map<String, Object> a = one("SELECT COUNT(*) v FROM ml_warehouse WHERE del_flag=0");
                Map<String, Object> b = one("SELECT COUNT(*) v FROM ml_terminal WHERE del_flag=0");
                Map<String, Object> c = one("SELECT COUNT(*) v FROM ml_terminal WHERE status='在线'");
                Map<String, Object> e = one("SELECT COALESCE(SUM(today_amount),0) v FROM ml_warehouse WHERE del_flag=0");
                out.put("storeCount", a.get("v")); out.put("terminalTotal", b.get("v")); out.put("terminalOnline", c.get("v"));
                out.put("todayAmount", e.get("v"));
                break;
            }
            case "member": {
                Map<String, Object> a = one("SELECT COUNT(*) v FROM ml_member WHERE del_flag=0");
                Map<String, Object> b = one("SELECT COALESCE(SUM(total_amount),0) v FROM ml_member WHERE del_flag=0");
                Map<String, Object> c = one("SELECT COUNT(*) v FROM ml_goods WHERE del_flag=0");
                out.put("memberCount", a.get("v")); out.put("memberAmount", b.get("v")); out.put("goodsCount", c.get("v"));
                out.put("repurchaseRate", 38.4);
                break;
            }
            case "risk": {
                Map<String, Object> a = one("SELECT COUNT(*) v FROM ml_risk_alert WHERE status='未处理'");
                Map<String, Object> b = one("SELECT COUNT(*) v FROM ml_risk_alert WHERE level='P0' AND status!='已处理'");
                Map<String, Object> c = one("SELECT COALESCE(SUM(amount),0) v FROM ml_risk_alert WHERE status='未处理'");
                out.put("pending", a.get("v")); out.put("highRisk", b.get("v")); out.put("amount", c.get("v"));
                out.put("queryMerchants", 128);
                break;
            }
            default: {
                out.put("total", jdbc.queryForObject("SELECT COUNT(*) FROM " + safeTable(module), Integer.class));
            }
        }
        return out;
    }

    private String safeTable(String module) {
        Map<String, String> m = Map.of(
            "goods", "ml_goods", "customer", "ml_customer", "order", "ml_sales_order",
            "payment", "ml_payment", "supplier", "ml_supplier", "member", "ml_member");
        return m.getOrDefault(module, "ml_goods");
    }
}
