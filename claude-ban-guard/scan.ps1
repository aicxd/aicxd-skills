# claude-ban-guard scan.ps1 -- READ-ONLY. Never modifies anything.
# Detects the 3 signals Claude Code uses to steganographically mark Chinese users,
# plus network consistency, browser hardening, and account resilience.
# Usage: pwsh -NoProfile -File scan.ps1 [-ProjectDir <path>]
# Verdict: GREEN=not flagged / YELLOW=human review needed / RED=flagged as Chinese user.

param([string]$ProjectDir = (Get-Location).Path)

function Line($s) { Write-Output $s }

Line "==================== claude-ban-guard self-check (read-only) ===================="
Line ("Time     : " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
Line ("ProjectDir : " + $ProjectDir)
Line ""

# ---------------------------------------------------------------------------
# Signal 1: System timezone (Claude Code runs on Node, reads IANA timezone -- proxy doesn't help)
#   Triggers when: IANA == Asia/Shanghai or Asia/Urumqi
# ---------------------------------------------------------------------------
$iana = $null
try { $iana = (& node -e "process.stdout.write(Intl.DateTimeFormat().resolvedOptions().timeZone)" 2>$null) } catch {}
$winTz = (Get-TimeZone).Id
$tzEnv = if ($env:TZ) { $env:TZ } else { "(not set)" }

if ($iana) {
    $tzFlag = if ($iana -eq "Asia/Shanghai" -or $iana -eq "Asia/Urumqi") { "RED" } else { "GREEN" }
    $ianaShown = $iana
} else {
    $ianaShown = "(node unavailable, can't confirm Claude's actual IANA; falling back to Windows timezone name)"
    $tzFlag = if ($winTz -match "China Standard Time") { "RED(suspected, node missing)" } else { "GREEN(suspected)" }
}

Line "[Signal 1] System Timezone"
Line ("  Claude/Node IANA  : " + $ianaShown)
Line ("  Windows TZ name   : " + $winTz)
Line ("  TZ env var        : " + $tzEnv)
Line ("  Verdict : " + $tzFlag)
Line "  Rule: IANA = Asia/Shanghai or Asia/Urumqi -> RED (date separator changed to slash in prompt)"
Line ""

# ---------------------------------------------------------------------------
# Signal 2 + 3: ANTHROPIC_BASE_URL (env var / settings.json / .env)
#   Official users never set this. Any non-official BASE_URL = flagging signal.
#   Its domain is also compared against 147 relay stations / big-tech / AI labs.
# ---------------------------------------------------------------------------
$baseHits = New-Object System.Collections.ArrayList
function AddBase($src, $val) { if ($val) { [void]$baseHits.Add(@($src, ($val.ToString().Trim()))) } }

AddBase "env:ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL

$settingsPaths = @(
    (Join-Path $env:USERPROFILE ".claude\settings.json"),
    (Join-Path $ProjectDir ".claude\settings.json"),
    (Join-Path $ProjectDir ".claude\settings.local.json")
)
foreach ($p in $settingsPaths) {
    if (Test-Path $p) {
        try {
            $j = Get-Content $p -Raw | ConvertFrom-Json
            if ($j.env -and $j.env.ANTHROPIC_BASE_URL) { AddBase "$p (env block)" $j.env.ANTHROPIC_BASE_URL }
        } catch {}
    }
}

Get-ChildItem -Path $ProjectDir -Filter ".env*" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $f = $_.FullName
    Select-String -Path $f -Pattern '^\s*ANTHROPIC_BASE_URL\s*=\s*(.+)$' -ErrorAction SilentlyContinue | ForEach-Object {
        AddBase ($f + ":" + $_.LineNumber) ($_.Matches[0].Groups[1].Value.Trim('"',"'"," "))
    }
}

