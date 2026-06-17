
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
Clear-Host

$Banner = @"

╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║   /$$$$$$  /$$$$$$$  /$$    /$$ /$$$$$$$  /$$$$$$ /$$$$$$$$        ║
║  /$$__  $$| $$__  $$| $$   | $$| $$__  $$|_  $$_/|__  $$__/        ║
║ | $$  \__/| $$  \ $$| $$   | $$| $$  \ $$  | $$     | $$           ║
║ | $$      | $$$$$$$/|  $$ / $$/| $$$$$$$/  | $$     | $$           ║
║ | $$      | $$____/  \  $$ $$/ | $$____/   | $$     | $$           ║
║ | $$    $$| $$        \  $$$/  | $$        | $$     | $$           ║
║ |  $$$$$$/| $$         \  $/   | $$       /$$$$$$   | $$           ║
║  \______/ |__/          \_/    |__/      |______/   |__/           ║
║                                                                      ║
║                         ░░░░  CPVP.IT  ░░░░                         ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝

"@

Write-Host $Banner -ForegroundColor Cyan
Write-Host
Write-Host "="*76 -ForegroundColor DarkCyan
Write-Host

Write-Host "Enter path to the mods folder: " -NoNewline
$modsPath = Read-Host "PATH"
Write-Host

if ([string]::IsNullOrWhiteSpace($modsPath)) {
    $modsPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
    Write-Host "Continuing with " -NoNewline
    Write-Host $modsPath -ForegroundColor White
    Write-Host
}

