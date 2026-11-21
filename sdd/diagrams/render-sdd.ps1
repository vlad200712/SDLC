# Generator of B&W no-fill SDD architecture diagrams and color iteration plan charts
Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot "..\images"
if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

function New-Canvas([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear([System.Drawing.Color]::White)
    return @{ bmp = $bmp; g = $g }
}

function Save-Canvas($c, [string]$name) {
    $path = Join-Path $outDir $name
    $c.bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $c.g.Dispose()
    $c.bmp.Dispose()
    Write-Host "Generated: $path"
}

function Draw-RoundRect($g, $brush, $pen, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    if ($null -ne $brush) { $g.FillPath($brush, $path) }
    if ($null -ne $pen) { $g.DrawPath($pen, $path) }
    $path.Dispose()
}

function Draw-Arrow($g, $pen, [float]$x1, [float]$y1, [float]$x2, [float]$y2, [string]$label = "", [float]$lxOffset = 0, [float]$lyOffset = -16, [bool]$dashed = $false) {
    $p = $pen.Clone()
    if ($dashed) { $p.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash }
    $cap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(5, 6, $true)
    $p.CustomEndCap = $cap
    $g.DrawLine($p, $x1, $y1, $x2, $y2)
    if ($label -ne "") {
        $f = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
        $mx = ($x1 + $x2) / 2 + $lxOffset
        $my = ($y1 + $y2) / 2 + $lyOffset
        $sz = $g.MeasureString($label, $f)
        $bg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 255, 255, 255))
        $g.FillRectangle($bg, $mx - $sz.Width/2 - 3, $my - 1, $sz.Width + 6, $sz.Height + 1)
        $tb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
        $g.DrawString($label, $f, $tb, $mx - $sz.Width/2, $my)
        $f.Dispose(); $bg.Dispose(); $tb.Dispose()
    }
    $p.Dispose(); $cap.Dispose()
}

function Draw-BoxBW($g, [float]$x, [float]$y, [float]$w, [float]$h, [string]$title, [string]$subtitle, [System.Drawing.Color]$fill, [float]$penWidth = 1.6, [string]$tag = "", [bool]$dashedBorder = $false) {
    $br = New-Object System.Drawing.SolidBrush($fill)
    $pn = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, $penWidth)
    if ($dashedBorder) { $pn.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash }
    Draw-RoundRect $g $br $pn $x $y $w $h 6
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Near

    $yCur = $y + 8
    if ($tag -ne "") {
        $ftag = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Italic)
        $btag = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(55, 55, 55))
        $g.DrawString($tag, $ftag, $btag, ([System.Drawing.RectangleF]::new(($x + 6), $yCur, ($w - 12), 18)), $sf)
        $yCur += 16
        $ftag.Dispose(); $btag.Dispose()
    }
    $ft = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
    $bt = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $g.DrawString($title, $ft, $bt, ([System.Drawing.RectangleF]::new(($x + 6), $yCur, ($w - 12), 38)), $sf)
    $yCur += $(if ($title.Contains("`n")) { 36 } else { 22 })
    if ($subtitle -ne "") {
        $fs = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
        $bs = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 30, 30))
        $g.DrawString($subtitle, $fs, $bs, ([System.Drawing.RectangleF]::new(($x + 8), $yCur, ($w - 16), ($h - ($yCur - $y) - 6))), $sf)
        $fs.Dispose(); $bs.Dispose()
    }
    $br.Dispose(); $pn.Dispose(); $ft.Dispose(); $bt.Dispose(); $sf.Dispose()
}

function Draw-HeaderBW($g, [int]$w, [string]$title, [string]$subtitle) {
    $bg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $pn = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.5)
    $g.FillRectangle($bg, 0, 0, $w, 56)
    $g.DrawLine($pn, 0, 56, $w, 56)
    $ft = New-Object System.Drawing.Font("Segoe UI", 13.5, [System.Drawing.FontStyle]::Bold)
    $fs = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
    $bt = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $bs = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 40, 40))
    $g.DrawString($title, $ft, $bt, 18, 8)
    $g.DrawString($subtitle, $fs, $bs, 18, 33)
    $bg.Dispose(); $pn.Dispose(); $ft.Dispose(); $fs.Dispose(); $bt.Dispose(); $bs.Dispose()
}

# Pure B&W no-fill palette for ALL 5 architecture diagrams (white backgrounds, crisp black lines & text)
$colWhite = [System.Drawing.Color]::White
$colTint1 = [System.Drawing.Color]::White
$colTint2 = [System.Drawing.Color]::White
$colTint3 = [System.Drawing.Color]::White

$penBW     = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.7)
$penBWBold = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 2.1)
$penBWGray = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 90, 90), 1.6)

# ============================================================================
# 1. ARCH-COMPONENTS.PNG (DV-002 — STRICTLY B&W)
# ============================================================================
$c = New-Canvas 1460 820
$g = $c.g
Draw-HeaderBW $g 1460 "DV-002: Компонентная архитектура AutoService v1.0 (C4 / MVVM + Layered)" "Связанные решения: ADR-0001, ADR-0002, ADR-0003, ADR-0005, ADR-0006"

