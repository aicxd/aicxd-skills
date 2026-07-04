<div align="center">

**中文** · [English](./README.en.md)

# 创小搭 AI Skills

**一人公司实战工具集 · 用 AI 跑业务时顺手写下来的**

[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](./LICENSE)
[![Skills](https://img.shields.io/badge/skills-1-blue?style=flat-square)](#️-skills)
[![Platform](https://img.shields.io/badge/platform-Claude_Code_%7C_Codex_%7C_OpenCode-orange?style=flat-square)](#-安装方式)

</div>

---

一人公司，靠 Claude Code 跑日常业务。每次被同一个问题卡住超过两次，就把解法写成 Skill。跑稳了就开源出来。

每个 Skill 都是可直接加载的结构化指令集，遵循 [AgentSkills](https://agentskills.io) 开放标准。

---

## 🗂️ 目录

| Skill | 干嘛的 |
|---|---|
| 🛡️ [**claude-ban-guard**](#️-claude-ban-guard) | 生成 Claude / Codex 系统环境自查报告，覆盖时区、代理、网络、浏览器 6 个维度，逐项 ✅/⚠️/❌ 判定 + 调整指引 |

---

## 🔧 安装方式

在支持 Skill 的 Agent（Claude Code / Codex / OpenCode 等）里直接说：

**🛡️ claude-ban-guard**
```
帮我安装这个 skill：https://github.com/aicxd/aicxd-skills/tree/main/claude-ban-guard
```

---

## 🛠️ Skills

<a id="️-skills"></a>

<table>
<tr><td>

### 🛡️ claude-ban-guard

> *"Anthropic 在 Claude Code 本地内置了一套环境信号采集逻辑，请求发出前就已完成用户环境判断。这个 Skill 扫出本机当前命中哪些信号，逐项标注并给出调整步骤。"*

**它是什么**

一个只读的系统环境自查工具。触发后跑 `scan.ps1` 扫描本机，生成一份结构化的《Claude / Codex 系统环境自查报告》，把你当前环境里所有被 Anthropic 用于识别用户环境的信号全部列出来，逐项给出判定和调整方案。

**背景：Claude Code 的隐写标记机制**

自 2.1.91（2026-04-03）起，Claude Code 会在本地检测 3 个信号，命中后把系统提示词里 `Today's date is …` 这行的单引号和日期分隔符替换成肉眼无法区分的 Unicode 变体。服务端解码这个标记做风控处置。**这一层不靠 IP 采集**，只看 3 个本地信号。

**自查报告覆盖 6 个维度**

| # | 检查项 | 查什么 |
|---|---|---|
| 1 | 系统时区 | Node 读到的 IANA 时区是否为 `Asia/Shanghai` / `Asia/Urumqi` |
| 2 | `ANTHROPIC_BASE_URL` | 环境变量 / settings.json / .env 三处是否设了非官方地址 |
| 3 | 中转站域名 | 那个地址的域名是否命中内置 147 个中转站 + 11 个 AI 实验室列表 |
| 4 | 网络环境一致性 | 出口 IP 国家与系统时区 / 语言是否矛盾 |
| 5 | 浏览器加固 | 浏览器登录 claude.ai 时，语言 / WebRTC 是否泄露中国特征 |
| 6 | 账号韧性 | DeepSeek 兜底 Key 是否就位，主要调用链路是否有备用方案 |

**报告格式**

每项给 ✅ / ⚠️ / ❌ 判定，并标明 🤖 Claude 可代处理 还是 ✋ 需你手动，如实报告当前信号状态。

**怎么触发**

```
系统环境检测
查下本机 Claude 配置
查下时区/BASE_URL 有没有暴露
/claude-ban-guard
```

**🖥️ Windows 完整实测，macOS 可用（scan.ps1 需 pwsh）**

→ [SKILL.md](./claude-ban-guard/SKILL.md) · [隐写标记机制详解](./claude-ban-guard/README.md)

</td></tr>
</table>

---

## 👤 关于

创小搭 AI 品牌主理人，一人公司。这些工具是自己在用的，开源出来如果对你有帮助，给个 ⭐ 就行。有问题或建议欢迎开 Issue。

<div align="center">

[MIT License](./LICENSE) · 自由使用 / 修改 / 再分发 · Made by [@aicxd](https://github.com/aicxd)

</div>
