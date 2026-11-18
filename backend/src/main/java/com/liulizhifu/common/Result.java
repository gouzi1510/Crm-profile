package com.liulizhifu.common;

import java.util.Map;
import java.util.LinkedHashMap;

/** 统一响应结构 */
public class Result<T> {
    private int code;
    private String message;
    private T data;

    public Result() {}
    public Result(int code, String message, T data) {
        this.code = code; this.message = message; this.data = data;
    }
    public static <T> Result<T> ok() { return new Result<>(200, "ok", null); }
    public static <T> Result<T> ok(T data) { return new Result<>(200, "ok", data); }
    public static <T> Result<T> ok(String msg, T data) { return new Result<>(200, msg, data); }
    public static <T> Result<T> fail(String msg) { return new Result<>(500, msg, null); }
    public static <T> Result<T> fail(int code, String msg) { return new Result<>(code, msg, null); }

    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
}