Line "[Signal 2+3] ANTHROPIC_BASE_URL / relay domain"
if ($baseHits.Count -eq 0) {
    Line "  ANTHROPIC_BASE_URL not found anywhere (= using official api.anthropic.com)"
    $urlFlag = "GREEN"
} else {
    $nonOfficial = @()
    foreach ($h in $baseHits) {
        $isOfficial = $h[1] -match '^https?://api\.anthropic\.com/?$'
        $mark = if ($isOfficial) { "official (redundant setting, OK)" } else { "non-official -> will be flagged" }
        Line ("  Found: " + $h[0] + " = " + $h[1] + "   [" + $mark + "]")
        if (-not $isOfficial) { $nonOfficial += $h }
    }
    if ($nonOfficial.Count -gt 0) {
        $urlFlag = "RED"
        Line ""
        Line "  Non-official domains (compared against relay/big-tech/AI-lab list):"
        foreach ($h in $nonOfficial) {
            try { $dom = ([Uri]$h[1]).Host } catch { $dom = $h[1] }
            Line ("    - " + $dom)
        }
    } else {
        $urlFlag = "GREEN"
    }
}
Line ("  Verdict : " + $urlFlag)
Line "  Rule: any address other than api.anthropic.com is a signal (official users don't set it)"
Line ""

# ---------------------------------------------------------------------------
# Signal 4: Network environment consistency (account-level risk; separate from steganography)
#   Queries exit IP country online, cross-checks with system timezone/language.
#   DNS leak / WebRTC can't be tested from CLI -- self-check URLs provided.
# ---------------------------------------------------------------------------
Line "[Signal 4] Network environment consistency (account risk, not steganography)"

$exitIp = $null; $exitCountry = $null; $exitOrg = $null
try {
    $r = Invoke-RestMethod -Uri "https://ipinfo.io/json" -TimeoutSec 8 -ErrorAction Stop
    $exitIp = $r.ip; $exitCountry = $r.country; $exitOrg = $r.org
} catch {}

$sysUi = try { (Get-UICulture).Name } catch { "" }
$region = try { (Get-Culture).Name } catch { "" }
$langIsCN = ($sysUi -like "zh-CN*") -or ($region -like "zh-CN*")
$tzIsCN = ($iana -eq "Asia/Shanghai") -or ($iana -eq "Asia/Urumqi") -or ($winTz -match "China Standard Time")