# Client container
Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($colTint1)) (New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 2)) 24 80 410 520 8
$g.DrawString("AutoServiceClient (Qt Quick / C++17, MVVM)", (New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 38, 90)

Draw-BoxBW $g 44 125 370 110 "QML Views (Презентационный слой)" "Auth, Register, Garage, AddCar, Booking/History,`nStaffPanel, PhotoGallery (F15), Reminders (F16)" $colWhite 1.6 "<<UI / зона задач Junior>>"
Draw-BoxBW $g 44 265 370 100 "C++ ViewModels (Состояние и команды)" "AuthVM, GarageVM, BookingVM, StaffVM, HistoryVM`n(Q_PROPERTY, сигналы/слоты, валидация форм)" $colWhite 1.6 "<<ViewModel>>"
Draw-BoxBW $g 44 395 175 100 "CloudApiClient" "HTTPS/TLS 1.3 + JWT`nJSON REST / Multipart`nSecureTokenStore" $colWhite 1.5 "<<Network>>"
Draw-BoxBW $g 239 395 175 100 "SqliteCacheRepo" "Read-only кэш`nPull-синхронизация`nJsonExporter (F11)" $colWhite 1.5 "<<Local Data>>"
Draw-BoxBW $g 239 520 175 62 "SQLite (Клиент)" "Гараж + история (<200 мс)" $colTint2 1.6 ""

Draw-Arrow $g $penBW 229 235 229 265 "bindings" 40 -10
Draw-Arrow $g $penBW 150 365 130 395 "" 0 0
Draw-Arrow $g $penBW 305 365 325 395 "" 0 0
Draw-Arrow $g $penBW 326 495 326 520 "SQL" 22 -8

# Shared Core library
Draw-BoxBW $g 24 635 410 150 "AutoServiceCore (Статическая библиотека C++17)" "Общие DTO (User, Vehicle, Order, ServiceItem, Reminder)`nVinValidator (ISO 3779) | PriceCalculator (коэфф. кузова + скидка 10%)`nOrderStateMachine | Без зависимостей от Qt GUI и СУБД" $colTint2 2.0 "<<Shared Domain Library / ADR-0003>>"

# Server container
Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($colTint1)) (New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 2)) 510 80 610 705 8
$g.DrawString("AutoServiceServer – Cloud API (C++17, Layered + Repository)", (New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 526, 90)

Draw-BoxBW $g 530 125 570 95 "Transport, Security & Observability Layer" "REST Router /api/v1/* | JwtAuthMiddleware | RbacGuard (client/master/admin)`nRateLimitGuard (5 попыток -> 15 мин блок) | X-Request-ID JSON Logger | GET /health" $colWhite 1.8 "<<Gateway / ADR-0002>>"

Draw-BoxBW $g 530 250 180 115 "Auth & Vehicle`nServices" "Регистрация (99-З)`nJWT, гараж, VIN`nпробег (F02, F03)" $colWhite 1.5 "<<Domain>>"
Draw-BoxBW $g 725 250 180 115 "Booking & Workflow`nServices" "ACID-слоты (F06)`nСтатусы, доп. работы`nАудит (F07-F09)" $colWhite 1.5 "<<Domain>>"
Draw-BoxBW $g 920 250 180 115 "Media & Reminder`nServices" "Фотоотчёт F15 (JPEG)`nПланировщик ТО F16`nЗагрузка СТО F14" $colWhite 1.5 "<<Domain / R2>>"

Draw-BoxBW $g 530 400 275 110 "PgRepository (ACID Data Access)" "Параметризованный SQL (anti-SQLi)`nSELECT FOR UPDATE + EXCLUDE gist`nImmutable AuditLog & History" $colWhite 1.6 "<<Persistence / ADR-0004>>"
Draw-BoxBW $g 825 400 275 110 "External Adapters & Media" "NhtsaVinAdapter (3s, 2 retry, cache)`nPushQueueWorker (async FCM/APNs)`nLocalMediaStorage (IMediaStorage)" $colWhite 1.6 "<<Adapters / ADR-0005, 0006>>"

Draw-BoxBW $g 530 555 275 110 "PostgreSQL 16 (Мастер-БД)" "11 таблиц (users, vehicles, orders,`norder_photos, maintenance_reminders,`naudit_log) + pg_dump backup" $colTint2 1.8 "<<Database / ADR-0001>>"
Draw-BoxBW $g 825 555 275 110 "Media Volume (Docker)" "/var/lib/autoservice/media`nСжатые JPEG <= 500 КБ (UUID)`nДоступ строго по JWT/RBAC" $colTint2 1.8 "<<File Storage / ADR-0006>>"

Draw-BoxBW $g 530 695 570 72 "Логи и мониторинг: JSON stdout/file + /health check + ежедневный backup-cron (RTO <= 30 мин)" "" $colWhite 1.4 ""

# Internal server arrows
Draw-Arrow $g $penBW 620 220 620 250 "" 0 0
Draw-Arrow $g $penBW 815 220 815 250 "" 0 0
Draw-Arrow $g $penBW 1010 220 1010 250 "" 0 0
Draw-Arrow $g $penBW 620 365 650 400 "" 0 0
Draw-Arrow $g $penBW 815 365 720 400 "" 0 0
Draw-Arrow $g $penBW 850 365 920 400 "" 0 0
Draw-Arrow $g $penBW 1010 365 980 400 "" 0 0
Draw-Arrow $g $penBW 667 510 667 555 "libpq / SQL" 45 -8
Draw-Arrow $g $penBW 962 510 962 555 "JPEG <=500KB" 52 -8

# External systems (dashed borders in B&W)
Draw-BoxBW $g 1185 250 250 130 "NHTSA VIN API" "vpic.nhtsa.dot.gov/api`nДекодирование 17-зн. VIN`n(таймаут 3 с -> ручной ввод)" $colWhite 1.7 "<<External System>>" $true
Draw-BoxBW $g 1185 430 250 130 "FCM / APNs Push" "Доставка Push-событий:`nГотов к выдаче, Доп. работы,`nНапоминания о ТО (F16)" $colWhite 1.7 "<<External System>>" $true
Draw-BoxBW $g 1185 615 250 105 "API курсов валют (USD)" "Исключён в Раунде 2`n(F13 отменён, расчёты`nтолько в BYN)" $colTint2 1.2 "<<Removed in R2>>" $true

# Cross-boundary arrows
Draw-Arrow $g $penBWBold 414 445 530 175 "HTTPS / REST`n+ Bearer JWT" -6 -24
Draw-Arrow $g $penBW 229 600 229 635 "links" 26 -8 $true
Draw-Arrow $g $penBW 434 710 510 320 "uses Core`n(DTO/Calc)" -12 -20 $true
Draw-Arrow $g $penBW 1100 435 1185 320 "HTTPS`nVIN" 0 -18
Draw-Arrow $g $penBW 1100 475 1185 495 "Push`nAPI" 0 -18

$g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.2)), 0, 0, 1459, 819)
Save-Canvas $c "arch-components.png"

