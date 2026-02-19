# MapleStory Server 079 - 服务器运行状态

**状态检查时间：** 2026-02-19 22:26

---

## 服务器状态总览

### ✅ 服务运行状态
- **主服务进程：** 运行中
- **进程ID：** 101434
- **内存使用：** 930 MB
- **CPU使用：** 19.7%
- **运行时长：** 约5分钟

### ✅ MySQL数据库
- **状态：** 已连接
- **版本：** MySQL 8.0.45
- **数据库名：** maplestory_079
- **连接地址：** 127.0.0.1:3306
- **用户名：** root
- **数据表数量：** 116张表
- **NPC数据：** 1553个

---

## 服务器网络配置

### 登录服务器
- **地址：** 127.0.0.1:1314
- **配置端口：** 7575 (LPort: 9595)
- **状态：** 运行中

### 游戏频道服务器
| 频道 | 地址 | 状态 |
|------|------|------|
| 频道 1 | 127.0.0.1:2525 | ✅ 运行中 |
| 频道 2 | 127.0.0.1:2526 | ✅ 运行中 |
| 频道 3 | 127.0.0.1:2527 | ✅ 运行中 |
| 频道 4 | 127.0.0.1:2528 | ✅ 运行中 |
| 频道 5 | 127.0.0.1:2529 | ✅ 运行中 |
| 频道 6 | 127.0.0.1:2530 | ✅ 运行中 |

### 商城服务器
- **地址：** 127.0.0.1:8600
- **状态：** 运行中

---

## 数据库数据统计

| 数据类型 | 数量 |
|----------|------|
| 账号总数 | 1 |
| 角色总数 | 1 |
| NPC数据 | 1553 |
| 数据表 | 116 |

---

## 服务器配置

### 游戏设置
- **服务器名称：** LOC冒险岛
- **版本：** v.79.1
- **频道数量：** 6
- **最大玩家：** 100人/频道
- **经验倍率：** 20x
- **金币倍率：** 10x
- **掉落倍率：** 2x
- **自动注册：** 已启用

### Java虚拟机配置
```
-Xms512m              # 初始堆内存
-Xmx2048m             # 最大堆内存
-XX:MetaspaceSize=256m    # Metaspace初始大小
-XX:MaxMetaspaceSize=512m # Metaspace最大大小
-XX:MaxNewSize=512m       # 新生代最大大小
```

---

## 已知问题

### ⚠️ JavaScript脚本兼容性问题
**问题描述：** 部分事件脚本报错 `importPackage is not defined`

**影响范围：** 以下事件脚本无法正常加载：
- Trains.js (火车)
- Geenie.js
- AirPlane.js (飞机)
- Boats.js (船)
- GuildQuest.js (公会任务)
- Subway.js (地铁)
- Hak.js
- Cabin.js
- cpq.js / cpq2.js (组队任务)
- Flight.js (航班)
- WuGongPQ.js (武工组队)

**原因分析：**
Java 8的Nashorn JavaScript引擎不支持`importPackage`（这是Rhino引擎的语法）。

**解决方案：**
需要修改这些JavaScript脚本文件，将：
```javascript
importPackage(Packages.xxxx);
```
改为：
```javascript
var ClassName = Java.type("package.name.ClassName");
```

**临时影响：**
- 基本游戏功能正常
- 上述特定事件功能可能无法使用
- 不影响登录、战斗、交易等核心功能

### ℹ️ MySQL SSL警告
**警告信息：** SSL连接警告（非错误）

**影响：** 无实际影响，连接正常

**消除方法：** 在 `config/db.properties` 的URL中添加 `&useSSL=false`

---

## 管理命令

### 查看服务器进程
```bash
ps aux | grep maple.jar
```

### 查看服务器日志
```bash
tail -f logs/server.log
```

### 停止服务器
```bash
pkill -f "maple.jar"
# 或
kill <进程ID>
```

### 重启服务器
```bash
pkill -f "maple.jar"
sleep 3
./start.sh
```

### 查看端口监听（需要安装net-tools）
```bash
apt-get install net-tools
netstat -tulpn | grep java
```

### 测试MySQL连接
```bash
mysql -uroot -pafauria maplestory_079 -e "SELECT COUNT(*) FROM accounts;"
```

---

## 客户端连接信息

### 连接配置
- **服务器IP：** 127.0.0.1
- **登录端口：** 1314（或7575，取决于配置）
- **版本：** 冒险岛 v.79

### 本地测试
1. 修改客户端的服务器列表配置
2. 将IP改为 `127.0.0.1`
3. 端口改为 `1314` 或 `7575`
4. 启动客户端连接

### 远程连接（如需要）
需要修改以下配置：
1. `config/server.properties` 中的 `RoyMS.IP`
2. 开放防火墙端口：1314, 2525-2530, 8600
3. 客户端配置服务器外网IP

---

## 日志文件位置

- **服务器主日志：** `logs/server.log`
- **IP记录：** `logs/LogIPs.txt`
- **MySQL日志：** `/var/log/mysql/error.log`

---

## 备份建议

### 定期备份内容
1. **数据库备份**
   ```bash
   mysqldump -uroot -pafauria maplestory_079 > backup_$(date +%Y%m%d).sql
   ```

2. **配置文件备份**
   ```bash
   tar -czf config_backup_$(date +%Y%m%d).tar.gz config/
   ```

3. **脚本文件备份**
   ```bash
   tar -czf scripts_backup_$(date +%Y%m%d).tar.gz scripts/
   ```

---

## 故障排查

### 服务器无法启动
1. 检查Java是否正确安装：`java -version`
2. 检查MySQL是否运行：`service mysql status`
3. 查看错误日志：`tail -100 logs/server.log`
4. 检查端口占用：`netstat -tulpn | grep -E "1314|2525|8600"`

### 无法连接MySQL
1. 检查MySQL服务：`service mysql status`
2. 测试连接：`mysql -uroot -pafauria`
3. 检查配置：`cat config/db.properties`
4. 查看MySQL日志：`tail /var/log/mysql/error.log`

### 客户端无法连接
1. 检查服务器IP配置是否正确
2. 确认端口开放（防火墙/安全组）
3. 查看服务器日志是否有连接记录
4. 确认客户端版本为v.79

---

**维护人员：** Claude AI
**最后更新：** 2026-02-19 22:26
**服务器版本：** MapleStory 079 / MySQL 8.0 / Java 8
