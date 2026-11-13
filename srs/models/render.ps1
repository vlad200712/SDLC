<#
.SYNOPSIS
    Отрисовка моделей SysMLv2 из папки srs/models в PNG (папка srs/images).
.DESCRIPTION
    Запуск из корня репозитория:
        powershell -ExecutionPolicy Bypass -File srs/models/render.ps1
    Использует встроенную библиотеку .NET System.Drawing без сторонних зависимостей.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutDir = Join-Path (Split-Path -Parent $BaseDir) "images"
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

# Палитра оформления макетов
$C_BG       = [System.Drawing.Color]::FromArgb(255, 255, 255)
$C_TITLE    = [System.Drawing.Color]::FromArgb(30, 64, 175)
$C_CTX_HDR  = [System.Drawing.Color]::FromArgb(52, 58, 70)
$C_GOLD     = [System.Drawing.Color]::FromArgb(253, 224, 71)
$C_INK      = [System.Drawing.Color]::FromArgb(33, 37, 41)
$C_MUTED    = [System.Drawing.Color]::FromArgb(100, 116, 139)
$C_LINE     = [System.Drawing.Color]::FromArgb(148, 163, 184)
$C_PANEL    = [System.Drawing.Color]::FromArgb(248, 250, 252)
$C_PRIMARY  = [System.Drawing.Color]::FromArgb(37, 99, 235)
$C_SUCCESS  = [System.Drawing.Color]::FromArgb(22, 163, 74)
$C_SUCCESS_BG = [System.Drawing.Color]::FromArgb(236, 253, 245)
$C_DANGER   = [System.Drawing.Color]::FromArgb(220, 38, 38)
$C_DANGER_BG = [System.Drawing.Color]::FromArgb(254, 242, 242)
$C_WARN     = [System.Drawing.Color]::FromArgb(217, 119, 6)
$C_WARN_BG  = [System.Drawing.Color]::FromArgb(255, 251, 235)
$C_INFO_BG  = [System.Drawing.Color]::FromArgb(239, 246, 255)
$C_PURPLE   = [System.Drawing.Color]::FromArgb(190, 24, 93)
$C_PURPLE_BG = [System.Drawing.Color]::FromArgb(253, 242, 248)
$C_EXT_BG   = [System.Drawing.Color]::FromArgb(241, 245, 249)
$C_DISABLED = [System.Drawing.Color]::FromArgb(226, 232, 240)

