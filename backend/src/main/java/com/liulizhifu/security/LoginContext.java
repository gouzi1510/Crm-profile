package com.liulizhifu.security;

/** 当前登录上下文 */
public class LoginContext {
    private static final ThreadLocal<String> USER = new ThreadLocal<>();
    public static void set(String username) { USER.set(username); }
    public static String get() { return USER.get(); }
    public static void clear() { USER.remove(); }
}