# ============================================================================
# 2. ER-DATABASE.PNG (DV-003 — STRICTLY B&W)
# ============================================================================
$c = New-Canvas 1480 860
$g = $c.g
Draw-HeaderBW $g 1480 "DV-003: Логическая ER-модель БД PostgreSQL (11 таблиц) и локального кэша SQLite" "Связанные решения: ADR-0001, ADR-0004, ADR-0006 | Все запросы параметризованы (REQ-SEC-006)"

function Draw-EntityBW($g, [float]$x, [float]$y, [float]$w, [string]$name, [string[]]$fields, [bool]$isCore = $true) {
    $rowH = 19
    $h = 30 + $fields.Count * $rowH + 6
    $bg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $pn = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.6)
    if (-not $isCore) { $pn.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash }
    $pnSep = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.4)
    $g.FillRectangle($bg, $x, $y, $w, $h)
    $g.DrawRectangle($pn, $x, $y, $w, $h)
    $g.DrawLine($pnSep, $x, $y + 28, $x + $w, $y + 28)
    $ft = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    $ff = New-Object System.Drawing.Font("Consolas", 8.8, [System.Drawing.FontStyle]::Regular)
    $ffb = New-Object System.Drawing.Font("Consolas", 8.8, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($name, $ft, [System.Drawing.Brushes]::Black, $x + 8, $y + 6)
    $cy = $y + 32
    foreach ($fld in $fields) {
        $useFont = if ($fld.StartsWith("PK") -or $fld.StartsWith("FK")) { $ffb } else { $ff }
        $g.DrawString($fld, $useFont, [System.Drawing.Brushes]::Black, $x + 8, $cy)
        $cy += $rowH
    }
    $bg.Dispose(); $pn.Dispose(); $pnSep.Dispose(); $ft.Dispose(); $ff.Dispose(); $ffb.Dispose()
    return $h
}

$null = Draw-EntityBW $g 30 80 265 "users" @("PK id : UUID","   role : ENUM(client,master,admin)","   full_name : VARCHAR(120)","   phone : VARCHAR(20) UNIQUE","   email : VARCHAR(120) UNIQUE","   password_hash : TEXT (Argon2id)","FK box_id : INT NULL -> service_boxes","   failed_attempts : SMALLINT","   locked_until : TIMESTAMPTZ","   consent_at : TIMESTAMPTZ (99-З)") $true
$null = Draw-EntityBW $g 30 340 265 "refresh_tokens" @("PK id : UUID","FK user_id : UUID -> users","   token_hash : CHAR(64)","   expires_at : TIMESTAMPTZ","   revoked_at : TIMESTAMPTZ NULL") $true
$null = Draw-EntityBW $g 30 505 265 "audit_log (APPEND-ONLY)" @("PK id : BIGSERIAL","FK actor_id : UUID -> users","   action : VARCHAR(64)","   target_entity : VARCHAR(40)","   target_id : TEXT","   payload_jsonb : JSONB","   created_at : TIMESTAMPTZ") $true

$null = Draw-EntityBW $g 365 80 275 "vehicles" @("PK id : UUID","FK owner_id : UUID -> users","   vin : CHAR(17) (ISO 3779)","   brand : VARCHAR(50)","   model : VARCHAR(60)","   year : SMALLINT","   mileage_km : INT","   plate_number : VARCHAR(20)","   body_type : VARCHAR(30)","   body_coeff : NUMERIC(3,2)") $true
$null = Draw-EntityBW $g 365 340 275 "maintenance_reminders [NEW R2]" @("PK id : UUID","FK vehicle_id : UUID UNIQUE","   interval_km : INT (def 10000)","   interval_months : INT (def 12)","   next_due_date : DATE","   next_due_km : INT","   notified_at : TIMESTAMPTZ","   is_enabled : BOOLEAN") $false
$null = Draw-EntityBW $g 365 565 275 "service_boxes" @("PK id : SERIAL","   number : SMALLINT UNIQUE","   work_start : TIME (09:00)","   work_end : TIME (21:00)","   is_active : BOOLEAN") $true

$null = Draw-EntityBW $g 710 80 310 "orders (EXCLUDE gist slots)" @("PK id : BIGSERIAL","FK vehicle_id : UUID -> vehicles","FK box_id : INT -> service_boxes","   slot_start : TIMESTAMPTZ","   slot_end : TIMESTAMPTZ","   status : ENUM(7 states)","   mileage_at_visit : INT","   subtotal_byn : NUMERIC(10,2)","   discount_byn : NUMERIC(10,2)","   total_byn : NUMERIC(10,2)","   created_at : TIMESTAMPTZ") $true
$null = Draw-EntityBW $g 710 365 310 "order_services (Snapshot)" @("PK (order_id, service_id)","FK order_id : BIGINT -> orders","FK service_id : INT -> catalog","   service_name_snap : VARCHAR(80)","   price_snap_byn : NUMERIC(10,2)","   duration_snap_min : INT") $true
$null = Draw-EntityBW $g 710 550 310 "service_catalog" @("PK id : SERIAL","   code : VARCHAR(32) UNIQUE","   name : VARCHAR(80)","   base_price_byn : NUMERIC(10,2)","   base_duration_min : INT","   use_body_coeff : BOOLEAN","   is_active : BOOLEAN") $true