function Parse-SysmlModel {
    param([string]$FilePath)

    $text = Get-Content -Path $FilePath -Raw -Encoding UTF8
    # Удаление однострочных комментариев
    $lines = $text -split "`r?`n"
    $cleanLines = foreach ($ln in $lines) {
        $idx = $ln.IndexOf("//")
        if ($idx -ge 0) { $ln.Substring(0, $idx) } else { $ln }
    }
    $clean = ($cleanLines -join "`n")

    $rootNodes = New-Object System.Collections.ArrayList
    $connections = New-Object System.Collections.ArrayList
    $stack = New-Object System.Collections.Stack

    $i = 0
    $len = $clean.Length

    # Токенизация на строки и блоки { }
    $tokens = New-Object System.Collections.ArrayList
    $sb = New-Object System.Text.StringBuilder
    $inStr = $false
    while ($i -lt $len) {
        $ch = $clean[$i]
        if ($ch -eq '"') {
            $inStr = -not $inStr
            [void]$sb.Append($ch)
        } elseif (-not $inStr -and ($ch -eq '{' -or $ch -eq '}' -or $ch -eq ';')) {
            $buf = $sb.ToString().Trim()
            if ($buf.Length -gt 0) { [void]$tokens.Add($buf) }
            $sb.Clear() | Out-Null
            [void]$tokens.Add([string]$ch)
        } else {
            [void]$sb.Append($ch)
        }
        $i++
    }

    $tIdx = 0
    while ($tIdx -lt $tokens.Count) {
        $tok = $tokens[$tIdx]
        if ($tok -eq '}') {
            if ($stack.Count -gt 0) { [void]$stack.Pop() }
            $tIdx++
            continue
        }
        if ($tok -eq '{' -or $tok -eq ';') {
            $tIdx++
            continue
        }

        if ($tok -match '^package\s+(\w+)$') {
            $next = if ($tIdx + 1 -lt $tokens.Count) { $tokens[$tIdx + 1] } else { "" }
            if ($next -eq '{') {
                $pkgNode = @{ Kind = "package"; Name = $Matches[1]; Children = (New-Object System.Collections.ArrayList); Attrs = @{} }
                $stack.Push($pkgNode)
                $tIdx += 2
                continue
            }
        }

        if ($tok -match '^part\s+(\w+)\s*:\s*(\w+)$') {
            $pName = $Matches[1]
            $pType = $Matches[2]
            $node = @{
                Kind = "part"
                Name = $pName
                Type = $pType
                Attrs = @{ posX = 0; posY = 0; width = 0; height = 0; caption = ""; subcaption = ""; tone = ""; progress = 0; steps = "" }
                Children = (New-Object System.Collections.ArrayList)
            }
            if ($stack.Count -gt 0) {
                $parent = $stack.Peek()
                if ($parent.Kind -eq "part") {
                    [void]$parent.Children.Add($node)
                } else {
                    [void]$rootNodes.Add($node)
                }
            } else {
                [void]$rootNodes.Add($node)
            }
            $next = if ($tIdx + 1 -lt $tokens.Count) { $tokens[$tIdx + 1] } else { "" }
            if ($next -eq '{') {
                $stack.Push($node)
                $tIdx += 2
                continue
            }
        }
        elseif ($tok -match '^connection\s+(\w+)\s*:\s*\w+\s+connect\s+([\w\.]+)\s+to\s+([\w\.]+)$') {
            $conn = @{
                Name = $Matches[1]
                From = $Matches[2]
                To   = $Matches[3]
                Caption = ""
            }
            [void]$connections.Add($conn)
            $next = if ($tIdx + 1 -lt $tokens.Count) { $tokens[$tIdx + 1] } else { "" }
            if ($next -eq '{') {
                $connNode = @{ Kind = "connection"; Conn = $conn }
                $stack.Push($connNode)
                $tIdx += 2
                continue
            }
        }
        elseif ($tok -match '^attribute\s+:>>\s*(\w+)\s*=\s*(.+)$') {
            $attrName = $Matches[1]
            $rawVal = $Matches[2].Trim()
            if ($rawVal.StartsWith('"') -and $rawVal.EndsWith('"')) {
                $val = $rawVal.Substring(1, $rawVal.Length - 2).Replace('\n', "`n")
            } elseif ($rawVal -match '^-?\d+$') {
                $val = [int]$rawVal
            } else {
                $val = $rawVal
            }
            if ($stack.Count -gt 0) {
                $top = $stack.Peek()
                if ($top.Kind -eq "part") {
                    $top.Attrs[$attrName] = $val
                } elseif ($top.Kind -eq "connection" -and $attrName -eq "caption") {
                    $top.Conn.Caption = [string]$val
                }
            }
        }

        $tIdx++
    }

    return @{ Roots = $rootNodes; Connections = $connections }
}

function Draw-RoundedRect {
    param(
        [System.Drawing.Graphics]$G,
        [float]$X, [float]$Y, [float]$W, [float]$H, [float]$Radius,
        [System.Drawing.Brush]$FillBrush = $null,
        [System.Drawing.Pen]$BorderPen = $null
    )
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $Radius * 2
    if ($d -gt $W) { $d = $W }
    if ($d -gt $H) { $d = $H }
    if ($d -le 0) {
        $path.AddRectangle([System.Drawing.RectangleF]::new($X, $Y, $W, $H))
    } else {
        $path.AddArc($X, $Y, $d, $d, 180, 90)
        $path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
        $path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
        $path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
        $path.CloseFigure()
    }
    if ($null -ne $FillBrush) { $G.FillPath($FillBrush, $path) }
    if ($null -ne $BorderPen) { $G.DrawPath($BorderPen, $path) }
    $path.Dispose()
}

