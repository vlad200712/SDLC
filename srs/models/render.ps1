<#
.SYNOPSIS
    Упрощённая чёрно-белая отрисовка моделей SysMLv2 из папки srs/models в PNG (srs/images).
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

# Строго чёрно-белая / монохромная палитра (вайрфреймы)
$C_WHITE   = [System.Drawing.Color]::FromArgb(255, 255, 255)
$C_BLACK   = [System.Drawing.Color]::FromArgb(0, 0, 0)
$C_DARK    = [System.Drawing.Color]::FromArgb(34, 34, 34)
$C_MUTED   = [System.Drawing.Color]::FromArgb(90, 90, 90)
$C_GRAY_BG = [System.Drawing.Color]::FromArgb(236, 236, 236)
$C_BOX_BG  = [System.Drawing.Color]::FromArgb(247, 247, 247)

function Parse-SysmlModel {
    param([string]$FilePath)

    $text = Get-Content -Path $FilePath -Raw -Encoding UTF8
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

function Render-ContextDiagram {
    param($Model, [string]$OutPath)

    $screen = $Model.Roots[0]
    $W = [int]$screen.Attrs.width
    $H = [int]$screen.Attrs.height

    $bmp = New-Object System.Drawing.Bitmap($W, $H)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear($C_WHITE)

    $fHdr    = New-Object System.Drawing.Font("Arial", 13, [System.Drawing.FontStyle]::Bold)
    $fStamp  = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
    $fStereo = New-Object System.Drawing.Font("Arial", 9.5, [System.Drawing.FontStyle]::Regular)
    $fTitle  = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $fSub    = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
    $fActor  = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Regular)
    $fLink   = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)

    $bWhite = New-Object System.Drawing.SolidBrush($C_WHITE)
    $bBlack = New-Object System.Drawing.SolidBrush($C_BLACK)
    $bMuted = New-Object System.Drawing.SolidBrush($C_MUTED)
    $bBoxBg = New-Object System.Drawing.SolidBrush($C_BOX_BG)
    $bGray  = New-Object System.Drawing.SolidBrush($C_GRAY_BG)

    $pFrame = New-Object System.Drawing.Pen($C_BLACK, 1.5)
    $pBox   = New-Object System.Drawing.Pen($C_BLACK, 1.5)
    $pDash  = New-Object System.Drawing.Pen($C_BLACK, 1.5)
    $pDash.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    $pLink  = New-Object System.Drawing.Pen($C_BLACK, 1.3)

    # Ч/б шапка схемы
    $g.DrawRectangle($pFrame, 0, 0, $W - 1, $H - 1)
    $g.FillRectangle($bGray, 1, 1, $W - 2, 36)
    $g.DrawLine($pFrame, 0, 37, $W, 37)
    $g.DrawString([string]$screen.Attrs.caption, $fHdr, $bBlack, 14, 9)

    $sfRight = New-Object System.Drawing.StringFormat
    $sfRight.Alignment = [System.Drawing.StringAlignment]::Far
    $g.DrawString("Макет, не итоговый вид", $fStamp, $bMuted, ($W - 14), 11, $sfRight)

    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center

    $boundsMap = @{}

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

    foreach ($entry in $boundsMap.Values) {
        if ($entry.Kind -eq "Block" -and $entry.Node.Children.Count -gt 0) {
            $g.FillRectangle($bBoxBg, $entry.X, $entry.Y, $entry.W, $entry.H)
            $g.DrawRectangle($pBox, $entry.X, $entry.Y, $entry.W, $entry.H)
            $g.DrawString("«система»", $fStereo, $bMuted, $entry.CX, $entry.Y + 14, $sfCenter)
            $g.DrawString([string]$entry.Node.Attrs.caption, $fTitle, $bBlack, $entry.CX, $entry.Y + 34, $sfCenter)
        }
    }

    foreach ($conn in $Model.Connections) {
        $a = $boundsMap[$conn.From]
        $b = $boundsMap[$conn.To]
        if ($null -eq $a -or $null -eq $b) { continue }

        $x1 = [float]$a.CX; $y1 = [float]$a.CY
        $x2 = [float]$b.CX; $y2 = [float]$b.CY

        if ($a.Kind -eq "Actor") {
            $x1 = [float]($a.X + 26)
            $y1 = [float]($a.Y + 45)
        }
        $g.DrawLine($pLink, $x1, $y1, $x2, $y2)

        if ($conn.Caption -ne "") {
            $mx = ($x1 + $x2) / 2
            $my = ($y1 + $y2) / 2
            $sz = $g.MeasureString($conn.Caption, $fLink)
            $g.FillRectangle($bWhite, $mx - ($sz.Width / 2) - 4, $my - ($sz.Height / 2) - 2, $sz.Width + 8, $sz.Height + 4)
            $g.DrawString($conn.Caption, $fLink, $bBlack, $mx, $my - ($sz.Height / 2), $sfCenter)
        }
    }

    foreach ($entry in $boundsMap.Values) {
        if ($entry.Kind -eq "Actor") {
            $cx = $entry.X
            $cy = $entry.Y
            $g.FillEllipse($bWhite, $cx - 13, $cy, 26, 26)
            $g.DrawEllipse($pBox, $cx - 13, $cy, 26, 26)
            $g.DrawLine($pBox, $cx, $cy + 26, $cx, $cy + 64)
            $g.DrawLine($pBox, $cx - 20, $cy + 38, $cx + 20, $cy + 38)
            $g.DrawLine($pBox, $cx, $cy + 64, $cx - 16, $cy + 92)
            $g.DrawLine($pBox, $cx, $cy + 64, $cx + 16, $cy + 92)
            $g.DrawString([string]$entry.Node.Attrs.caption, $fActor, $bBlack, $cx, $cy + 98, $sfCenter)
        } elseif ($entry.Node.Children.Count -eq 0) {
            $isExt = ($entry.Node.Attrs.tone -eq "external")
            $fill = if ($isExt) { $bGray } else { $bWhite }
            $pen  = if ($isExt) { $pDash } else { $pBox }
            $stereo = if ($isExt) { "«внешний элемент»" } else { "«часть»" }
            $g.FillRectangle($fill, $entry.X, $entry.Y, $entry.W, $entry.H)
            $g.DrawRectangle($pen, $entry.X, $entry.Y, $entry.W, $entry.H)

            $sub = [string]$entry.Node.Attrs.subcaption
            if ($sub -ne "") {
                $g.DrawString($stereo, $fStereo, $bMuted, $entry.CX, $entry.Y + 24, $sfCenter)
                $g.DrawString([string]$entry.Node.Attrs.caption, $fTitle, $bBlack, $entry.CX, $entry.Y + 48, $sfCenter)
                $g.DrawString($sub, $fSub, $bMuted, $entry.CX, $entry.Y + 76, $sfCenter)
            } else {
                $g.DrawString($stereo, $fStereo, $bMuted, $entry.CX, $entry.Y + 34, $sfCenter)
                $g.DrawString([string]$entry.Node.Attrs.caption, $fTitle, $bBlack, $entry.CX, $entry.Y + 58, $sfCenter)
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
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear($C_WHITE)

    # Обычный базовый шрифт Arial без декоративных стилей
    $fHdr     = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $fStamp   = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Regular)
    $fHeading = New-Object System.Drawing.Font("Arial", 10.5, [System.Drawing.FontStyle]::Bold)
    $fBody    = New-Object System.Drawing.Font("Arial", 9.5, [System.Drawing.FontStyle]::Regular)
    $fBold    = New-Object System.Drawing.Font("Arial", 9.5, [System.Drawing.FontStyle]::Bold)
    $fSmall   = New-Object System.Drawing.Font("Arial", 8.5, [System.Drawing.FontStyle]::Regular)

    $bWhite  = New-Object System.Drawing.SolidBrush($C_WHITE)
    $bBlack  = New-Object System.Drawing.SolidBrush($C_BLACK)
    $bDark   = New-Object System.Drawing.SolidBrush($C_DARK)
    $bMuted  = New-Object System.Drawing.SolidBrush($C_MUTED)
    $bGrayBg = New-Object System.Drawing.SolidBrush($C_GRAY_BG)
    $bBoxBg  = New-Object System.Drawing.SolidBrush($C_BOX_BG)

    $pThin   = New-Object System.Drawing.Pen($C_BLACK, 1)
    $pThick  = New-Object System.Drawing.Pen($C_BLACK, 2)
    $pMuted  = New-Object System.Drawing.Pen($C_MUTED, 1)

    $sfCenter = New-Object System.Drawing.StringFormat
    $sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

    $sfRight = New-Object System.Drawing.StringFormat
    $sfRight.Alignment = [System.Drawing.StringAlignment]::Far

    $sfRightMid = New-Object System.Drawing.StringFormat
    $sfRightMid.Alignment = [System.Drawing.StringAlignment]::Far
    $sfRightMid.LineAlignment = [System.Drawing.StringAlignment]::Center

    $sfLeftMid = New-Object System.Drawing.StringFormat
    $sfLeftMid.Alignment = [System.Drawing.StringAlignment]::Near
    $sfLeftMid.LineAlignment = [System.Drawing.StringAlignment]::Center

    # Внешняя ч/б рамка экрана и шапка макета
    $g.DrawRectangle($pThin, 0, 0, $W - 1, $H - 1)
    $g.FillRectangle($bGrayBg, 1, 1, $W - 2, 36)
    $g.DrawLine($pThin, 0, 37, $W, 37)
    $g.DrawString([string]$screen.Attrs.caption, $fHdr, $bBlack, 10, 10)
    $g.DrawString("Макет, не итоговый вид", $fStamp, $bMuted, ($W - 10), 12, $sfRight)

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
                $g.FillRectangle($bWhite, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                if ($cap -ne "") {
                    $g.FillRectangle($bGrayBg, $x + 1, $y + 1, $w - 2, 23)
                    $g.DrawLine($pThin, $x, $y + 24, $x + $w, $y + 24)
                    $g.DrawString($cap, $fBold, $bBlack, ($x + 8), ($y + 4))
                }
            }
            "TabActive" {
                $g.FillRectangle($bDark, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                $g.DrawString($cap, $fBold, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "TabInactive" {
                $g.FillRectangle($bWhite, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                $g.DrawString($cap, $fBody, $bBlack, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "Heading" {
                $g.DrawString($cap, $fHeading, $bBlack, $x, $y)
            }
            "Label" {
                $g.DrawString($cap, $fBody, $bBlack, [System.Drawing.RectangleF]::new($x, $y, $w, $h + 10))
            }
            "TextField" {
                $g.DrawString($cap, $fSmall, $bBlack, $x, ($y - 16))
                $g.FillRectangle($bWhite, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                $g.DrawString($sub, $fBody, $bMuted, [System.Drawing.RectangleF]::new(($x + 8), $y, ($w - 16), $h), $sfLeftMid)
            }
            "Button" {
                $g.FillRectangle($bWhite, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                $g.DrawString($cap, $fBody, $bBlack, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "PrimaryButton" {
                $g.FillRectangle($bDark, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                $g.DrawString($cap, $fBold, $bWhite, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $sfCenter)
            }
            "CheckRow" {
                $isSel = ($tone -eq "selected" -or $tone -eq "normal")
                $bg = if ($isSel) { $bGrayBg } else { $bWhite }
                $g.FillRectangle($bg, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                $capW = if ($sub -ne "") { $w - 92 } else { $w - 16 }
                $g.DrawString($cap, $fBody, $bBlack, [System.Drawing.RectangleF]::new(($x + 8), $y, $capW, $h), $sfLeftMid)
                if ($sub -ne "") {
                    $g.DrawString($sub, $fBold, $bBlack, [System.Drawing.RectangleF]::new($x, $y, ($w - 8), $h), $sfRightMid)
                }
            }
            "SlotChip" {
                $sfTopC = New-Object System.Drawing.StringFormat
                $sfTopC.Alignment = [System.Drawing.StringAlignment]::Center
                if ($tone -eq "selected") {
                    $g.FillRectangle($bDark, $x, $y, $w, $h)
                    $g.DrawRectangle($pThick, $x, $y, $w, $h)
                    $g.DrawString($cap, $fBold, $bWhite, ($x + ($w / 2)), ($y + 6), $sfTopC)
                    $g.DrawString($sub, $fSmall, $bWhite, ($x + ($w / 2)), ($y + 24), $sfTopC)
                } elseif ($tone -eq "available") {
                    $g.FillRectangle($bWhite, $x, $y, $w, $h)
                    $g.DrawRectangle($pThin, $x, $y, $w, $h)
                    $g.DrawString($cap, $fBold, $bBlack, ($x + ($w / 2)), ($y + 6), $sfTopC)
                    $g.DrawString($sub, $fSmall, $bBlack, ($x + ($w / 2)), ($y + 24), $sfTopC)
                } else {
                    $g.FillRectangle($bGrayBg, $x, $y, $w, $h)
                    $g.DrawRectangle($pMuted, $x, $y, $w, $h)
                    $g.DrawString($cap, $fBody, $bMuted, ($x + ($w / 2)), ($y + 6), $sfTopC)
                    $g.DrawString($sub, $fSmall, $bMuted, ($x + ($w / 2)), ($y + 24), $sfTopC)
                }
            }
            "ProgressBar" {
                $pct = [Math]::Max(0, [Math]::Min(100, [int]$Node.Attrs.progress))
                $barH = 12
                $g.FillRectangle($bWhite, $x, $y, $w, $barH)
                $g.DrawRectangle($pThin, $x, $y, $w, $barH)
                $fillW = [int]($w * $pct / 100.0)
                if ($fillW -gt 0) {
                    $g.FillRectangle($bDark, $x, $y, $fillW, $barH)
                }
                $steps = [string]$Node.Attrs.steps
                if ($steps -ne "") {
                    $g.DrawString($steps, $fSmall, $bMuted, $x, ($y + 16))
                }
            }
            "ListRow" {
                $g.FillRectangle($bWhite, $x, $y, $w, $h)
                $g.DrawRectangle($pThin, $x, $y, $w, $h)
                $g.DrawString($cap, $fBold, $bBlack, ($x + 8), ($y + 6))
                if ($sub -ne "") {
                    $g.DrawString($sub, $fSmall, $bMuted, ($x + 8), ($y + 25))
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