if (-not (Test-Path $modsPath -PathType Container)) {
    Write-Host "ERROR: Invalid Path!" -ForegroundColor Red
    Write-Host "The directory does not exist or is not accessible." -ForegroundColor Yellow
    Write-Host
    Write-Host "Tried to access: $modsPath" -ForegroundColor Gray
    Write-Host
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "Scanning directory: $modsPath" -ForegroundColor Green
Write-Host

$mcProcess = Get-Process javaw -ErrorAction SilentlyContinue
if (-not $mcProcess) {
    $mcProcess = Get-Process java -ErrorAction SilentlyContinue
}

if ($mcProcess) {
    try {
        if ($mcProcess -is [System.Array]) {
            $mcProcess = $mcProcess[0]
        }
        $startTime = $mcProcess.StartTime
        $uptime = (Get-Date) - $startTime
        Write-Host "Minecraft Uptime: $($uptime.Hours)h $($uptime.Minutes)m $($uptime.Seconds)s" -ForegroundColor DarkCyan
        Write-Host
    } catch {}
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$cheatPatterns = @(
    "AutoCrystal", "AutoAnchor", "AutoTotem", "AutoPot", "AutoArmor",
    "InventoryTotem", "HoverTotem", "LegitTotem", "Totem Hit",
    "AutoDoubleHand", "AutoClicker", "AutoMace", "MaceSwap",
    "AnchorTweaks", "AnchorAction", "SafeAnchor", "DoubleAnchor",
    "AntiKB", "NoKnockback", "GrimVelocity", "VelocitySpoof",
    "LagReach", "ReachHack", "LongReach", "HitboxExpand",
    "KillAura", "ClickAura", "MultiAura", "CrystalAura", "AnchorAura",
    "BowAimbot", "BowSpam", "AutoCrit", "CritBypass",
    "ShieldDisabler", "ShieldBreaker", "PreventSwordBlock",
    "AimAssist", "SilentAim", "AimBot", "TriggerBot",
    "FastPlace", "AirPlace", "InstantPlace",
    "FlyHack", "SpeedHack", "BHop", "BunnyHop",
    "NoFall", "StepHack", "WaterWalk", "LiquidWalk",
    "NoSlow", "NoWeb", "Xray", "PlayerESP", "MobESP",
    "ScaffoldWalk", "Nuker", "GhostHand", "NoSwing",
    "FakeLag", "PingSpoof", "PositionSpoof",
    "FastXP", "FastExp", "ElytraSwap", "ElytraSpeed",
    "AutoMine", "AutoCity", "Burrow", "SelfTrap", "HoleFiller",
    "WTap", "TargetStrafe", "AutoGap", "AutoPearl",
    "TimerHack", "GameSpeed", "SpeedTimer",
    "PopSwitch", "FakeNick", "AutoRespawn", "AutoSprint",
    "GrimBypass", "VulcanBypass", "MatrixBypass", "AACBypass", "VerusDisabler",
    "meteordevelopment", "liquidbounce", "novaclient", "intent.store",
    "rise.today", "riseclient", "vape.gg", "vapeclient",
    "meteor-client", "fdp-client", "aristois", "impactclient",
    "walsky.optimizer", "WalksyOptimizer", "WalksyCrystalOptimizerMod",
    "selfdestruct", "LicenseCheckMixin", "phantom-refmap.json",
    "JNativeHook", "imgui.gl3", "imgui.glfw",
    "client-refmap.json", "cheat-refmap.json", "obfuscatedAuth",
    "dev.krypton", "dev/krypton", "skid.krypton", "skid/krypton",
    "dqrkis", "doomsdayclient", "PrestigeClient", "PrestigeClient.vip",
    "gypsy", "Xenon", "GrimClient", "VirginClient",
    "catlean", "CatleanClient", "ArgonClient", "Asteria",
    "AntiMissClick", "PackSpoof", "AntiBot", "ChestStealer",
    "JumpReset", "AxeSpam", "WebMacro", "AutoWeb", "AntiWeb",
    "Donut", "Replace Mod", "StunSlam", "SpearSwap",
    "BaseFinder", "InvSee", "ItemExploit", "FreezePlayer", "VirtualMachine",
    "Freecam", "No Clip", "Fake Punch", "Loot Yeeter", "KeyPearl",
    "AutoFirework", "AutoBreach", "AutoSwitchBack", "CheckLineOfSight",
    "OnlyWhenFalling", "RequireCrit", "StopOnKill", "StopOnCrystal",
    "CheckShield", "OnPop", "PredictDamage", "OnGround", "CheckPlayers",
    "PredictCrystals", "CheckAim", "CheckItems", "ActivatesAbove",
    "Blatant", "ForceTotem", "StayOpenFor", "AutoInventoryTotem",
    "OnlyOnPop", "VerticalSpeed", "HoverTotem", "SwapSpeed",
    "StrictOneTick", "MacePriority", "MinTotems", "MinPearls",
    "TotemFirst", "DropInterval", "RandomPattern", "HorizontalAimSpeed",
    "VerticalAimSpeed", "IncludeHead", "WebDelay", "HoldingWeb",
    "NotWhenAffectsPlayer", "HitDelay", "SwitchBack", "RequireHoldAxe",
    "org.chainlibs", "net.minecraft.injection"
)

Write-Host "Loading signature database ($($cheatPatterns.Count) patterns)" -ForegroundColor Cyan
Write-Host

function Get-FileSHA1 {
    param([string]$Path)
    return (Get-FileHash -Path $Path -Algorithm SHA1).Hash
}

function Get-DownloadSource {
    param([string]$Path)
    $zoneData = Get-Content -Raw -Stream Zone.Identifier $Path -ErrorAction SilentlyContinue
    if ($zoneData -match "HostUrl=(.+)") {
        $url = $matches[1].Trim()
        if ($url -match "mediafire\.com") { return "MediaFire" }
        elseif ($url -match "discord\.com|discordapp\.com|cdn\.discordapp\.com") { return "Discord" }
        elseif ($url -match "dropbox\.com") { return "Dropbox" }
        elseif ($url -match "drive\.google\.com") { return "Google Drive" }
        elseif ($url -match "mega\.nz|mega\.co\.nz") { return "MEGA" }
        elseif ($url -match "github\.com") { return "GitHub" }
        elseif ($url -match "modrinth\.com") { return "Modrinth" }
        elseif ($url -match "curseforge\.com") { return "CurseForge" }
        else {
            if ($url -match "https?://(?:www\.)?([^/]+)") { return $matches[1] }
            return $url
        }
    }
    return $null
}

function Query-Modrinth {
    param([string]$Hash)
    try {
        $versionInfo = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/version_file/$Hash" -Method Get -UseBasicParsing -ErrorAction Stop
        if ($versionInfo.project_id) {
            $projectInfo = Invoke-RestMethod -Uri "https://api.modrinth.com/v2/project/$($versionInfo.project_id)" -Method Get -UseBasicParsing -ErrorAction Stop
            return @{Name = $projectInfo.title; Slug = $projectInfo.slug; Found = $true}
        }
    } catch {}
    return @{Name = ""; Slug = ""; Found = $false}
}

function Send-DiscordWebhook {
    param([string]$WebhookUrl, [string]$Title, [string]$Color, [string]$Description, [array]$Fields)
    
    $payload = @{
        username = "CPVP.IT Scanner"
        avatar_url = "https://raw.githubusercontent.com/CpvPScanners/CPVPScanner/main/icon.png"
        embeds = @(
            @{
                title = $Title
                color = $Color
                description = $Description
                fields = $Fields
                timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                footer = @{text = "CPVP.IT"}
            }
        )
    }
    
    try {
        $jsonPayload = $payload | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $jsonPayload -ContentType "application/json" -UseBasicParsing | Out-Null
        return $true
    } catch {
        return $false
    }
}

Write-Host "Searching for JAR files..." -ForegroundColor Cyan
$jars = Get-ChildItem -Path $modsPath -Filter "*.jar" -Recurse -File
$total = $jars.Count
Write-Host "Found $total JAR files to scan`n" -ForegroundColor Green

$results = @{
    Cheats = @()
    Suspicious = @()
    Clean = @()
    Errors = @()
}

$current = 0
foreach ($jar in $jars) {
    $current++
    $filename = $jar.Name
    
    $foundMatches = @()
    $verdict = "Clean"
    
    try {
        $sha1 = Get-FileSHA1 -Path $jar.FullName
        $downloadSource = Get-DownloadSource -Path $jar.FullName
        $modrinthResult = Query-Modrinth -Hash $sha1
        
        $filenameLower = $filename.ToLower()
        foreach ($pat in $cheatPatterns) {
            $patLower = $pat.ToLower()
            if ($filenameLower.Contains($patLower) -and $patLower.Length -gt 3) {
                if (-not $foundMatches.Contains($pat)) { $foundMatches += $pat }
            }
        }
        
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
        foreach ($entry in $zip.Entries) {
            $entryLower = $entry.FullName.ToLower()
            foreach ($pat in $cheatPatterns) {
                $patLower = $pat.ToLower()
                if ($entryLower.Contains($patLower) -and $patLower.Length -gt 3) {
                    if (-not $foundMatches.Contains($pat)) { $foundMatches += $pat }
                }
            }
            
            if ($entry.Name -match '\.class$' -and $entry.Length -gt 0) {
                $stream = $entry.Open()
                $reader = New-Object System.IO.StreamReader($stream)
                $content = $reader.ReadToEnd()
                $reader.Close()
                $stream.Close()
                
                foreach ($pat in $cheatPatterns) {
                    if ($content.Contains($pat)) {
                        if (-not $foundMatches.Contains($pat)) { $foundMatches += $pat }
                    }
                }
                
                if ($foundMatches.Count -gt 5) { break }
            }
        }
        $zip.Dispose()
        
        if ($modrinthResult.Found) {
            Write-Host "[$current/$total] [$filename]" -NoNewline
            Write-Host " [MODRINTH VERIFIED: $($modrinthResult.Name)]" -ForegroundColor Green
        } else {
            Write-Host "[$current/$total] [$filename]" -NoNewline
        }
        
        if ($foundMatches.Count -gt 3) {
            $verdict = "CHEAT"
            Write-Host " - " -NoNewline
            Write-Host "CHEAT DETECTED" -ForegroundColor Red -NoNewline
            Write-Host " ($($foundMatches.Count) matches)"
            $results.Cheats += @{File = $filename; Matches = $foundMatches; SHA1 = $sha1; Source = $downloadSource; Modrinth = $modrinthResult}
        } elseif ($foundMatches.Count -gt 0) {
            $verdict = "SUSPICIOUS"
            Write-Host " - " -NoNewline
            Write-Host "SUSPICIOUS" -ForegroundColor Yellow -NoNewline
            Write-Host " ($($foundMatches.Count) matches)"
            $results.Suspicious += @{File = $filename; Matches = $foundMatches; SHA1 = $sha1; Source = $downloadSource; Modrinth = $modrinthResult}
        } else {
            Write-Host " - " -NoNewline
            Write-Host "CLEAN" -ForegroundColor Green
            $results.Clean += @{File = $filename; SHA1 = $sha1; Source = $downloadSource; Modrinth = $modrinthResult}
        }
        
    } catch {
        Write-Host "[$current/$total] [$filename]" -NoNewline
        Write-Host " - ERROR" -ForegroundColor Red
        $results.Errors += @{File = $filename; Error = $_.Exception.Message}
    }
}

Write-Host
Write-Host "="*70 -ForegroundColor DarkCyan
Write-Host "  SCAN COMPLETE" -ForegroundColor Green
Write-Host "="*70 -ForegroundColor DarkCyan
Write-Host
Write-Host "Total: $total" -ForegroundColor White
Write-Host "Cheats: $($results.Cheats.Count)" -ForegroundColor Red
Write-Host "Suspicious: $($results.Suspicious.Count)" -ForegroundColor Yellow
Write-Host "Clean: $($results.Clean.Count)" -ForegroundColor Green
Write-Host "Errors: $($results.Errors.Count)" -ForegroundColor DarkGray
Write-Host

$WEBHOOK_LEGIT = "https://discord.com/api/webhooks/1516894842129481748/R_3BabH2lLdMc_2wKiaOTy9v0TGfcfM0oKmBItpLAL0sfMOuM8Uzs-qsUXXiHyTwMTCG"
$WEBHOOK_SUSPICIOUS = "https://discord.com/api/webhooks/1516894904083546126/ITKUS6FElobBzbemEh6-KUPNY1Fac86e2Ivle-qEx9eV-5sMEtYzTdH_5PsGLNTrj4bQ"
$WEBHOOK_CHEAT = "https://discord.com/api/webhooks/1516894976296882341/BY_8YykAlNsoBuhZ7bS89zH74D6diQ8IxuOE7fX0Rwf3PiqyoE-zziGe0l9v2vhhW0It"

$fields = @(
    @{name = "📂 Directory"; value = "`"$modsPath`""; inline = $true},
    @{name = "📊 Total"; value = "`"$total`""; inline = $true},
    @{name = "🚫 Cheats"; value = "`"$($results.Cheats.Count)`""; inline = $true},
    @{name = "⚠️ Suspicious"; value = "`"$($results.Suspicious.Count)`""; inline = $true},
    @{name = "✅ Clean"; value = "`"$($results.Clean.Count)`""; inline = $true}
)

if ($results.Cheats.Count -gt 0) {
    $cheatList = $results.Cheats | ForEach-Object {
        "- $($_.File) ($($_.Matches.Count) matches)"
    }
    $fields += @{name = "🚫 Cheats Found"; value = ($cheatList -join "`n"); inline = $false}
    Send-DiscordWebhook -WebhookUrl $WEBHOOK_CHEAT -Title "🚨 CHEATS DETECTED!" -Color "16711680" -Description "Found suspicious mods in the scanned directory" -Fields $fields
}

if ($results.Suspicious.Count -gt 0) {
    $suspiciousList = $results.Suspicious | ForEach-Object {
        "- $($_.File) ($($_.Matches.Count) matches)"
    }
    $fields += @{name = "⚠️ Suspicious Mods"; value = ($suspiciousList -join "`n"); inline = $false}
    Send-DiscordWebhook -WebhookUrl $WEBHOOK_SUSPICIOUS -Title "⚠️ Suspicious Mods Found" -Color "16776960" -Description "Found potentially suspicious mods" -Fields $fields
}

Send-DiscordWebhook -WebhookUrl $WEBHOOK_LEGIT -Title "✅ Scan Complete" -Color "65280" -Description "Scan completed successfully" -Fields $fields

Write-Host "📤 Webhook sent!" -ForegroundColor Green
Write-Host

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
