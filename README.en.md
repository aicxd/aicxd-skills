<div align="center">

[中文](./README.md) · **English**

# 创小搭 AI Skills

**Practical tools built while running a one-person company with AI**

[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](./LICENSE)
[![Skills](https://img.shields.io/badge/skills-1-blue?style=flat-square)](#️-skills)
[![Platform](https://img.shields.io/badge/platform-Claude_Code_%7C_Codex_%7C_OpenCode-orange?style=flat-square)](#-installation)

</div>

---

Solo founder running daily operations on Claude Code. When the same problem blocks me twice, I write the fix into a Skill. When it holds up, I open-source it.

Each Skill is a structured instruction set that Agent platforms can load directly, following the [AgentSkills](https://agentskills.io) open standard.

---

## 🗂️ Directory

| Skill | What it does |
|---|---|
| 🛡️ [**claude-ban-guard**](#️-claude-ban-guard) | Generates a Claude / Codex account security environment report — checks 6 dimensions (timezone, proxy, network, browser) and gives ✅/⚠️/❌ verdicts with fix steps |

---

## 🔧 Installation

In any Agent that supports Skills (Claude Code / Codex / OpenCode, etc.), just say:

**🛡️ claude-ban-guard**
```
Help me install this skill: https://github.com/aicxd/aicxd-skills/tree/main/claude-ban-guard
```

---

## 🛠️ Skills

<a id="️-skills"></a>

<table>
<tr><td>

### 🛡️ claude-ban-guard

> *"Getting banned isn't random. Anthropic embedded a signal detection layer in Claude Code that decides how to flag you before your request even goes out. This Skill maps out your own machine's risk profile."*

**What it is**

A read-only account security environment scanner. When triggered, it runs `scan.ps1` against the local machine and produces a structured *Claude / Codex Account Security Report* — surfacing every signal that could cause Anthropic to flag your environment as mainland China, with verdicts and fix steps for each.

**Background: Claude Code's steganographic marking**

Since version 2.1.91 (2026-04-03), Claude Code detects 3 local signals and — when triggered — replaces the apostrophe and date separator in the `Today's date is …` system prompt line with visually identical Unicode variants. The server decodes this mark for risk controls. **It doesn't check your IP.** A proxy won't help.

**The report covers 6 dimensions**

| # | Check | What's examined |
|---|---|---|
| 1 | System timezone | Whether Node's IANA timezone is `Asia/Shanghai` / `Asia/Urumqi` |
| 2 | `ANTHROPIC_BASE_URL` | Whether a non-official address is set in env var / settings.json / .env |
| 3 | Relay domain | Whether that address's domain matches the built-in list of 147 relays + 11 AI labs |
| 4 | Network consistency | Whether exit IP country conflicts with system timezone / language |
| 5 | Browser hardening | Whether language / WebRTC leaks Chinese identity when logging into claude.ai |
| 6 | Account resilience | Whether a DeepSeek fallback key is in place so critical calls survive a ban |

**Report format**

Each item gets a ✅ / ⚠️ / ❌ verdict, labeled with 🤖 Claude can handle it or ✋ manual action needed. Honest about risk — no guarantees.

**How to trigger**

```
account security check
will I get banned
check if my timezone is exposed
/claude-ban-guard
```

**🖥️ Fully tested on Windows, works on macOS (requires pwsh)**

→ [SKILL.md](./claude-ban-guard/SKILL.md) · [Ban mechanism explained](./claude-ban-guard/README.md)

</td></tr>
</table>

---

## 👤 About

Founder of 创小搭 AI, one-person company. These are tools I actually use. If they help you, a ⭐ is appreciated. Questions or suggestions — open an Issue.

<div align="center">

[MIT License](./LICENSE) · Free to use / modify / redistribute · Made by [@aicxd](https://github.com/aicxd)

</div>