$null = Draw-EntityBW $g 1095 80 355 "additional_work_requests" @("PK id : UUID","FK order_id : BIGINT -> orders","FK master_id : UUID -> users","   title : VARCHAR(140)","   price_byn : NUMERIC(10,2)","   comment : TEXT","   decision : ENUM(pending,approved,rejected)","   decided_at : TIMESTAMPTZ NULL") $true
$null = Draw-EntityBW $g 1095 310 355 "order_photos [F15 – NEW R2]" @("PK id : UUID","FK request_id : UUID -> add_work_req","   storage_key : VARCHAR(120) (UUID)","   mime_type : VARCHAR(32) (image/jpeg)","   size_bytes : INT (<= 512000)","   sha256 : CHAR(64)","   uploaded_at : TIMESTAMPTZ") $false

Draw-BoxBW $g 1095 510 355 215 "Локальный кэш SQLite (Клиент)" "Read-only Pull-синхронизация (ADR-0001):`n• cached_vehicles (авто текущего клиента)`n• cached_service_catalog (тарифы BYN)`n• cached_order_history (завершённые заказы)`n`nИндекс: (vehicle_id, completed_at DESC)`nОчистка БД при выходе (REQ-DIST-001)`nЧтение 100 записей <= 200 мс (REQ-PERF-004)" $colTint1 1.6 "<<Client Offline Cache>>" $true

# Relationships
Draw-Arrow $g $penBW 295 140 365 140 "1 : N" 0 -16
Draw-Arrow $g $penBW 160 306 160 340 "1 : N" 26 -8
$g.DrawLine($penBW, 30, 210, 12, 210)
$g.DrawLine($penBW, 12, 210, 12, 570)
Draw-Arrow $g $penBW 12 570 30 570 "" 0 0
Draw-Arrow $g $penBW 502 306 502 340 "1 : 1" 26 -8
Draw-Arrow $g $penBW 640 160 710 160 "1 : N" 0 -16
Draw-Arrow $g $penBW 640 610 710 260 "1 : N`nbox" -16 -10
Draw-Arrow $g $penBW 865 325 865 365 "1 : N" 26 -8
Draw-Arrow $g $penBW 865 550 865 516 "1 : N" 26 -8
Draw-Arrow $g $penBW 1020 155 1095 155 "1 : N" 0 -16
Draw-Arrow $g $penBW 1270 268 1270 310 "1 : 0..3" 32 -8

$g.DrawString("Примечание: сплошная рамка – базовые таблицы ядра (SRS v0.1); пунктирная рамка [NEW R2] – таблицы, добавленные в Раунде 2 (F15, F16).", (New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Italic)), [System.Drawing.Brushes]::Black, 30, 815)
$g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.2)), 0, 0, 1479, 859)
Save-Canvas $c "er-database.png"

# ============================================================================
# 3. STATE-ORDER.PNG (DV-006 — STRICTLY B&W)
# ============================================================================
$c = New-Canvas 1420 560
$g = $c.g
Draw-HeaderBW $g 1420 "DV-006: Диаграмма состояний жизненного цикла заказа (OrderStateMachine)" "Связанные требования: REQ-FUNC-014..019, REQ-FUNC-022, REQ-FUNC-026, REQ-FUNC-031..032"

$g.FillEllipse([System.Drawing.Brushes]::Black, 24, 178, 22, 22)

Draw-BoxBW $g 145 140 175 98 "Scheduled" "Записан на слот`n[Клиент / ACID-слот]" $colWhite 1.8 "1"
Draw-BoxBW $g 375 140 175 98 "Accepted" "Принят в бокс`n[Мастер бокса]" $colWhite 1.8 "2"
Draw-BoxBW $g 605 140 175 98 "Diagnostics" "На диагностике`n[Мастер бокса]" $colWhite 1.8 "3"
Draw-BoxBW $g 835 140 175 98 "InProgress" "В работе`n[Мастер бокса]" $colWhite 1.8 "4"
Draw-BoxBW $g 1075 140 195 98 "Ready" "Готов к выдаче`n[Push -> Клиент]" $colTint1 1.8 "5"

Draw-BoxBW $g 120 355 220 112 "Cancelled" "Отменён`nСлот освобождён`n(запись в audit_log)" $colTint2 1.8 "Финальное"
Draw-BoxBW $g 1045 355 275 122 "Completed" "Завершён (История + ТО)`nНеизменяемый снимок (F10)`nОбновление ТО +12 мес / 10т км (F16)" $colTint2 1.8 "Финальное"

Draw-BoxBW $g 575 355 395 130 "Согласование доп. работ + фотоотчёт (F08, F15)" "1) Мастер: запрос + 1..3 фото (JPEG <= 500 КБ) -> Push`n2) Клиент: «Подтвердить» (пересчёт total_byn) или «Отклонить»`n3) Неизменяемая запись в audit_log" $colTint1 1.6 "<<Параллельный подпроцесс>>" $true

