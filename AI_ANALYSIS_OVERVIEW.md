# Taiga 前端 AI 分析功能 — 概览文档

> 目的：在本仓库对话或会话上下文被清空后，开发者/维护者可以通过本文件快速理解、调试和继续开发 AI 分析功能的前端实现与与后端对接要点。

---

## 一句话摘要

当前前端实现：同步（Synchronous）+ 批量（Batch）。
- 点击“AI 分析”按钮后，前端会一次性将当前可见的所有 Issues 发送（或在当前实现中模拟发送），等待完整分析结果返回，然后在 Lightbox 中一次性展示所有结果。
- 后端尚未实现：前端使用模拟数据，真实 API 调用已在服务中预留（被注释）。

---

## 目录

1. 快速回答
2. 关键文件与代码证据
3. 功能与数据结构详述
4. 前端如何切换到真实后端（替换模拟数据）
5. 后端对接规范（请求 / 响应）
6. 本地运行与测试指南
7. 已完成 / 待完成 工作项
8. 下一步建议与扩展方向
9. 参考文档

---

## 1. 快速回答

- API 交互方式：同步（Synchronous）
- API 设计方案：批量（Batch：一次传入多个 Issues）
- 当前状态：前端完成（使用模拟数据），后端待实现

---

## 2. 关键文件与代码证据

重要文件（路径相对于 `taiga-front`）：

- `app/modules/services/ai-analysis.service.coffee` — AI 分析服务（当前使用模拟数据）
  - 关键方法：`analyzeIssues(projectId, issues)`
  - 当前实现：使用 `setTimeout` 模拟延迟并返回 `mockResults`；真实 API 调用已注释（包含 `@http.post` 模板）。

- `app/coffee/modules/issues/list.coffee` — Issues 列表控制器
  - 关键方法：`analyzeIssuesWithAI()`
  - 行为：收集 `@scope.issues`（当前可见所有 issues），调用 `@aiAnalysisService.analyzeIssues(projectId, issues)`，使用 `.then()` 等待完整结果并打开 Lightbox 显示。

- `app/partials/issue/ai-analysis-lightbox.jade` — Lightbox 模板（展示分析结果）
- `app/modules/components/issues-table/issues/ai-analysis.scss` — 样式文件（蓝色主题）
- 翻译键：`app/locales/taiga/locale-en.json`、`app/locales/taiga/locale-zh-hans.json`

关键代码片段（说明）:

- 同步 + 批量证据：
  - 服务中（注释掉的真实调用示例）会发送一次 `@http.post(@.apiUrl, { project_id, issue_ids: _.map(issues, (i) -> i.id), issues: @._formatIssuesForAPI(issues) })`，并在 `.then` 中 `deferred.resolve(response.data.results)`。
  - 控制器中调用时直接 `@aiAnalysisService.analyzeIssues(projectId, issues).then (results) -> openAiAnalysisLightbox(results)`。

---

## 3. 功能与数据结构详述

功能目标：在 Issue 列表页面，新增一个“AI 分析”按钮，用户点击后分析当前可见的所有 Issues 并展示 AI 生成的建议（推荐优先级、类型、描述、关联模块与解决方案）。

前端数据结构（示例）：

```javascript
{
  issueId: Number,
  issueRef: String,
  subject: String,
  analysis: {
    priority: String,
    type: String,
    severity: String,
    description: String,
    relatedModules: [String],
    solutions: [String],
    confidence?: Number
  }
}
```

视图交互流程：
1. 用户点击 `AI 分析` 按钮
2. 显示 Loading（`ISSUES.AI_ANALYSIS_LOADING`）
3. 调用 `analyzeIssues(projectId, issues)`（当前为模拟）
4. 等待 Promise 完成（同步等待）
5. 关闭 Loading，打开 Lightbox 显示所有结果

---

## 4. 前端如何切换到真实后端（替换模拟数据）

在 `app/modules/services/ai-analysis.service.coffee` 中找到 `analyzeIssues`，将注释的真实请求取消注释并移除 `setTimeout` 模拟部分：

示例替换：

```coffeescript
analyzeIssues: (projectId, issues) ->
  deferred = @q.defer()

  @http.post(@.apiUrl, {
    project_id: projectId,
    issue_ids: _.map(issues, (issue) -> issue.id),
    issues: @._formatIssuesForAPI(issues)
  }).then (response) =>
    deferred.resolve(response.data.results)
  .catch (error) =>
    deferred.reject(error)

  return deferred.promise
```

注意事项：
- 确保 `@config.get('api')` 配置正确，指向后端服务。
- 后端需实现认证（Bearer Token）和权限检查；前端需要传递当前会话的认证头（Angular $http 默认会发送 cookie，或使用 `Authorization` header）。
- 如果后端返回字段命名风格与前端不同（snake_case vs camelCase），可在 `then` 回调中做字段映射转换。

