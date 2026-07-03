<div align="center">

[中文](./README.md) · **English**

# 🧰 aicxd Skills

#### By 创小搭 AI · Tools built while running a one-person company with Claude

[![License](https://img.shields.io/badge/License-MIT-3B82F6?style=for-the-badge)](./LICENSE)
[![Skills](https://img.shields.io/badge/Skills-1-10B981?style=for-the-badge)](#-skills)
[![AgentSkills](https://img.shields.io/badge/AgentSkills-Standard-8B5CF6?style=for-the-badge)](https://agentskills.io)

![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-D97706?style=flat-square&logo=anthropic&logoColor=white)
![Codex](https://img.shields.io/badge/Codex-Skill-10B981?style=flat-square&logo=openai&logoColor=white)
![OpenCode](https://img.shields.io/badge/OpenCode-Skill-3B82F6?style=flat-square)
![OpenClaw](https://img.shields.io/badge/OpenClaw-Skill-8B5CF6?style=flat-square)

</div>

Solo founder running on Claude Code. When I hit a problem that keeps coming back, I write it into a Skill. When it actually holds up, I open-source it.

Each skill is a structured instruction set that Agent platforms can load directly, following the [Agent Skills](https://agentskills.io) open standard. Works with Claude Code, Codex, OpenCode, and OpenClaw.

---

## 📦 Installation

In any Agent that supports Skills (Claude Code, Codex, OpenClaw, etc.), just say:

**🛡️ claude-ban-guard**
```
Help me install this skill: https://github.com/aicxd/aicxd-skills/tree/main/claude-ban-guard
```

---

## ✨ Skills

<a id="-skills"></a>

<table>
<tr><td>

### 🛡️ claude-ban-guard

> *"Anthropic doesn't look at your IP — it looks at 3 local signals on your machine: timezone, BASE_URL, and relay domain. A proxy won't help, but fixing the right three settings will."*

Since Claude Code 2.1.91 (2026-04-03), a **steganographic marking** mechanism is built in: when it detects mainland China signals, it replaces the apostrophe and date separators in the system prompt line `Today's date is 2026-07-03` with visually identical Unicode variants. The server decodes these to apply risk controls.

This skill does two things: **① read-only scan for the 3 signals; ② per-signal fix steps**, clearly labeled whether Claude can handle it or you need to do it manually.

**What it checks**

- 🕐 **System timezone** — Node reads IANA timezone; `Asia/Shanghai` / `Asia/Urumqi` triggers the flag (proxy won't help)
- 🔗 **`ANTHROPIC_BASE_URL`** — official users never set this; any non-official address is a signal
- 🌐 **Relay domain** — that address's domain is compared against 147 known relay stations + 11 Chinese AI lab keywords (list obfuscated with base64 + XOR)
- 📡 **Network consistency** — queries exit IP country online, cross-checks with system timezone/language
- 🖥️ **Browser hardening** — when logging into claude.ai in a browser, whether WebRTC / language leaks Chinese identity

Outputs a structured *Claude / Codex Account Security Report* with ✅/⚠️/❌ per item + who handles it (🤖 Claude can do it / ✋ manual), honest about risk, no guarantees.

**How to trigger**

```
will I get banned
account security check
check if my timezone is exposed
anti-ban
/claude-ban-guard
```

**🌐 Cross-platform (fully tested on Windows)**: Claude Code · Codex · OpenCode · OpenClaw

→ [SKILL.md](./claude-ban-guard/SKILL.md) · [Ban mechanism explained](./claude-ban-guard/README.md)

</td></tr>
</table>

---

## 🌟 About

Solo founder of 创小搭 AI, building everything from 0 to 1 with AI. These are skills I use daily. If they help you, a ⭐ is appreciated. Questions or suggestions welcome in Issues / Discussions.

---

<div align="center">

[MIT License](./LICENSE) · Free to use / modify / redistribute

Made by [@aicxd](https://github.com/aicxd)

</div>
