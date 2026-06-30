# 圣娅快跑 · 鸿蒙版 (Seia Runner for HarmonyOS)

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-Next-blue)](https://www.harmonyos.com/)
[![License](https://img.shields.io/github/license/VanillaNahida/seia-runner)](https://github.com/VanillaNahida/seia-runner/blob/main/LICENSE)

《蔚蓝档案》同人横版跑酷游戏，控制百合园圣娅躲避障碍物，挑战最高分。

本项目移植自网页版 [VanillaNahida/seia-runner](https://github.com/VanillaNahida/seia-runner)，适配 HarmonyOS NEXT (API 22)。

## 功能

- 🏃 横版跑酷玩法：跳跃躲避巧乐兹，下蹲躲避雪碧瓶
- 🎵 多首 BGM 可选，支持静音模式
- 🏆 成绩上传 + 极验验证码防刷
- 📊 日/周/月/总排行榜
- 💬 成绩留言、归属地显示
- 🎮 支持键盘（W/S/空格）和触摸操作

## 技术架构

| 层 | 技术 |
|----|------|
| 原生 UI | ArkTS + ArkUI |
| 游戏渲染 | Canvas (WebView 内嵌) |
| 网络代理 | WebView 资源拦截 + 本地资源替换 |
| 验证码 | 极验 v4 SDK |

游戏核心逻辑运行在 WebView 中，通过资源拦截实现本地秒加载 + 远程 API 同源访问。

## 构建

1. 安装 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/)
2. 克隆仓库：
   ```
   git clone https://github.com/CJH750/RunningSeia_HarmonyOS.git
   ```
3. 用 DevEco Studio 打开项目
4. 在 `File → Project Structure → Signing Configs` 中配置签名
5. 点击 `Build → Build HAP(s)` 构建

## 致谢

- 原作网页版：[VanillaNahida/seia-runner](https://github.com/VanillaNahida/seia-runner)
- 原作灵感：[Ottomate 张雪峰跑酷](https://ottomate.games/zxf/)
- 极验验证码：[Geetest](https://www.geetest.com/)

## 许可

本项目仅供学习交流，禁止商业用途。遵循原项目许可协议。

---

欢迎大家克隆并继续优化、开发本项目！如有问题欢迎联系：1156855761@qq.com
