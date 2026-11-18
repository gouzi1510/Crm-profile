package com.liulizhifu.security;

import org.springframework.stereotype.Component;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/** 轻量 token 服务：内存态，登录签发，退出失效 */
@Component
public class TokenService {
    private final Map<String, String> tokens = new ConcurrentHashMap<>();
    private static final String SECRET = "liulizhifu-grain-2026";

    public String createToken(String username) {
        String raw = username + "|" + System.currentTimeMillis() + "|" + UUID.randomUUID();
        String token = md5(raw + SECRET);
        tokens.put(token, username);
        return token;
    }

    public String getUsername(String token) {
        return token == null ? null : tokens.get(token);
    }

    public void remove(String token) {
        if (token != null) tokens.remove(token);
    }

    private static String md5(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { throw new RuntimeException(e); }
    }
}
