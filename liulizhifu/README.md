# 穗丰粮仓 · Linux 部署（liulizhifu/install.sh）

仓库只含源码。`install.sh` 在目标服务器上**自动从源码构建**前后端并部署，
目标机只需能联网安装 JDK17 / MySQL8 / Nginx。

## 部署步骤

```bash
# 1. 克隆仓库
git clone https://github.com/gouzi1510/Ram.git && cd Ram

# 2. 一键部署（root）
sudo bash liulizhifu/install.sh
```

常用参数（环境变量传入）：

```bash
sudo ADMIN_PWD='强密码' bash liulizhifu/install.sh        # 自定义管理员登录密码
sudo MYSQL_ROOT_PWD='root密码' bash liulizhifu/install.sh # CentOS root 非免密时
sudo APP_DOMAIN=your.com bash liulizhifu/install.sh       # 有域名时
sudo DB_APP_PWD='强密码' bash liulizhifu/install.sh       # 自定义数据库应用账号密码
```

## 脚本做了什么

1. 探测包管理器（dnf/yum/apt），安装 JDK17 + MySQL8（无则回退 MariaDB）+ Nginx
2. 导入 `backend/.../db/01_schema.sql`（39 张表）+ `03_base_config.sql`（角色/菜单配置）
3. 按 `ADMIN_PWD` **现场创建** admin 账号（密码不入库）；建最小权限 DB 账号 `liulizhifu@127.0.0.1`
4. 构建产物：优先用 `liulizhifu/app|web`（若随包上传），否则 `mvn package` + `vite build` 现场构建
5. jar → `/opt/liulizhifu/app`，注册 systemd 服务 `liulizhifu`（8081，崩溃自启）
6. dist → `/opt/liulizhifu/web`，Nginx 80 托管并反代 `/api` → 8081
7. 处理 SELinux（httpd_can_network_connect）、禁用抢占 80 的旧站点（备份到 /root/nginx-backup）、放行防火墙

脚本幂等，可重复执行。

## 跨域说明

生产为**同源部署**：页面和 API 都走 Nginx 80，`/api/` 反代到后端 8081，浏览器视角同源，
**不存在跨域问题**。（Windows 开发期是 5180 直连 8081，靠后端 CorsFilter 放行。）

## 日常运维

```bash
systemctl status liulizhifu        # 后端状态
journalctl -u liulizhifu -f        # 后端实时日志
systemctl restart liulizhifu nginx # 重启
nginx -t && systemctl reload nginx # 改配置后热加载
```

## 更新发布（改了代码之后）

```bash
cd Ram && git pull
sudo bash liulizhifu/install.sh    # 重新构建并部署，幂等
```

## 上生产前建议

1. 部署时用 `ADMIN_PWD` 指定强密码（默认 admin123 仅演示）
2. 用 `DB_APP_PWD` 指定数据库应用账号密码
3. token 存于后端内存，重启即全员掉线重登（演示可接受；生产可换 JWT/Redis）
4. 建议加 HTTPS：`certbot --nginx`（需先有域名并配 A 记录）
5. 阿里云用户注意：安全组（或轻量服务器防火墙）需放行 **80** 端口，否则公网打不开