Draw-Arrow $g $penBWBold 46 189 145 189 "POST /orders`n(ACID)" 0 -36
Draw-Arrow $g $penBWBold 320 189 375 189 "приём" 0 -20
Draw-Arrow $g $penBWBold 550 189 605 189 "осмотр" 0 -20
Draw-Arrow $g $penBWBold 780 189 835 189 "ремонт" 0 -20
Draw-Arrow $g $penBWBold 1010 189 1075 189 "готово`n(+Push)" 0 -34

Draw-Arrow $g $penBWBold 232 238 232 355 "отмена [slot_start - now >= 2 ч]`n(REQ-FUNC-015)" 106 -14
$g.DrawArc($penBW, 172, 92, 120, 60, 180, 180)
$g.DrawString("перенос [>= 2 ч]", (New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 182, 75)

Draw-Arrow $g $penBWBold 1172 238 1172 355 "выдача авто и`nзакрытие наряда" 68 -14
Draw-Arrow $g $penBW 692 238 692 355 "инициация`nдоп. работ" -44 -14 $true
Draw-Arrow $g $penBW 895 238 895 355 "инициация`nдоп. работ" 44 -14 $true

$g.DrawEllipse($penBWBold, 365, 398, 26, 26)
$g.FillEllipse([System.Drawing.Brushes]::Black, 370, 403, 16, 16)
Draw-Arrow $g $penBWBold 340 411 365 411 "" 0 0

$g.DrawEllipse($penBWBold, 1350, 403, 26, 26)
$g.FillEllipse([System.Drawing.Brushes]::Black, 1355, 408, 16, 16)
Draw-Arrow $g $penBWBold 1320 416 1350 416 "" 0 0

$g.DrawString("Примечание: каждый перевод статуса мастером проверяется RBAC middleware (только закреплённый бокс) и фиксируется в таблице audit_log с меткой времени UTC.", (New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Italic)), [System.Drawing.Brushes]::Black, 30, 515)
$g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.2)), 0, 0, 1419, 559)
Save-Canvas $c "state-order.png"

# ============================================================================
# 4. SEQ-BOOKING-EXTRA.PNG (DV-005 — STRICTLY B&W)
# ============================================================================
$c = New-Canvas 1440 820
$g = $c.g
Draw-HeaderBW $g 1440 "DV-005: Диаграмма последовательности – Конкурентное бронирование и фотоотчёт доп. работ" "Связанные решения: ADR-0004 (ACID-слоты), ADR-0005 (Push), ADR-0006 (Фотоотчёт F15)"

$actors = @(
    @{ x = 110; name = "Клиент 1`n(Qt Quick)" },
    @{ x = 310; name = "Клиент 2`n(Конкурент)" },
    @{ x = 560; name = "Cloud API`n(C++17 / RBAC)" },
    @{ x = 830; name = "PostgreSQL`n(ACID / gist)" },
    @{ x = 1080; name = "MediaStorage`n(JPEG <=500KB)" },
    @{ x = 1310; name = "Мастер СТО`n& FCM Push" }
)

$dashPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(110, 110, 110), 1.4)
$dashPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash

foreach ($a in $actors) {
    Draw-BoxBW $g ($a.x - 85) 78 170 54 $a.name "" $colTint1 1.6
    $g.DrawLine($dashPen, $a.x, 132, $a.x, 785)
}

Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($colTint2)) (New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.2)) 24 150 1392 26 4
$g.DrawString("Сценарий 1: Конкурентное бронирование одного слота Бокса №2 (ADR-0004, REQ-FUNC-014, REQ-REL-002)", (New-Object System.Drawing.Font("Segoe UI", 9.8, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 34, 154)

Draw-Arrow $g $penBWBold 110 205 560 205 "1. POST /api/v1/orders (Бокс 2, 12:30, JWT)" 0 -21
Draw-Arrow $g $penBWGray 310 238 560 238 "2. POST /api/v1/orders (Бокс 2, 12:30 – одновременно)" 0 -21
Draw-Arrow $g $penBWBold 560 272 830 272 "3. BEGIN; SELECT box FOR UPDATE; INSERT orders" 0 -21
Draw-Arrow $g $penBWBold 830 304 560 304 "4. COMMIT (order #1042 создан)" 0 -21 $true
Draw-Arrow $g $penBWBold 560 334 110 334 "5. HTTP 201 Created (Заказ #1042)" 0 -21 $true
Draw-Arrow $g $penBWGray 560 366 830 366 "6. INSERT orders (Клиент 2) -> SQLSTATE 23P01 (EXCLUDE gist)" 0 -21
Draw-Arrow $g $penBWGray 830 396 560 396 "7. ROLLBACK (слот занят)" 0 -21 $true
Draw-Arrow $g $penBWGray 560 426 310 426 "8. HTTP 409 Conflict «Слот занят, обновите расписание»" 0 -21 $true

Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($colTint2)) (New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.2)) 24 452 1392 26 4
$g.DrawString("Сценарий 2: Запрос дополнительных работ с фотоотчётом мастера и согласование клиентом (F08 + F15, ADR-0006)", (New-Object System.Drawing.Font("Segoe UI", 9.8, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 34, 456)

Draw-Arrow $g $penBWBold 1310 508 560 508 "9. POST /orders/1042/extra-works + POST /photos (2 фото JPEG <=500KB)" 0 -21
Draw-Arrow $g $penBWBold 560 540 1080 540 "10. Проверка MIME/размера, сохранение UUID-файлов" 0 -21
Draw-Arrow $g $penBWBold 560 572 830 572 "11. INSERT additional_work_requests + order_photos + push_queue" 0 -21
Draw-Arrow $g $penBWGray 560 605 1310 605 "12. PushQueueWorker -> FCM/APNs (Push: «Запрос + фото по #1042»)" 0 -21 $true
Draw-Arrow $g $penBWBold 110 642 560 642 "13. GET /extra-works/{reqId}/photos/{photoId} (Bearer JWT)" 0 -21
Draw-Arrow $g $penBWBold 560 672 1080 672 "14. Проверка RBAC (owner) -> чтение JPEG" 0 -21
Draw-Arrow $g $penBWBold 560 704 110 704 "15. HTTP 200 image/jpeg (просмотр галереи у клиента)" 0 -21 $true
Draw-Arrow $g $penBWBold 110 738 560 738 "16. POST /extra-works/{reqId}/decision {decision: 'approved'}" 0 -21
Draw-Arrow $g $penBWBold 560 768 830 768 "17. TX: UPDATE total_byn (+45 BYN) + INSERT audit_log -> 200 OK" 0 -21

$g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.2)), 0, 0, 1439, 819)
Save-Canvas $c "seq-booking-extra.png"

