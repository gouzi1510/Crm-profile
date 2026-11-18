package com.liulizhifu.controller;

import com.liulizhifu.common.Result;
import com.liulizhifu.security.TokenService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final JdbcTemplate jdbc;
    private final TokenService tokenService;
    public AuthController(JdbcTemplate jdbc, TokenService tokenService) {
        this.jdbc = jdbc; this.tokenService = tokenService;
    }

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, Object> body) {
        String username = str(body.get("username"));
        String password = str(body.get("password"));
        List<Map<String, Object>> list = jdbc.queryForList(
            "SELECT a.id, a.username, a.real_name realName, a.emp_id empId, e.dept_id deptId, d.dept_name deptName " +
            "FROM sys_account a LEFT JOIN sys_employee e ON a.emp_id=e.id LEFT JOIN sys_dept d ON e.dept_id=d.id " +
            "WHERE a.username=? AND a.password=? AND a.status=1 AND a.del_flag=0", username, password);
        if (list.isEmpty()) return Result.fail(401, "账号或密码错误");
        Map<String, Object> user = list.get(0);
        // 角色
        List<String> roles = new ArrayList<>();
        if (user.get("empId") != null) {
            roles = jdbc.queryForList(
                "SELECT role_name FROM sys_role WHERE status=1 GROUP BY role_name ORDER BY MIN(order_num) LIMIT 5",
                String.class);
        }
        if (roles.isEmpty()) roles.add("系统用户");
        user.put("roles", roles);
        String token = tokenService.createToken(username);
        jdbc.update("UPDATE sys_account SET last_login=NOW() WHERE username=?", username);
        jdbc.update("INSERT INTO sys_login_log(username,ip,device,status) VALUES(?,?,?,1)",
                    username, "", "Web 浏览器");
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("token", token);
        data.put("userInfo", user);
        return Result.ok("登录成功", data);
    }

    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader(value="Authorization", required=false) String auth) {
        if (auth != null && auth.startsWith("Bearer ")) tokenService.remove(auth.substring(7));
        return Result.ok();
    }

    @GetMapping("/me")
    public Result<Map<String, Object>> me(@RequestHeader(value="Authorization", required=false) String auth) {
        String username = null;
        if (auth != null && auth.startsWith("Bearer ")) username = tokenService.getUsername(auth.substring(7));
        if (username == null) return Result.fail(401, "未登录");
        List<Map<String, Object>> l = jdbc.queryForList(
            "SELECT id, username, real_name realName FROM sys_account WHERE username=?", username);
        return Result.ok(l.isEmpty() ? Map.of("username", username) : l.get(0));
    }

    /** 菜单树（按角色返回全部，演示不做细粒度过滤） */
    @GetMapping("/menus")
    public Result<List<Map<String, Object>>> menus() {
        List<Map<String, Object>> all = jdbc.queryForList(
            "SELECT id, parent_id parentId, menu_name name, path, icon, type, perm, order_num orderNum " +
            "FROM sys_menu WHERE status=1 ORDER BY order_num ASC");
        List<Map<String, Object>> roots = new ArrayList<>();
        Map<Object, List<Map<String, Object>>> children = new HashMap<>();
        for (Map<String, Object> m : all) {
            Object pid = m.get("parentId");
            if (pid == null || ((Number)pid).longValue() == 0) roots.add(m);
            else children.computeIfAbsent(pid, k -> new ArrayList<>()).add(m);
        }
        for (Map<String, Object> m : roots) {
            List<Map<String, Object>> ch = children.get(m.get("id"));
            m.put("children", ch == null ? List.of() : ch);
        }
        return Result.ok(roots);
    }

    private static String str(Object o) { return o == null ? "" : String.valueOf(o); }
}
