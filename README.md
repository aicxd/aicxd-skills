<div align="center">

**中文** · [English](./README.en.md)

# 🧰 aicxd Skills

#### 我自己每天在用的一些 AI Skill，都开源在这里

[![License](https://img.shields.io/badge/License-MIT-3B82F6?style=for-the-badge)](./LICENSE)
[![Skills](https://img.shields.io/badge/Skills-1-10B981?style=for-the-badge)](#-skills)
[![AgentSkills](https://img.shields.io/badge/AgentSkills-Standard-8B5CF6?style=for-the-badge)](https://agentskills.io)

![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-D97706?style=flat-square&logo=anthropic&logoColor=white)
![Codex](https://img.shields.io/badge/Codex-Skill-10B981?style=flat-square&logo=openai&logoColor=white)
![OpenCode](https://img.shields.io/badge/OpenCode-Skill-3B82F6?style=flat-square)
![OpenClaw](https://img.shields.io/badge/OpenClaw-Skill-8B5CF6?style=flat-square)

</div>

都是在自己项目里跑通了一段时间，确实省事，才搬出来开源的。没什么花活，就是几个挺实用的东西。

这里的每个 Skill 都是 Agent 能直接加载的结构化指令集，遵循 [Agent Skills](https://agentskills.io) 开放标准。Claude Code、Codex、OpenCode、OpenClaw 都能装。

---

## 📋 目录

| 名字 | 一句话 |
|---|---|
| 🛡️ [**claude-ban-guard（封号自检）**](#️-claude-ban-guard封号自检) | 只读扫出 Claude Code 打「中国用户」隐写标记的 3 个信号，逐项给修复步骤 |

---

## 📦 安装方式

在 Claude Code、Codex、OpenClaw 等支持 Skill 的 Agent 里，直接说：

```
帮我安装这个 skill：https://github.com/aicxd/aicxd-skills/tree/main/<skill-name>
```

把 `<skill-name>` 换成你想装的那个，比如 `claude-ban-guard`。Agent 会自己 clone 到对应目录，不用你操心路径。

---

## ✨ Skills

<a id="-skills"></a>

<table>
<tr><td>

### 🛡️ claude-ban-guard（封号自检）

> *"Anthropic 不看 IP，它看的是你机器上 3 个本地信号——时区、BASE_URL、中转站域名。挂代理没用，但改对地方三行设置就够了。"*

Claude Code 自 2.1.91(2026-04-03)起内置了一套**隐写术标记**机制：检测到中国大陆信号后，把系统提示词里 `Today's date is 2026-07-03` 那行的单引号和日期分隔符替换成肉眼无法分辨的 Unicode 变体，服务端解码后做风控处置。

这个 skill 做两件事：**① 只读扫描你是否命中 3 个信号；② 按结果给逐项修复步骤**，标清哪些 Claude 可以代做、哪些你自己手动处理。

**它查什么**

- 🕐 **系统时区** —— Node 读 IANA 时区，是 `Asia/Shanghai` / `Asia/Urumqi` 就命中，挂代理无效
- 🔗 **`ANTHROPIC_BASE_URL`** —— 官方用户根本不设它；设了非官方地址即为信号
- 🌐 **中转站域名** —— 那个地址的域名被拿去和内置 147 个中转站 + 11 个 AI 实验室列表比对（列表 base64 + XOR 混淆）
- 📡 **网络环境一致性** —— 联网查出口 IP 国家，和系统时区/语言交叉比对是否矛盾
- 🖥️ **浏览器加固** —— 浏览器登录 claude.ai 时，WebRTC / 语言是否泄露中国特征

扫完按固定模板输出《Claude / Codex 账号安全自查报告》，每项给 ✅/⚠️/❌ 判定 + 处理方归属（🤖 Claude 代做 / ✋ 手动），诚实说清风险，不打包票。

**怎么触发**

```
会不会被封
封号自检
查下时区有没有暴露
anti-ban
账号安全体检
/claude-ban-guard
```

**🌐 跨平台（Windows 完整实测）**：Claude Code · Codex · OpenCode · OpenClaw

→ [SKILL.md](./claude-ban-guard/SKILL.md) · [封号识别机制详解](./claude-ban-guard/README.md)

</td></tr>
</table>

---

## 🌟 关于

我是创小搭 AI 品牌主理人，一人公司，用 AI 从 0 到 1 搭建所有业务。这些 skill 都是自己每天在用的，开源出来如果对你有帮助，给个 ⭐ 就行。有问题或建议，欢迎在 Issues / Discussions 里说一声。

---

<div align="center">

[MIT License](./LICENSE) · 自由使用 / 修改 / 再分发

Made by [@aicxd](https://github.com/aicxd)

</div>