# ============================================================================
# 5. DEPLOYMENT.PNG (DV-009 — STRICTLY B&W)
# ============================================================================
$c = New-Canvas 1420 660
$g = $c.g
Draw-HeaderBW $g 1420 "DV-009: Диаграмма развёртывания AutoService (Docker Compose + Клиент Qt Quick)" "Связанные требования: REQ-INST-001, REQ-AVAIL-001..002, REQ-SEC-002, REQ-COST-001, ADR-0006"

Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($colTint1)) (New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 2)) 24 85 330 520 8
$g.DrawString("<<device>> Клиентские устройства", (New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 38, 96)
Draw-BoxBW $g 44 135 290 120 "Смартфон Клиента СТО" "Android / iOS (Qt Quick 6)`nЛокальный SQLite read-only кэш`nSecureTokenStore (JWT)" $colWhite 1.5 "<<mobile>>"
Draw-BoxBW $g 44 285 290 120 "Планшет / Смартфон Мастера" "Android / iOS (Qt Quick 6)`nКамера/галерея (фотоотчёт F15)`nУправление заказами бокса" $colWhite 1.5 "<<mobile>>"
Draw-BoxBW $g 44 435 290 120 "ПК Администратора СТО" "Windows / Linux (Qt Quick 6)`nНастройка тарифов и боксов`nИндикатор загрузки СТО" $colWhite 1.5 "<<desktop>>"

Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($colTint1)) (New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 2)) 440 85 640 520 8
$g.DrawString("<<host>> Сервер СТО / VPS (Linux + Docker Compose)", (New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 456, 96)

Draw-BoxBW $g 465 135 190 130 "nginx (Reverse Proxy)" "Порт 443 (TLS 1.2/1.3)`nЛимит тела 2 МБ (фото)`nHTTP -> HTTPS redirect" $colWhite 1.6 "<<container>>"
Draw-BoxBW $g 705 135 350 130 "autoservice-api (Cloud API C++17)" "Порт 8080 (внутренняя сеть Docker)`nПул БД 4..32 | /health | JSON-логи`nPushQueueWorker & ReminderScheduler" $colWhite 1.6 "<<container>>"

Draw-BoxBW $g 465 320 275 130 "postgres (PostgreSQL 16)" "Порт 5432 (internal only)`nРасширение btree_gist`nVolume: pg_data (ACID)" $colTint2 1.6 "<<container + volume>>"
Draw-BoxBW $g 780 320 275 130 "Media Volume (IMediaStorage)" "/var/lib/autoservice/media`nФотоотчёты JPEG <= 500 КБ`nКвота 5 ГБ (~10 000 фото)" $colTint2 1.6 "<<docker volume>>"

Draw-BoxBW $g 465 485 590 95 "backup-cron (Резервное копирование)" "Ежедневный pg_dump + rsync медиа-тома в резервное хранилище`nЦелевое время восстановления RTO <= 30 минут (REQ-AVAIL-002) | Доступность >= 99.5%" $colWhite 1.5 "<<container / cron>>"

$extPen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.8)
$extPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($colTint1)) $extPen 1150 85 245 365 8
$g.DrawString("<<external>> Внешние API", (New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 1166, 96)
Draw-BoxBW $g 1170 140 205 120 "NHTSA VIN API" "HTTPS / REST`nТаймаут 3 с, 2 retry`nБесплатный доступ" $colWhite 1.5 ""
Draw-BoxBW $g 1170 295 205 120 "FCM / APNs" "Push-уведомления`nГотовность, доп. работы,`nнапоминания ТО" $colWhite 1.5 ""

Draw-Arrow $g $penBWBold 354 270 465 200 "HTTPS`nTLS 1.3" 0 -22
Draw-Arrow $g $penBW 655 200 705 200 "HTTP" 0 -16
Draw-Arrow $g $penBW 790 265 650 320 "libpq:5432" -34 -14
Draw-Arrow $g $penBW 920 265 920 320 "FS I/O" 28 -8
Draw-Arrow $g $penBW 600 485 600 450 "pg_dump" 34 -8 $true
Draw-Arrow $g $penBW 915 485 915 450 "rsync" 26 -8 $true
Draw-Arrow $g $penBW 1055 180 1170 195 "HTTPS" 0 -16
Draw-Arrow $g $penBW 1055 230 1170 345 "HTTPS" 8 -14

$g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.2)), 0, 0, 1419, 659)
Save-Canvas $c "deployment.png"

# ============================================================================
# 6. PLANS-COMPARISON.PNG (COLOR CHART — ALLOWED TO BE COLOR!)
# ============================================================================
$c = New-Canvas 1480 860
$g = $c.g
Draw-HeaderBW $g 1480 "Сравнение планов реализации AutoService по итерациям (v1 -> v2 -> v2.5 -> v3)" 'Длина итерации: 2 недели | Дедлайн: 5 итераций (29.01.2027) | Ставки: Senior $35/ч, Junior $12/ч'

