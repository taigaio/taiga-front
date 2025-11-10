#!/bin/bash

# 性能监控功能快速验证脚本

echo "================================"
echo "性能监控功能快速验证"
echo "================================"
echo ""

# 1. 检查服务是否编译
echo "1️⃣  检查服务是否已编译..."
latest_app=$(ls -t dist/v-*/js/app.js 2>/dev/null | head -1)
if [ -n "$latest_app" ]; then
    count=$(grep -c "PerformanceMonitor\|MonitoringCollector" "$latest_app" 2>/dev/null || echo "0")
    if [ "$count" -gt "0" ]; then
        echo "   ✅ 服务已成功编译到 app.js (找到 $count 处引用)"
    else
        echo "   ❌ 服务未找到，需要重新编译"
        echo "   运行: npx gulp app-deploy"
        exit 1
    fi
else
    echo "   ❌ 未找到编译后的 app.js"
    echo "   运行: npx gulp app-deploy"
    exit 1
fi
echo ""

# 2. 检查配置文件
echo "2️⃣  检查配置文件..."
if [ -f "conf/conf.json" ]; then
    echo "   ✅ 找到 conf/conf.json"
    
    # 检查监控配置
    if grep -q '"monitoring"' conf/conf.json; then
        monitoring_enabled=$(grep -A 2 '"monitoring"' conf/conf.json | grep '"enabled"' | grep -o 'true\|false' || echo "未设置")
        echo "   📋 monitoring.enabled: $monitoring_enabled"
    else
        echo "   ⚠️  未找到 monitoring 配置，需要添加"
    fi
    
    if grep -q '"performanceMonitor"' conf/conf.json; then
        perf_enabled=$(grep -A 2 '"performanceMonitor"' conf/conf.json | grep '"enabled"' | grep -o 'true\|false' || echo "未设置")
        echo "   📋 performanceMonitor.enabled: $perf_enabled"
    else
        echo "   ⚠️  未找到 performanceMonitor 配置，需要添加"
    fi
else
    echo "   ⚠️  未找到 conf/conf.json"
    echo "   建议: cp conf/conf.example.json conf/conf.json"
fi
echo ""

# 3. 提供启用配置的示例
echo "3️⃣  如需启用监控，在 conf/conf.json 中添加："
echo ""
cat << 'EOF'
{
  "monitoring": {
    "enabled": true,
    "reportInterval": 300000
  },
  "performanceMonitor": {
    "enabled": true
  }
}
EOF
echo ""

# 4. 检查开发服务器
echo "4️⃣  检查开发服务器状态..."
if lsof -i:9001 > /dev/null 2>&1; then
    echo "   ✅ 开发服务器正在运行 (端口 9001)"
    echo "   访问: http://localhost:9001"
else
    echo "   ℹ️  开发服务器未运行"
    echo "   启动命令: npm start"
fi
echo ""

# 5. 提供测试步骤
echo "================================"
echo "📝 下一步测试步骤："
echo "================================"
echo ""
echo "1. 启动开发服务器（如果还未运行）:"
echo "   npm start"
echo ""
echo "2. 在浏览器中访问:"
echo "   http://localhost:9001"
echo ""
echo "3. 打开浏览器控制台 (F12)"
echo ""
echo "4. 验证监控已初始化，应该看到:"
echo "   [DEBUG] Performance Monitor: initialized"
echo "   [DEBUG] Monitoring Collector: initialized"
echo ""
echo "5. 在控制台中执行测试命令:"
echo "   TaigaMonitoring.getReport()"
echo ""
echo "6. 查看详细测试指南:"
echo "   cat 测试指南_性能监控.md"
echo ""
echo "================================"
echo "验证完成！"
echo "================================"
