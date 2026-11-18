package com.liulizhifu.config;

import com.liulizhifu.common.Result;
import com.liulizhifu.security.LoginContext;
import com.liulizhifu.security.TokenService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** CORS + 登录拦截（除 /api/auth/** 外都需 token） */
@Configuration
public class WebConfig implements WebMvcConfigurer {
    private final TokenService tokenService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public WebConfig(TokenService tokenService) { this.tokenService = tokenService; }

    /**
     * CORS 改用 Servlet Filter 级实现（替代 MVC addCorsMappings）：
     * - Filter 位于拦截器之前，预检 OPTIONS 直接短路返回 200，不会进入登录拦截器被 401 掉
     * - 异常响应（GlobalExceptionHandler 产出的 500/业务错误体）同样会带上 CORS 头，
     *   避免浏览器端报 CORS 错误而掩盖真实的服务端错误
     * - 生产环境请白名单化 allowedOriginPatterns，勿用 "*"
     */
    @Bean
    public FilterRegistrationBean<CorsFilter> corsFilter() {
        CorsConfiguration cfg = new CorsConfiguration();
        cfg.setAllowedOriginPatterns(java.util.List.of("*"));
        cfg.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        cfg.setAllowedHeaders(java.util.List.of("*"));
        cfg.setAllowCredentials(true);
        cfg.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", cfg);
        FilterRegistrationBean<CorsFilter> bean = new FilterRegistrationBean<>(new CorsFilter(source));
        bean.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return bean;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new HandlerInterceptor() {
            @Override
            public boolean preHandle(HttpServletRequest req, HttpServletResponse resp, Object handler) throws Exception {
                String path = req.getRequestURI();
                if (path.startsWith("/api/auth/")) return true;
                String header = req.getHeader("Authorization");
                String token = (header != null && header.startsWith("Bearer ")) ? header.substring(7) : null;
                String username = tokenService.getUsername(token);
                if (username == null) {
                    resp.setStatus(200);
                    resp.setContentType("application/json;charset=UTF-8");
                    objectMapper.writeValue(resp.getWriter(), Result.fail(401, "登录已过期，请重新登录"));
                    return false;
                }
                LoginContext.set(username);
                return true;
            }
            @Override
            public void afterCompletion(HttpServletRequest req, HttpServletResponse resp, Object handler, Exception ex) {
                LoginContext.clear();
            }
        }).addPathPatterns("/api/**");
    }
}