function Render-ContextDiagram {
    param($Model, [string]$OutPath)

    $screen = $Model.Roots[0]
    $W = [int]$screen.Attrs.width
    $H = [int]$screen.Attrs.height

    $bmp = New-Object System.Drawing.Bitmap($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear($C_BG)

    $fHdr   = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $fStamp = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $fStereo = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $fTitle = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    $fSub   = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
    $fActor = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
    $fLink  = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)

    $bHdr = New-Object System.Drawing.SolidBrush($C_CTX_HDR)
    $bWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $bGold = New-Object System.Drawing.SolidBrush($C_GOLD)
    $bInk = New-Object System.Drawing.SolidBrush($C_INK)
    $bMuted = New-Object System.Drawing.SolidBrush($C_MUTED)
    $bPanel = New-Object System.Drawing.SolidBrush($C_PANEL)
    $bExt = New-Object System.Drawing.SolidBrush($C_EXT_BG)

    $pBox = New-Object System.Drawing.Pen($C_INK, 1.8)
    $pLink = New-Object System.Drawing.Pen($C_INK, 1.5)

    # Верхний заголовок
    $g.FillRectangle($bHdr, 0, 0, $W, 44)
    $g.DrawString([string]$screen.Attrs.caption, $fHdr, $bWhite, 16, 10)
    $sfRight = New-Object System.Drawing.StringFormat
    $sfRight.Alignment = [System.Drawing.StringAlignment]::Far
    $g.DrawString("Макет, не итоговый вид", $fStamp, $bGold, ($W - 16), 13, $sfRight)

    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center

    $boundsMap = @{}

    # Сбор координат всех элементов
    function Collect-Blocks {
        param($Node, [int]$OffX, [int]$OffY, [string]$Prefix)
        foreach ($ch in $Node.Children) {
            $ax = $OffX + [int]$ch.Attrs.posX
            $ay = $OffY + [int]$ch.Attrs.posY
            $key = if ($Prefix -eq "") { $ch.Name } else { "$Prefix.$($ch.Name)" }
            if ($ch.Type -eq "Actor") {
                $boundsMap[$key] = @{ Kind = "Actor"; X = $ax; Y = $ay; W = 70; H = 110; CX = $ax; CY = $ay + 45; Node = $ch }
            } else {
                $cw = [int]$ch.Attrs.width
                $chh = [int]$ch.Attrs.height
                $boundsMap[$key] = @{ Kind = "Block"; X = $ax; Y = $ay; W = $cw; H = $chh; CX = $ax + ($cw / 2); CY = $ay + ($chh / 2); Node = $ch }
                Collect-Blocks -Node $ch -OffX $ax -OffY $ay -Prefix $key
            }
        }
    }
    Collect-Blocks -Node $screen -OffX 0 -OffY 0 -Prefix ""

    # Сначала рисуем родительские/контейнерные блоки (содержащие Children), затем вложенные
    foreach ($entry in $boundsMap.Values) {
        if ($entry.Kind -eq "Block" -and $entry.Node.Children.Count -gt 0) {
            $g.FillRectangle($bPanel, $entry.X, $entry.Y, $entry.W, $entry.H)
            $g.DrawRectangle($pBox, $entry.X, $entry.Y, $entry.W, $entry.H)
            $g.DrawString("«система»", $fStereo, $bMuted, $entry.CX, $entry.Y + 14, $sfCenter)
            $g.DrawString([string]$entry.Node.Attrs.caption, $fTitle, $bInk, $entry.CX, $entry.Y + 34, $sfCenter)
        }
    }

    # Связи (до рисования внутренних блоков, чтобы линии шли к границам аккуратно)
    foreach ($conn in $Model.Connections) {
        $a = $boundsMap[$conn.From]
        $b = $boundsMap[$conn.To]
        if ($null -eq $a -or $null -eq $b) { continue }

        $x1 = [float]$a.CX; $y1 = [float]$a.CY
        $x2 = [float]$b.CX; $y2 = [float]$b.CY

        if ($a.Kind -eq "Actor") {
            $x1 = [float]($a.X + 35)
            $y1 = [float]($a.Y + 45)
        }
        $g.DrawLine($pLink, $x1, $y1, $x2, $y2)

        if ($conn.Caption -ne "") {
            $mx = ($x1 + $x2) / 2
            $my = ($y1 + $y2) / 2
            $sz = $g.MeasureString($conn.Caption, $fLink)
            $g.FillRectangle($bWhite, $mx - ($sz.Width / 2) - 4, $my - ($sz.Height / 2) - 2, $sz.Width + 8, $sz.Height + 4)
            $g.DrawString($conn.Caption, $fLink, $bInk, $mx, $my - ($sz.Height / 2), $sfCenter)
        }
    }

    # Листовые блоки и акторы
    foreach ($entry in $boundsMap.Values) {
        if ($entry.Kind -eq "Actor") {
            $cx = $entry.X
            $cy = $entry.Y
            $g.FillEllipse($bWhite, $cx - 14, $cy, 28, 28)
            $g.DrawEllipse($pBox, $cx - 14, $cy, 28, 28)
            $g.DrawLine($pBox, $cx, $cy + 28, $cx, $cy + 66)
            $g.DrawLine($pBox, $cx - 22, $cy + 40, $cx + 22, $cy + 40)
            $g.DrawLine($pBox, $cx, $cy + 66, $cx - 18, $cy + 94)
            $g.DrawLine($pBox, $cx, $cy + 66, $cx + 18, $cy + 94)
            $g.DrawString([string]$entry.Node.Attrs.caption, $fActor, $bInk, $cx, $cy + 100, $sfCenter)
        } elseif ($entry.Node.Children.Count -eq 0) {
            $isExt = ($entry.Node.Attrs.tone -eq "external")
            $fill = if ($isExt) { $bExt } else { $bWhite }
            $stereo = if ($isExt) { "«внешний элемент»" } else { "«часть»" }
            $g.FillRectangle($fill, $entry.X, $entry.Y, $entry.W, $entry.H)
            $g.DrawRectangle($pBox, $entry.X, $entry.Y, $entry.W, $entry.H)

            $sub = [string]$entry.Node.Attrs.subcaption
            if ($sub -ne "") {
                $g.DrawString($stereo, $fStereo, $bMuted, $entry.CX, $entry.Y + 24, $sfCenter)
                $g.DrawString([string]$entry.Node.Attrs.caption, $fTitle, $bInk, $entry.CX, $entry.Y + 48, $sfCenter)
                $g.DrawString($sub, $fSub, $bMuted, $entry.CX, $entry.Y + 76, $sfCenter)
            } else {
                $g.DrawString($stereo, $fStereo, $bMuted, $entry.CX, $entry.Y + 34, $sfCenter)
                $g.DrawString([string]$entry.Node.Attrs.caption, $fTitle, $bInk, $entry.CX, $entry.Y + 58, $sfCenter)
            }
        }
    }

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

function Render-UiScreen {
    param($Model, [string]$OutPath)

    $screen = $Model.Roots[0]
    $W = [int]$screen.Attrs.width
    $H = [int]$screen.Attrs.height

    $bmp = New-Object System.Drawing.Bitmap($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear($C_BG)

    $fHdr     = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $fStamp   = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $fHeading = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $fBody    = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $fBold    = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fSmall   = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $fMono    = New-Object System.Drawing.Font("Consolas", 9.5, [System.Drawing.FontStyle]::Regular)

    $bTitleBar = New-Object System.Drawing.SolidBrush($C_TITLE)
    $bWhite    = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $bGold     = New-Object System.Drawing.SolidBrush($C_GOLD)
    $bInk      = New-Object System.Drawing.SolidBrush($C_INK)
    $bMuted    = New-Object System.Drawing.SolidBrush($C_MUTED)
    $bPanel    = New-Object System.Drawing.SolidBrush($C_PANEL)
    $bPrimary  = New-Object System.Drawing.SolidBrush($C_PRIMARY)
    $bSuccess  = New-Object System.Drawing.SolidBrush($C_SUCCESS)
    $bSuccessBg = New-Object System.Drawing.SolidBrush($C_SUCCESS_BG)
    $bDanger   = New-Object System.Drawing.SolidBrush($C_DANGER)
    $bDangerBg = New-Object System.Drawing.SolidBrush($C_DANGER_BG)
    $bWarn     = New-Object System.Drawing.SolidBrush($C_WARN)
    $bWarnBg   = New-Object System.Drawing.SolidBrush($C_WARN_BG)
    $bInfoBg   = New-Object System.Drawing.SolidBrush($C_INFO_BG)
    $bPurple   = New-Object System.Drawing.SolidBrush($C_PURPLE)
    $bPurpleBg = New-Object System.Drawing.SolidBrush($C_PURPLE_BG)
    $bDisabled = New-Object System.Drawing.SolidBrush($C_DISABLED)

    $pLine     = New-Object System.Drawing.Pen($C_LINE, 1.3)
    $pPrimary  = New-Object System.Drawing.Pen($C_PRIMARY, 1.6)
    $pSuccess  = New-Object System.Drawing.Pen($C_SUCCESS, 1.6)
    $pDanger   = New-Object System.Drawing.Pen($C_DANGER, 1.6)
    $pWarn     = New-Object System.Drawing.Pen($C_WARN, 1.6)
    $pPurple   = New-Object System.Drawing.Pen($C_PURPLE, 1.6)

    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

    $sfRight = New-Object System.Drawing.StringFormat
    $sfRight.Alignment = [System.Drawing.StringAlignment]::Far

    $sfRightMid = New-Object System.Drawing.StringFormat
    $sfRightMid.Alignment = [System.Drawing.StringAlignment]::Far
    $sfRightMid.LineAlignment = [System.Drawing.StringAlignment]::Center

    # Заголовок окна (макет)
    $g.FillRectangle($bTitleBar, 0, 0, $W, 44)
    $g.DrawString([string]$screen.Attrs.caption, $fHdr, $bWhite, 14, 12)
    $g.DrawString("Макет, не итоговый вид", $fStamp, $bGold, ($W - 12), 14, $sfRight)

    function Draw-Node {
        param($Node, [int]$OffX, [int]$OffY)
        $x = $OffX + [int]$Node.Attrs.posX
        $y = $OffY + [int]$Node.Attrs.posY
        $w = [int]$Node.Attrs.width
        $h = [int]$Node.Attrs.height
        $cap = [string]$Node.Attrs.caption
        $sub = [string]$Node.Attrs.subcaption
        $tone = [string]$Node.Attrs.tone

        switch ($Node.Type) {
            "Card" {
                $bg = $bPanel; $pen = $pLine; $capBrush = $bInk
                if ($tone -eq "info") { $bg = $bInfoBg; $pen = $pPrimary; $capBrush = $bPrimary }
                elseif ($tone -eq "warning") { $bg = $bWarnBg; $pen = $pWarn; $capBrush = $bWarn }
                elseif ($tone -eq "danger") { $bg = $bDangerBg; $pen = $pDanger; $capBrush = $bDanger }
                elseif ($tone -eq "purple") { $bg = $bPurpleBg; $pen = $pPurple; $capBrush = $bPurple }
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 10 -FillBrush $bg -BorderPen $pen
                if ($cap -ne "") {
                    $g.DrawString($cap, $fBold, $capBrush, ($x + 14), ($y + 12))
                }
            }
            "Panel" {
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bPanel -BorderPen $pLine
            }
            "TabActive" {
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bPrimary -BorderPen $pPrimary
                $g.DrawString($cap, $fBold, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "TabInactive" {
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bPanel -BorderPen $pLine
                $g.DrawString($cap, $fBody, $bMuted, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "Heading" {
                $br = if ($tone -eq "normal") { $bSuccess } elseif ($tone -eq "primary") { $bPrimary } else { $bInk }
                $g.DrawString($cap, $fHeading, $br, $x, $y)
            }
            "Label" {
                $br = $bInk
                if ($tone -eq "muted") { $br = $bMuted }
                elseif ($tone -eq "danger") { $br = $bDanger }
                elseif ($tone -eq "normal") { $br = $bSuccess }
                elseif ($tone -eq "primary") { $br = $bPrimary }
                elseif ($tone -eq "purple") { $br = $bPurple }
                $g.DrawString($cap, $fBody, $br, [System.Drawing.RectangleF]::new($x, $y, $w, $h + 12))
            }
            "Mono" {
                $g.DrawString($cap, $fMono, $bMuted, $x, $y)
            }
            "TextField" {
                $g.DrawString($cap, $fSmall, $bMuted, $x, ($y - 18))
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bWhite -BorderPen $pLine
                $g.DrawString($sub, $fBody, $bInk, ($x + 12), ($y + 13))
            }
            "Button" {
                $pen = if ($tone -eq "primary-outline") { $pPrimary } else { $pLine }
                $br = if ($tone -eq "primary-outline") { $bPrimary } else { $bInk }
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bWhite -BorderPen $pen
                $g.DrawString($cap, $fBold, $br, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "PrimaryButton" {
                $bg = if ($tone -eq "purple") { $bPurple } else { $bPrimary }
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bg
                $g.DrawString($cap, $fBold, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "SuccessButton" {
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bSuccess
                $g.DrawString($cap, $fBold, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "DangerButton" {
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bDanger
                $g.DrawString($cap, $fBold, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "WarningButton" {
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bWarn
                $g.DrawString($cap, $fBold, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "Badge" {
                $bg = if ($tone -eq "normal") { $bSuccess } else { $bPrimary }
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 6 -FillBrush $bg
                $g.DrawString($cap, $fSmall, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "CheckRow" {
                $isSel = ($tone -eq "selected" -or $tone -eq "normal")
                $bg = if ($isSel) { $bSuccessBg } else { $bPanel }
                $pen = if ($isSel) { $pSuccess } else { $pLine }
                $br = if ($isSel) { $bSuccess } else { $bInk }
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bg -BorderPen $pen
                $g.DrawString($cap, $fBold, $bInk, ($x + 12), ($y + 12))
                if ($sub -ne "") {
                    $g.DrawString($sub, $fBold, $br, [System.Drawing.RectangleF]::new($x, $y, ($w - 12), $h), $sfRightMid)
                }
            }
            "SlotChip" {
                $sfTopC = New-Object System.Drawing.StringFormat
                $sfTopC.Alignment = [System.Drawing.StringAlignment]::Center
                if ($tone -eq "selected") {
                    Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bSuccess -BorderPen $pSuccess
                    $g.DrawString($cap, $fBold, $bWhite, ($x + ($w / 2)), ($y + 8), $sfTopC)
                    $g.DrawString($sub, $fSmall, $bWhite, ($x + ($w / 2)), ($y + 28), $sfTopC)
                } elseif ($tone -eq "available") {
                    Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bInfoBg -BorderPen $pPrimary
                    $g.DrawString($cap, $fBold, $bInk, ($x + ($w / 2)), ($y + 8), $sfTopC)
                    $g.DrawString($sub, $fSmall, $bPrimary, ($x + ($w / 2)), ($y + 28), $sfTopC)
                } else {
                    Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bDisabled -BorderPen $pLine
                    $g.DrawString($cap, $fBold, $bMuted, ($x + ($w / 2)), ($y + 8), $sfTopC)
                    $g.DrawString($sub, $fSmall, $bMuted, ($x + ($w / 2)), ($y + 28), $sfTopC)
                }
            }
            "ProgressBar" {
                $pct = [Math]::Max(0, [Math]::Min(100, [int]$Node.Attrs.progress))
                $barH = 14
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $barH -Radius 6 -FillBrush $bDisabled
                $fillW = [int]($w * $pct / 100.0)
                if ($fillW -gt 0) {
                    Draw-RoundedRect -G $g -X $x -Y $y -W $fillW -H $barH -Radius 6 -FillBrush $bSuccess
                }
                $steps = [string]$Node.Attrs.steps
                if ($steps -ne "") {
                    $g.DrawString($steps, $fSmall, $bMuted, $x, ($y + 20))
                }
            }
            "ListRow" {
                Draw-RoundedRect -G $g -X $x -Y $y -W $w -H $h -Radius 8 -FillBrush $bWhite -BorderPen $pLine
                $g.DrawString($cap, $fBold, $bInk, ($x + 12), ($y + 10))
                if ($sub -ne "") {
                    $g.DrawString($sub, $fSmall, $bMuted, [System.Drawing.RectangleF]::new(($x + 12), ($y + 34), ($w - 24), ($h - 40)))
                }
            }
        }

        foreach ($ch in $Node.Children) {
            Draw-Node -Node $ch -OffX $x -OffY $y
        }
    }

    foreach ($ch in $screen.Children) {
        Draw-Node -Node $ch -OffX 0 -OffY 0
    }

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
}

# Отрисовка всех .sysml файлов (кроме библиотеки)
$files = Get-ChildItem -Path $BaseDir -Filter "*.sysml" | Where-Object { $_.Name -ne "ui-library.sysml" }
foreach ($f in $files) {
    $model = Parse-SysmlModel -FilePath $f.FullName
    if ($model.Roots.Count -eq 0) { continue }
    $outName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name) + ".png"
    $outPath = Join-Path $OutDir $outName
    if ($f.Name -eq "system-context.sysml") {
        Render-ContextDiagram -Model $model -OutPath $outPath
    } else {
        Render-UiScreen -Model $model -OutPath $outPath
    }
    Write-Output "Generated: $outPath"
}