$plans = @(
    @{
        title = "План v1 (Исходный, 1 Senior)"
        meta  = '6 итераций (12 нед.) | 368 ч | $12,880 | СРЫВ ДЕДЛАЙНА (+2 нед.)'
        statusColor = [System.Drawing.Color]::FromArgb(220, 38, 38)
        iters = @(
            @{ sr = "F01, F02 (64 ч)"; jr = "" },
            @{ sr = "F03, F04, F05 (68 ч)"; jr = "" },
            @{ sr = "F06, F09 (70 ч)"; jr = "" },
            @{ sr = "F07, F08, F13 (68 ч)"; jr = "" },
            @{ sr = "F10 (42ч), F11 (52 ч)"; jr = "" },
            @{ sr = "F12 PDF, F14 (46 ч)"; jr = "" }
        )
    },
    @{
        title = "План v2 (После Раунда 1, 1 Senior)"
        meta  = '5 итераций (10 нед.) | 316 ч | $11,060 | В СРОК (F10 упрощён, F12 -> v1.1)'
        statusColor = [System.Drawing.Color]::FromArgb(37, 99, 235)
        iters = @(
            @{ sr = "F01, F02 (64 ч)"; jr = "" },
            @{ sr = "F03, F04, F05 (68 ч)"; jr = "" },
            @{ sr = "F06, F09 (70 ч)"; jr = "" },
            @{ sr = "F07, F08, F14 (64 ч)"; jr = "" },
            @{ sr = "F10, F11, F13 (50 ч)"; jr = "" },
            @{ sr = ""; jr = "" }
        )
    },
    @{
        title = "План v2.5 (Раунд 2 без Junior, 1 Senior)"
        meta  = '6 итераций (12 нед.) | 376 ч | $13,160 | ОТКЛОНЁН (срыв срока, +$2,100)'
        statusColor = [System.Drawing.Color]::FromArgb(217, 119, 6)
        iters = @(
            @{ sr = "F01, F02 (64 ч)"; jr = "" },
            @{ sr = "F03, F04, F05 (68 ч)"; jr = "" },
            @{ sr = "F06, F09 (70 ч)"; jr = "" },
            @{ sr = "F07, F08, F15.1 (70 ч)"; jr = "" },
            @{ sr = "F15.2-3, F10, F11 (64ч)"; jr = "" },
            @{ sr = "F14, F16 ТО (40 ч)"; jr = "" }
        )
    },
    @{
        title = "План v3 (СОГЛАСОВАННЫЙ: Senior + Junior)"
        meta  = '5 итераций (10 нед.) | 278ч Sr + 150ч Jr | $11,530 | УТВЕРЖДЁН (+4.25% к v2)'
        statusColor = [System.Drawing.Color]::FromArgb(22, 163, 74)
        iters = @(
            @{ sr = "Sr: F01, F02 (64 ч)"; jr = "Jr: не подключён (0 ч)" },
            @{ sr = "Sr: F04, F05 + рев.8ч (56ч)"; jr = "Jr: F03 Гараж (24 ч)" },
            @{ sr = "Sr: F06, F09.1 + рев.6ч (60ч)"; jr = "Jr: F09.2, F14 (32 ч)" },
            @{ sr = "Sr: F07, F08.1, F15.1+6ч (66ч)"; jr = "Jr: F08.2, F15.2-3 (47 ч)" },
            @{ sr = "Sr: F10.1, F16.1+4ч (32ч)"; jr = "Jr: F10.2, F11, F16.2 (47ч)" },
            @{ sr = ""; jr = "" }
        )
    }
)