$v6 = @(Get-NetIPAddress -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike 'fe80*' -and $_.IPAddress -ne '::1' })
$hasV6 = $v6.Count -gt 0
$dnsList = @()
try { $dnsList = (Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses | Where-Object { $_ } | Select-Object -Unique } catch {}
$cnDnsPat = '^(114\.114|223\.5\.5\.5|223\.6\.6\.6|119\.29\.29\.29|180\.76\.76\.76|1\.2\.4\.8|210\.2\.4\.8)'
$dnsCN = @($dnsList | Where-Object { $_ -match $cnDnsPat })
$dnsFake = @($dnsList | Where-Object { $_ -match '^198\.1[89]\.' })

if ($exitIp) {
    Line ("  Exit IP         : " + $exitIp)
    Line ("  Exit IP country : " + $exitCountry + "  (" + $exitOrg + ")")
} else {
    Line "  Exit IP         : (query failed -- offline / blocked by local proxy / timeout)"
}
Line ("  System UI lang  : " + $sysUi + " / region " + $region + $(if ($langIsCN) { "  [Chinese trait]" } else { "" }))
Line ("  System timezone : " + $(if ($tzIsCN) { "China mainland trait" } else { "non-China" }))
Line ("  IPv6 global     : " + $(if ($hasV6) { "present -- may leak around proxy if only IPv4 is proxied" } else { "none" }))
$dnsNote = if ($dnsFake.Count -gt 0) { "  [fake-ip mode, proxy owns DNS, usually no leak]" } elseif ($dnsCN.Count -gt 0) { "  [contains CN DNS, possible DNS leak]" } else { "" }
Line ("  DNS servers     : " + $(if ($dnsList) { ($dnsList -join ", ") } else { "(not retrieved)" }) + $dnsNote)

if (-not $exitCountry) {
    $envFlag = "unknown (exit IP unavailable; test manually via URLs below)"
} elseif ($exitCountry -eq "CN") {
    $envFlag = "RED (exit IP is in mainland China, directly visible to account risk engine)"
} elseif ($tzIsCN -or $langIsCN) {
    $envFlag = "YELLOW (exit IP=" + $exitCountry + " non-China, but timezone/language still shows China trait -> inconsistent)"
} else {
    $envFlag = "GREEN (exit IP / timezone / language all point to non-China)"
}
Line ("  Verdict : " + $envFlag)
Line "  >> WebRTC MUST be tested in browser (CLI can't test it, but it can bypass proxy and leak your real CN IP):"
Line "     https://browserleaks.com/webrtc  -- check Public IP for Chinese address"
Line "     To block: Chrome/Edge install 'WebRTC Control' extension; Firefox about:config set media.peerconnection.enabled=false"
Line "     (CLI-only Claude use is not affected by WebRTC; only browser login/account management is)"
Line "  Other manual checks: DNS leak https://dnsleaktest.com | IPv6 https://test-ipv6.com"
Line ""

# ---------------------------------------------------------------------------
# Signal 5: Browser hardening (best-effort; only relevant when logging into claude.ai in browser)
#   CLI-only Claude use is not affected.
#   Can reliably read: browser UI language / accept-languages + hardening launch flags.
#   Cannot read from CLI: WebRTC test / location permission / browser timezone.
# ---------------------------------------------------------------------------
Line "[Signal 5] Browser hardening (best-effort; only relevant for browser login / account management)"

$localData = $env:LOCALAPPDATA
$browsers = @(
    @{ Name='Chrome'; Local="$localData\Google\Chrome\User Data\Local State"; Pref="$localData\Google\Chrome\User Data\Default\Preferences"; Proc='chrome.exe' },
    @{ Name='Edge';   Local="$localData\Microsoft\Edge\User Data\Local State";  Pref="$localData\Microsoft\Edge\User Data\Default\Preferences";  Proc='msedge.exe' }
)

$anyBrowserFound = $false
$browserLocaleCN = $false
$foundWebrtcFlag = $false
$foundLangFlag   = $false

foreach ($b in $browsers) {
    $locale = $null; $accept = $null
    if (Test-Path $b.Local) { $anyBrowserFound = $true; try { $locale = ((Get-Content $b.Local -Raw | ConvertFrom-Json).intl.app_locale) } catch {} }
    if (Test-Path $b.Pref)  { $anyBrowserFound = $true; try { $accept = ((Get-Content $b.Pref  -Raw | ConvertFrom-Json).intl.accept_languages) } catch {} }
    if ($locale -or $accept) {
        $parts = @()
        if ($locale) { $parts += "app_locale=$locale" }
        if ($accept) { $parts += "accept_languages=$accept" }
        $cn = ($locale -like 'zh*') -or ($accept -like 'zh*')
        if ($cn) { $browserLocaleCN = $true }
        Line ("  " + $b.Name + " language : " + ($parts -join "; ") + $(if ($cn) { "  [leading Chinese -> exposes China on browser login]" } else { "" }))
    }
}

$cmdlines = @()
foreach ($b in $browsers) {
    try { Get-CimInstance Win32_Process -Filter "Name='$($b.Proc)'" -ErrorAction SilentlyContinue | ForEach-Object { if ($_.CommandLine) { $cmdlines += $_.CommandLine } } } catch {}
}
$lnkDirs = @(
    [Environment]::GetFolderPath('Desktop'),
    (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'),
    (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'),
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
)
try {
    $wsh = New-Object -ComObject WScript.Shell
    foreach ($d in $lnkDirs) {
        if ($d -and (Test-Path $d)) {
            Get-ChildItem -Path $d -Recurse -Filter *.lnk -ErrorAction SilentlyContinue | ForEach-Object {
                try { $sc = $wsh.CreateShortcut($_.FullName); if ($sc.TargetPath -match 'chrome\.exe$|msedge\.exe$') { $cmdlines += ($sc.TargetPath + " " + $sc.Arguments) } } catch {}
            }
        }
    }
} catch {}
foreach ($c in $cmdlines) {
    if ($c -match '--force-webrtc-ip-handling-policy') { $foundWebrtcFlag = $true }
    if ($c -match '--lang=') { $foundLangFlag = $true }
}
Line ("  WebRTC hardening flag (--force-webrtc-ip-handling-policy) : " + $(if ($foundWebrtcFlag) { "found" } else { "not found (best-effort, absence doesn't confirm missing)" }))
Line ("  Language lock flag (--lang=)                              : " + $(if ($foundLangFlag)   { "found" } else { "not found (best-effort)" }))

if (-not $anyBrowserFound) {
    $browserFlag = "skipped (Chrome/Edge user data not found; CLI-only environment, safe to ignore)"
} elseif ($browserLocaleCN) {
    $browserFlag = "YELLOW (browser UI/accept-language leads with Chinese -> exposes China on login; see SKILL.md browser hardening)"
} else {
    $browserFlag = "manual check needed (best-effort: language not Chinese; WebRTC/location/timezone/IPv6 must be tested in browser)"
}
Line ("  Verdict : " + $browserFlag)
Line "  >> Items CLI can't probe (WebRTC test / location / browser timezone / IPv6) MUST be checked in browser per SKILL.md 'browser hardening'"
Line ""

# ---------------------------------------------------------------------------
# Bonus: Claude Code version (steganography logic present since 2.1.91)
# ---------------------------------------------------------------------------
$ver = $null
try { $ver = (& claude --version 2>$null) } catch {}
if (-not $ver) { $ver = "(claude not in PATH, unknown)" }
Line "[Version] Claude Code"
Line ("  " + $ver)
Line "  Note: steganography logic present since 2.1.91 (2026-04-03); newer version != safe, check signals 1/2"
Line ""

# ---------------------------------------------------------------------------
# Resilience: DeepSeek fallback key (if account is banned, can key calls continue?)
# ---------------------------------------------------------------------------
$dsKey = $false
if ($env:DEEPSEEK_API_KEY) { $dsKey = $true }
Get-ChildItem -Path $ProjectDir -Filter ".env*" -File -ErrorAction SilentlyContinue | ForEach-Object {
    if (Select-String -Path $_.FullName -Pattern '^\s*DEEPSEEK_API_KEY\s*=\s*\S' -Quiet -ErrorAction SilentlyContinue) { $script:dsKey = $true }
}
Line "[Resilience] DeepSeek fallback (Plan B if account is banned)"
Line ("  DEEPSEEK_API_KEY configured : " + $dsKey)
Line ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Line "==================== Summary ===================="
Line ("  Signal 1  System timezone         : " + $tzFlag)
Line ("  Signal 2  ANTHROPIC_BASE_URL      : " + $urlFlag)
Line ("  Signal 4  Network consistency     : " + $envFlag)
Line ("  Signal 5  Browser hardening       : " + $browserFlag)
$stego = ($tzFlag -like "RED*") -or ($urlFlag -like "RED*")
$envBad = ($envFlag -like "RED*") -or ($envFlag -like "YELLOW*")
if ($stego -and $envBad)   { $overall = "Steganography signals + network environment both at risk -> see SKILL.md" }
elseif ($stego)            { $overall = "Steganography marking signals present -> see SKILL.md fix steps" }
elseif ($envBad)           { $overall = "Steganography not triggered, but network environment inconsistent -> see SKILL.md" }
else                       { $overall = "Steganography signals + network environment both on safe side" }
Line ("  Overall : " + $overall)
Line "================================================="
