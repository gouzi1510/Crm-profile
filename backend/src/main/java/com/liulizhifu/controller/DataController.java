package com.liulizhifu.controller;

import com.liulizhifu.common.PageResult;
import com.liulizhifu.common.Result;
import com.liulizhifu.service.DataService;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/** 通用数据接口：/api/data/{module} */
@RestController
@RequestMapping("/api/data")
public class DataController {
    private final DataService service;
    public DataController(DataService service) { this.service = service; }

    @GetMapping("/{module}")
    public Result<PageResult<Map<String, Object>>> page(
            @PathVariable String module,
            @RequestParam(required=false) String keyword,
            @RequestParam(required=false) String startDate,
            @RequestParam(required=false) String endDate,
            @RequestParam(required=false) String dateCol,
            @RequestParam(required=false) String sort,
            @RequestParam(defaultValue="1") Integer pageNum,
            @RequestParam(defaultValue="10") Integer pageSize,
            @RequestParam Map<String, String> allParams) {
        // 从 query 中提取白名单筛选项（排除分页/关键字/日期参数）
        Map<String, String> filters = new LinkedHashMap<>();
        for (Map.Entry<String, String> e : allParams.entrySet()) {
            String k = e.getKey();
            if (List.of("keyword","startDate","endDate","dateCol","sort","pageNum","pageSize","_t").contains(k)) continue;
            filters.put(k, e.getValue());
        }
        return Result.ok(service.page(module, keyword, filters, startDate, endDate, dateCol, pageNum, pageSize, sort));
    }

    /** 下拉选项 / 全部列表 */
    @GetMapping("/{module}/all")
    public Result<List<Map<String, Object>>> all(@PathVariable String module,
                                                 @RequestParam(required=false) Integer limit) {
        return Result.ok(service.listAll(module, limit));
    }

    @GetMapping("/{module}/{id}")
    public Result<Map<String, Object>> get(@PathVariable String module, @PathVariable Long id) {
        return Result.ok(service.get(module, id));
    }

    @PostMapping("/{module}")
    public Result<Map<String, Object>> create(@PathVariable String module, @RequestBody Map<String, Object> body) {
        return Result.ok("新增成功", service.create(module, body));
    }

    @PutMapping("/{module}/{id}")
    public Result<Map<String, Object>> update(@PathVariable String module, @PathVariable Long id,
                                              @RequestBody Map<String, Object> body) {
        return Result.ok("保存成功", service.update(module, id, body));
    }

    @DeleteMapping("/{module}/{id}")
    public Result<Void> delete(@PathVariable String module, @PathVariable Long id) {
        service.delete(module, id);
        return Result.ok("已删除", null);
    }
}