$leftCol = 320
$colW = 186
$startY = 104
$iterDates = @("Итер. 1 (23.11-04.12)", "Итер. 2 (07.12-18.12)", "Итер. 3 (21.12-01.01)", "Итер. 4 (04.01-15.01)", "Итер. 5 (18.01-29.01)", "Итер. 6 (01.02-12.02)")
for ($i = 0; $i -lt 6; $i++) {
    $x = $leftCol + $i * $colW
    $bg = if ($i -eq 5) { [System.Drawing.Color]::FromArgb(254, 226, 226) } else { [System.Drawing.Color]::FromArgb(241, 245, 249) }
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($bg)), $x, 70, $colW - 4, 28)
    $g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(148, 163, 184), 1)), $x, 70, $colW - 4, 28)
    $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = [System.Drawing.StringAlignment]::Center; $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($iterDates[$i], (New-Object System.Drawing.Font("Segoe UI", 8.8, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, ([System.Drawing.RectangleF]::new($x, 70, ($colW - 4), 28)), $sf)
    $sf.Dispose()
}

$y = $startY
for ($p = 0; $p -lt $plans.Count; $p++) {
    $pl = $plans[$p]
    $rowH = if ($p -eq 3) { 102 } else { 78 }
    $rowBg = if ($p -eq 3) { [System.Drawing.Color]::FromArgb(240, 253, 244) } else { [System.Drawing.Color]::White }
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($rowBg)), 18, $y, 1442, $rowH)
    $g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(203, 213, 225), 1.2)), 18, $y, 1442, $rowH)

    $g.DrawString($pl.title, (New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)), (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))), 26, $y + 10)
    $g.DrawString($pl.meta, (New-Object System.Drawing.Font("Segoe UI", 8.3, [System.Drawing.FontStyle]::Bold)), (New-Object System.Drawing.SolidBrush($pl.statusColor)), ([System.Drawing.RectangleF]::new(26, ($y + 32), 286, 56)))

    for ($i = 0; $i -lt 6; $i++) {
        $x = $leftCol + $i * $colW
        $it = $pl.iters[$i]
        if ($it.sr -ne "") {
            $bFill = if ($i -eq 5) { [System.Drawing.Color]::FromArgb(254, 202, 202) } elseif ($p -eq 3) { [System.Drawing.Color]::FromArgb(187, 247, 208) } else { [System.Drawing.Color]::FromArgb(219, 234, 254) }
            $bPen = if ($i -eq 5) { [System.Drawing.Color]::FromArgb(220, 38, 38) } elseif ($p -eq 3) { [System.Drawing.Color]::FromArgb(22, 163, 74) } else { [System.Drawing.Color]::FromArgb(59, 130, 246) }
            $bh = if ($p -eq 3) { 40 } else { 54 }
            Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($bFill)) (New-Object System.Drawing.Pen($bPen, 1.3)) ($x + 2) ($y + 10) ($colW - 10) $bh 5
            $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = [System.Drawing.StringAlignment]::Center; $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
            $g.DrawString($it.sr, (New-Object System.Drawing.Font("Segoe UI", 8.2, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, ([System.Drawing.RectangleF]::new(($x + 4), ($y + 10), ($colW - 14), $bh)), $sf)
            if ($p -eq 3 -and $it.jr -ne "") {
                $jFill = if ($i -eq 0) { [System.Drawing.Color]::FromArgb(241, 245, 249) } else { [System.Drawing.Color]::FromArgb(254, 243, 199) }
                $jPen = if ($i -eq 0) { [System.Drawing.Color]::FromArgb(148, 163, 184) } else { [System.Drawing.Color]::FromArgb(217, 119, 6) }
                Draw-RoundRect $g (New-Object System.Drawing.SolidBrush($jFill)) (New-Object System.Drawing.Pen($jPen, 1.3)) ($x + 2) ($y + 54) ($colW - 10) 38 5
                $g.DrawString($it.jr, (New-Object System.Drawing.Font("Segoe UI", 8.0, [System.Drawing.FontStyle]::Regular)), [System.Drawing.Brushes]::Black, ([System.Drawing.RectangleF]::new(($x + 4), ($y + 54), ($colW - 14), 38)), $sf)
            }
            $sf.Dispose()
        }
    }
    $y += $rowH + 10
}

$dlX = $leftCol + 5 * $colW - 4
$dlPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 38, 38), 2.8)
$dlPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$g.DrawLine($dlPen, $dlX, 66, $dlX, $y + 4)
$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 38, 38))), $dlX - 74, $y + 4, 148, 22)
$g.DrawString("ДЕДЛАЙН: 29.01.2027", (New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::White, $dlX - 66, $y + 7)

$chartY = 530
$g.DrawString("Сравнение итоговой стоимости ($) и трудозатрат по версиям плана", (New-Object System.Drawing.Font("Segoe UI", 11.5, [System.Drawing.FontStyle]::Bold)), (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))), 24, $chartY)

$bars = @(
    @{ label = "План v1 (Исходный)`n12 нед., 1 Senior"; cost = 12880; srCost = 12880; jrCost = 0; note = '$12,880 (368 ч) – срыв срока'; col = [System.Drawing.Color]::FromArgb(239, 68, 68) },
    @{ label = "План v2 (После R1)`n10 нед., 1 Senior"; cost = 11060; srCost = 11060; jrCost = 0; note = '$11,060 (316 ч) – без F15/F16'; col = [System.Drawing.Color]::FromArgb(59, 130, 246) },
    @{ label = "План v2.5 (R2 без Jr)`n12 нед., 1 Senior"; cost = 13160; srCost = 13160; jrCost = 0; note = '$13,160 (376 ч) – срыв срока'; col = [System.Drawing.Color]::FromArgb(245, 158, 11) },
    @{ label = "План v3 (Согласованный)`n10 нед., Senior + Junior"; cost = 11530; srCost = 9730; jrCost = 1800; note = '$11,530 ($9,730 Sr + $1,800 Jr) – В СРОК!'; col = [System.Drawing.Color]::FromArgb(34, 197, 94) }
)

$maxCost = 14000.0
$barLeft = 240
$barMaxW = 820
$by = $chartY + 38
foreach ($b in $bars) {
    $g.DrawString($b.label, (New-Object System.Drawing.Font("Segoe UI", 9.2, [System.Drawing.FontStyle]::Bold)), (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 41, 59))), 24, $by + 4)
    $srW = [float](($b.srCost / $maxCost) * $barMaxW)
    $jrW = [float](($b.jrCost / $maxCost) * $barMaxW)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($b.col)), $barLeft, $by + 6, $srW, 34)
    if ($jrW -gt 0) {
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(234, 179, 8))), $barLeft + $srW, $by + 6, $jrW, 34)
    }
    $g.DrawString($b.note, (New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)), (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))), $barLeft + $srW + $jrW + 12, $by + 13)
    $by += 58
}

$ceilX = $barLeft + [float]((11800.0 / $maxCost) * $barMaxW)
$ceilPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(15, 23, 42), 2)
$ceilPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot
$g.DrawLine($ceilPen, $ceilX, $chartY + 32, $ceilX, $by + 6)
$g.DrawString('Лимит бюджета Заказчика: $11,800', (New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)), (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(15, 23, 42))), $ceilX - 105, $by + 10)
Save-Canvas $c "plans-comparison.png"

Write-Host "All B&W no-fill UML/ER diagrams and color comparison chart regenerated!"
