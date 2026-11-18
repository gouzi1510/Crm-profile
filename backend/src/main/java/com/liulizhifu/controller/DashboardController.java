package com.liulizhifu.controller;

import com.liulizhifu.common.Result;
import com.liulizhifu.service.DashboardService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {
    private final DashboardService service;
    public DashboardController(DashboardService service) { this.service = service; }

    @GetMapping("/overview")
    public Result<Map<String, Object>> overview() { return Result.ok(service.dashboard()); }

    @GetMapping("/insight")
    public Result<Map<String, Object>> insight() { return Result.ok(service.insight()); }

    @GetMapping("/stats/{module}")
    public Result<Map<String, Object>> stats(@PathVariable String module) { return Result.ok(service.stats(module)); }
}
