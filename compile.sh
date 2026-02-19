#!/bin/bash

echo "=========================================="
echo "  MapleStory Server 079 编译脚本"
echo "=========================================="

# 设置变量
SRC_DIR="src"
BUILD_DIR="build"
BIN_DIR="bin"
LIB_DIR="lib"
JAR_NAME="maple.jar"

# 清理旧的编译文件
echo "1. 清理旧的编译文件..."
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${BIN_DIR}

# 查找所有Java源文件（排除乱码文件名）
echo "2. 查找Java源文件..."
find ${SRC_DIR} -name "*.java" | LC_ALL=C grep -v '[^[:print:]]' | grep -v '宠物数据\|装备数据' > sources.txt
SOURCE_COUNT=$(wc -l < sources.txt)
echo "   找到 ${SOURCE_COUNT} 个Java文件（已排除乱码文件名）"

# 设置classpath
CLASSPATH="${LIB_DIR}/slf4j-api.jar:${LIB_DIR}/slf4j-jdk14.jar:${LIB_DIR}/mina-core-2.0.9.jar:${LIB_DIR}/mysql-connector-java-bin.jar"

# 编译Java文件
echo "3. 编译Java源文件..."
javac -encoding UTF-8 \
      -source 1.7 \
      -target 1.7 \
      -d ${BUILD_DIR} \
      -cp ${CLASSPATH} \
      @sources.txt

if [ $? -ne 0 ]; then
    echo "❌ 编译失败！"
    rm sources.txt
    exit 1
fi

echo "✓ 编译成功！"

# 复制资源文件
echo "4. 复制资源文件..."
cp -r ${SRC_DIR}/META-INF ${BUILD_DIR}/ 2>/dev/null || true
cp ${SRC_DIR}/*.properties ${BUILD_DIR}/ 2>/dev/null || true

# 打包成JAR
echo "5. 打包JAR文件..."
cd ${BUILD_DIR}
jar cvfm ../${BIN_DIR}/${JAR_NAME} META-INF/MANIFEST.MF . > /dev/null 2>&1
cd ..

if [ ! -f "${BIN_DIR}/${JAR_NAME}" ]; then
    echo "❌ JAR打包失败！"
    rm sources.txt
    exit 1
fi

# 清理临时文件
rm sources.txt

# 显示结果
JAR_SIZE=$(du -h ${BIN_DIR}/${JAR_NAME} | cut -f1)
echo ""
echo "=========================================="
echo "✓ 编译完成！"
echo "  输出文件: ${BIN_DIR}/${JAR_NAME}"
echo "  文件大小: ${JAR_SIZE}"
echo "=========================================="