---

## 5. 后端对接规范（请求 / 响应）

推荐最小可行 API（与前端当前实现匹配）

端点：
```
POST /api/v1/issues/ai-analyze
```

请求体（JSON）：

```json
{
  "project_id": 1,
  "issue_ids": [1,2,3],
  "issues": [
    { "id":1, "ref":2, "subject":"...", "description":"...", "type":"Bug", "priority":"Normal", "severity":"Normal", "status":"New", "tags":["前端"] }
  ]
}
```

成功响应（JSON）：

```json
{
  "success": true,
  "results": [
    {
      "issue_id": 1,
      "issue_ref": 2,
      "subject": "...",
      "analysis": {
        "priority": "High",
        "priority_reason": "...",
        "type": "Bug",
        "severity": "High",
        "description": "...",
        "related_modules": ["前端-看板模块"],
        "solutions": ["..."],
        "confidence": 0.85
      }
    }
  ]
}
```

错误响应示例：

```json
{
  "success": false,
  "error": "AI service unavailable",
  "message": "AI 分析服务暂时不可用，请稍后重试"
}
```

后端建议：
- 返回 200 OK 并在 body 中使用 `success: true/false`；或根据团队风格使用 202/4xx/5xx 状态码。
- 建议响应时间（1-50 items）：< 30s。若需要更长时间，建议实现异步（方案 B）并返回 task_id。

---

## 6. 本地运行与测试指南

快速启动前端开发服务器（在 `taiga-front` 目录）：

```bash
# 安装依赖（若未安装）
npm install

# 启动前端（示例）
npm start
# 或根据项目实际启动脚本（例如 gulp、webpack）
```

在浏览器中打开： http://localhost:9001 （示例端口）

测试步骤：
1. 打开 Issues 页面
2. 点击右上角蓝色 "AI 分析" 按钮
3. 观察 Loading 提示
4. 1.5s 后 Lightbox 弹出显示模拟结果
5. 验证每个卡片的信息完整性
6. 关闭 Lightbox

联调（后端实现后）：
- 替换服务中的模拟实现（见第 4 节）
- 执行一次真实请求，检查后端返回字段是否需要映射
- 若出现超时或 202/任务ID 语义，请与后端确认是同步还是异步实现

常见问题 & 排查：
- 无法加载：检查 `npm start` 是否成功，查看 Console 和 Network
- 401 Unauthorized：检查前端是否正确发送 Token 或 Cookie
- CORS 错误：确认后端允许前端 origin，或在开发环境使用代理

---

## 7. 已完成 / 待完成 工作项

已完成（前端）：
- 添加 AI 分析按钮、Lightbox、样式和翻译
- 实现 `analyzeIssues`（使用模拟数据）和控制器触发逻辑
- 文档：`AI_ANALYSIS_CHANGES.md`, `COMPLETION_SUMMARY.md`, `CURRENT_IMPLEMENTATION_STATUS.md`

待完成（后端 & 联调）：
- 后端实现 `POST /api/v1/issues/ai-analyze`
- 前端取消注释真实 API 调用并映射字段
- 性能优化与权限校验
- 扩展特性：选择性分析、进度条、历史记录、缓存

---

## 8. 下一步建议与扩展方向

短期（MVP）：
- 后端实现同步批量接口（方案 A），确保 1-50 items 在 30s 内响应
- 前端取消注释并联调

中期：
- 支持异步任务（方案 B）以处理更大量的数据或长时间模型推理
- 增加进度条 / 实时更新
- 支持只分析选中 Items

长期：
- 学习用户交互，对 AI 结果进行微调和模型改进
- 自动应用并回滚建议
- 分析历史与统计面板

---

## 9. 参考文档

- `AI_ANALYSIS_CHANGES.md` — 代码改动记录
- `COMPLETION_SUMMARY.md` — 完成总结
- `CURRENT_IMPLEMENTATION_STATUS.md` — 当前实现状态（同步 + 批量）
- `BACKEND_API_INTEGRATION.md` — 后端 API 详细规范（如存在）

---

## 附录：快速定位代码（相对于 `taiga-front` 根目录）

- `app/modules/services/ai-analysis.service.coffee`
- `app/coffee/modules/issues/list.coffee`
- `app/partials/issue/ai-analysis-lightbox.jade`
- `app/modules/components/issues-table/issues/ai-analysis.scss`
- `app/partials/issue/issues.jade` (按钮位置)
- `app/locales/taiga/locale-en.json`
- `app/locales/taiga/locale-zh-hans.json`

---

文档由前端实现者生成，目的是在会话上下文丢失或与新成员协作时，能快速恢复开发状态与下一步工作。若需要，我可以把这个文档进一步精简成 PR 描述或 README 模板，或者把关键代码片段直接插回到 README 中以便快速浏览。