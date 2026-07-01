# 圣娅快跑 · 鸿蒙版 (Seia Runner for HarmonyOS)

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-Next-blue)](https://www.harmonyos.com/)
[![License](https://img.shields.io/github/license/VanillaNahida/seia-runner)](https://github.com/VanillaNahida/seia-runner/blob/main/LICENSE)

《蔚蓝档案》同人横版跑酷游戏，控制百合园圣娅躲避障碍物，挑战最高分。

本项目移植自网页版 [VanillaNahida/seia-runner](https://github.com/VanillaNahida/seia-runner)，适配 HarmonyOS NEXT (API 22)。

## 功能

- 🏃 横版跑酷玩法：跳跃躲避巧乐兹，下蹲躲避雪碧瓶
- 🎵 多首 BGM 可选，支持静音模式
- 🏆 成绩上传 + 极验验证码防刷
- 📊 日/周/月/总排行榜（iframe 嵌入 + AJAX 秒切）
- 💬 成绩留言、归属地显示
- 🎮 触摸操作（跳跃左下 + 下蹲右下，半透明悬浮按钮）

## 技术架构

| 层 | 技术 |
|----|------|
| 原生 UI | ArkTS + ArkUI |
| 游戏渲染 | WebView 直接加载原网页 |
| UI 定制 | 页面加载后 CSS 注入（按钮布局、画布居中） |
| 排行榜 | iframe 嵌入 + AJAX 无刷新切榜 |
| 验证码 | 极验 v4（原网页侧） |
| 请求头 | 无自定义头，直接同源访问 |

与早期版本的差异：
- ~~资源拦截 + 本地文件替换~~ → 直接加载原网页，通过 CSS 注入定制 UI
- ~~自定义 X-Client-Id 请求头~~ → 移除，API 无需额外认证
- 排行榜使用 iframe 嵌入，切榜秒切，返回游戏瞬间
- 启动加载遮罩 + CSS 注入完毕自动消失

## 构建

1. 安装 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/)
2. 克隆仓库：
   ```
   git clone https://github.com/CJH750/RunningSeia_HarmonyOS.git
   ```
3. 用 DevEco Studio 打开项目
4. 在 `File → Project Structure → Signing Configs` 中配置签名（建议使用自动签名）
5. 点击 `Build → Build HAP(s)` 构建

## 致谢

- 原作网页版：[VanillaNahida/seia-runner](https://github.com/VanillaNahida/seia-runner)
- 原作灵感：[Ottomate 张雪峰跑酷](https://ottomate.games/zxf/)
- 极验验证码：[Geetest](https://www.geetest.com/)

## 许可

本项目仅供学习交流，禁止商业用途。遵循原项目许可协议。

---

欢迎大家克隆并继续优化、开发本项目！如有问题欢迎联系：1156855761@qq.com
