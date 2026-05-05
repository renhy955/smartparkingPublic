# ============================================
# 智能停车场管理平台 Dockerfile
# 多阶段构建优化版（利用缓存加速）
# ============================================

# 第一阶段：Maven构建阶段（优化缓存）
FROM maven:3.8.6-openjdk-8 AS builder

WORKDIR /app

# 配置Maven阿里云镜像（加速依赖下载）
RUN mkdir -p /root/.m2 && echo '<?xml version="1.0" encoding="UTF-8"?><settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd"><mirrors><mirror><id>aliyunmaven</id><mirrorOf>central</mirrorOf><name>阿里云公共仓库</name><url>https://maven.aliyun.com/repository/public</url></mirror></mirrors></settings>' > /root/.m2/settings.xml

# 先复制pom.xml，利用Docker缓存（pom.xml不变时跳过重新下载依赖）
COPY pom.xml .
RUN mvn dependency:resolve -DskipTests

# 再复制源代码
COPY src ./src

# 构建项目
RUN mvn clean package -DskipTests

# ============================================
# 第二阶段：运行阶段
# ============================================
FROM ubuntu:20.04

WORKDIR /app

# 使用国内apt源加速
RUN sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 设置非交互式模式，避免时区配置弹窗
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    mysql-server \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# 设置Java环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# 从构建阶段复制打包好的war文件
COPY --from=builder /app/target/Smart-Parking.war .

# 创建启动脚本（修复SQL命令转义问题）
RUN printf '#!/bin/bash\nservice mysql start\nsleep 10\nmysql -u root -e "ALTER USER '"'"'root'"'"'@'"'"'localhost'"'"' IDENTIFIED WITH mysql_native_password BY '"'"'root'"'"'; FLUSH PRIVILEGES;"\nmysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS \`smart-parking\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"\njava -jar Smart-Parking.war --server.port=8100 --spring.profiles.active=dev\n' > /app/start.sh && chmod +x /app/start.sh

EXPOSE 8100 3306

CMD ["/app/start.sh"]