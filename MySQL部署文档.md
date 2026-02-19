# MapleStory Server 079 - MySQL数据库部署文档

## 目录
- [环境要求](#环境要求)
- [安装MySQL](#安装mysql)
- [配置数据库](#配置数据库)
- [导入数据](#导入数据)
- [验证安装](#验证安装)
- [数据库配置](#数据库配置)
- [管理命令](#管理命令)
- [常见问题](#常见问题)

---

## 环境要求

- 操作系统：Ubuntu 22.04 LTS (或其他Linux发行版)
- 磁盘空间：至少 500MB 可用空间
- 内存：建议 512MB 以上
- 权限：需要 root 或 sudo 权限

---

## 安装MySQL

### 1. 更新软件包列表

```bash
apt-get update
```

### 2. 安装MySQL服务器和客户端

```bash
apt-get install -y mysql-server mysql-client
```

安装过程会自动安装以下组件：
- MySQL Server 8.0
- MySQL Client 8.0
- 相关依赖库

### 3. 启动MySQL服务

```bash
service mysql start
```

### 4. 检查MySQL服务状态

```bash
service mysql status
```

如果显示 "Server version 8.0.x" 和 "Uptime" 信息，说明服务启动成功。

---

## 配置数据库

### 1. 设置root密码

默认情况下，MySQL root用户没有密码。需要设置密码为 `root`（与项目配置文件一致）：

```bash
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"
```

### 2. 创建游戏数据库

```bash
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS maplestory_079 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
```

**数据库配置说明：**
- 数据库名：`maplestory_079`
- 字符集：`utf8` (支持中文)
- 排序规则：`utf8_general_ci`

---

## 导入数据

### 1. 确认SQL文件存在

项目根目录下应该有SQL文件：

```bash
ls -lh ms_20210813_234816.sql
```

文件大小约为 2.0MB。

### 2. 导入SQL数据

```bash
mysql -uroot -proot maplestory_079 < ms_20210813_234816.sql
```

导入过程可能需要10-30秒，请耐心等待。

---

## 验证安装

### 1. 查看数据表数量

```bash
mysql -uroot -proot maplestory_079 -e "SHOW TABLES;"
```

应该显示 **116张数据表**。

### 2. 检查重要数据表

```bash
mysql -uroot -proot maplestory_079 -e "
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'maplestory_079';
SELECT 'Accounts:', COUNT(*) FROM accounts;
SELECT 'Characters:', COUNT(*) FROM characters;
"
```

**预期结果：**
- 数据表数量：116
- 默认账号：1个
- 默认角色：1个

### 3. 主要数据表说明

| 表名 | 用途 |
|------|------|
| accounts | 玩家账号信息 |
| characters | 角色数据 |
| cashshop_items | 商城物品 |
| inventoryitems | 背包物品 |
| inventoryequipment | 装备数据 |
| guilds | 公会信息 |
| drop_data | 怪物掉落数据 |
| shops | NPC商店数据 |
| wz_questdata | 任务数据 |
| skills | 技能数据 |

---

## 数据库配置

### 配置文件位置

项目配置文件：`config/db.properties`

```properties
# JDBC驱动
driverClassName = com.mysql.jdbc.Driver

# 数据库连接URL
url = jdbc:mysql://127.0.0.1:3306/maplestory_079?autoReconnect=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull

# 数据库账号
username = root
password = root

# 连接超时时间（毫秒）
timeout = 300000
```

### 连接参数说明

- `autoReconnect=true` - 自动重连
- `characterEncoding=UTF-8` - 使用UTF-8编码
- `zeroDateTimeBehavior=convertToNull` - 将零日期转换为null

---

## 管理命令

### MySQL服务管理

```bash
# 启动MySQL服务
service mysql start

# 停止MySQL服务
service mysql stop

# 重启MySQL服务
service mysql restart

# 查看服务状态
service mysql status
```

### 数据库操作

```bash
# 登录MySQL
mysql -uroot -proot

# 登录并选择数据库
mysql -uroot -proot maplestory_079

# 执行SQL文件
mysql -uroot -proot 数据库名 < 文件名.sql

# 导出数据库
mysqldump -uroot -proot maplestory_079 > backup.sql

# 导出数据库结构（不包含数据）
mysqldump -uroot -proot --no-data maplestory_079 > structure.sql
```

### 常用SQL命令

```sql
-- 查看所有数据库
SHOW DATABASES;

-- 使用数据库
USE maplestory_079;

-- 查看所有表
SHOW TABLES;

-- 查看表结构
DESC accounts;

-- 查看表数据量
SELECT COUNT(*) FROM accounts;

-- 查看账号信息
SELECT id, name, loggedin FROM accounts;

-- 查看角色信息
SELECT id, name, level, job FROM characters;
```

---

## 常见问题

### 1. MySQL服务无法启动

**症状：** `service mysql start` 失败

**解决方法：**
```bash
# 检查错误日志
tail -n 50 /var/log/mysql/error.log

# 检查端口占用
netstat -tulpn | grep 3306

# 删除锁文件重试
rm -f /var/run/mysqld/mysqld.sock
service mysql restart
```

### 2. 连接被拒绝 (Access Denied)

**症状：** `ERROR 1045 (28000): Access denied for user 'root'@'localhost'`

**解决方法：**
```bash
# 重置root密码
service mysql stop
mysqld_safe --skip-grant-tables &
mysql -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"
service mysql restart
```

### 3. 字符集问题（中文乱码）

**症状：** 中文显示为乱码或问号

**解决方法：**
```bash
# 检查数据库字符集
mysql -uroot -proot -e "SHOW VARIABLES LIKE 'character%';"

# 修改数据库字符集
mysql -uroot -proot -e "
ALTER DATABASE maplestory_079 CHARACTER SET utf8 COLLATE utf8_general_ci;
"
```

### 4. 导入SQL文件出错

**症状：** `ERROR at line XXX: Unknown command`

**解决方法：**
```bash
# 检查SQL文件编码
file ms_20210813_234816.sql

# 转换文件编码（如果需要）
iconv -f GBK -t UTF-8 ms_20210813_234816.sql > ms_utf8.sql

# 使用转换后的文件导入
mysql -uroot -proot maplestory_079 < ms_utf8.sql
```

### 5. 连接超时

**症状：** `Communications link failure`

**解决方法：**

编辑MySQL配置文件 `/etc/mysql/mysql.conf.d/mysqld.cnf`，添加：
```ini
[mysqld]
wait_timeout = 300
interactive_timeout = 300
max_allowed_packet = 64M
```

然后重启MySQL：
```bash
service mysql restart
```

### 6. 商城物品为空

**症状：** 商城没有物品可购买

**说明：** 默认SQL文件中 `cashshop_items` 表为空。

**解决方法：**
- 需要单独配置商城物品数据
- 可以从其他冒险岛服务端获取商城数据
- 或者使用GM命令手动添加物品

---

## 备份建议

### 定期备份

建议每天或每周备份数据库：

```bash
# 创建备份目录
mkdir -p /backup/mysql

# 备份数据库（带时间戳）
mysqldump -uroot -proot maplestory_079 > /backup/mysql/maplestory_079_$(date +%Y%m%d_%H%M%S).sql

# 压缩备份文件
gzip /backup/mysql/maplestory_079_$(date +%Y%m%d_%H%M%S).sql
```

### 自动备份脚本

创建 `backup.sh` 脚本：

```bash
#!/bin/bash
BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/maplestory_079_$DATE.sql"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -uroot -proot maplestory_079 > $BACKUP_FILE

# 压缩备份
gzip $BACKUP_FILE

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "备份完成: $BACKUP_FILE.gz"
```

添加到定时任务（每天凌晨3点执行）：
```bash
chmod +x backup.sh
crontab -e
# 添加以下行：
# 0 3 * * * /data/app/maple/MapleStory-Server-079/backup.sh
```

---

## 安全建议

1. **修改默认密码**
   - 生产环境建议使用复杂密码
   - 定期更换密码

2. **限制远程访问**
   - 默认只允许本地连接（127.0.0.1）
   - 如需远程访问，配置防火墙规则

3. **最小权限原则**
   - 为应用创建专用数据库用户
   - 不要使用root账号运行应用

4. **定期更新**
   - 及时更新MySQL补丁
   - 关注安全公告

---

## 性能优化

### 调整MySQL配置

编辑 `/etc/mysql/mysql.conf.d/mysqld.cnf`：

```ini
[mysqld]
# 缓存大小（根据服务器内存调整）
innodb_buffer_pool_size = 256M
query_cache_size = 32M

# 连接数
max_connections = 500

# 慢查询日志
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

重启MySQL使配置生效：
```bash
service mysql restart
```

---

## 技术支持

- 项目配置文件：`config/db.properties`
- MySQL配置文件：`/etc/mysql/mysql.conf.d/mysqld.cnf`
- MySQL错误日志：`/var/log/mysql/error.log`
- MySQL慢查询日志：`/var/log/mysql/slow.log`

---

**文档版本：** 1.0
**最后更新：** 2026-02-19
**适用版本：** MapleStory Server 079 / MySQL 8.0+
