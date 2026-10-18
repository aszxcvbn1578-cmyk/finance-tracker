Add-Type -AssemblyName System.Drawing

# ==============================================================
#  Icon generator for all platforms (PWA + Android)
#  Design: white wallet + card + gold clasp + gold coin
# ==============================================================

$root = "C:\pinokio\api\finance-tracker"

# ---------- Gradient background ----------
function Draw-GradientBg($g, $size) {
  $gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point($size, $size)),
    [System.Drawing.Color]::FromArgb(59, 130, 246),
    [System.Drawing.Color]::FromArgb(29, 78, 216)
  )
  $g.FillRectangle($gradBrush, 0, 0, $size, $size)
  $gradBrush.Dispose()
}

# ---------- Rounded rectangle path ----------
function New-RoundedRect($x, $y, $w, $h, $r) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

# ---------- Wallet art in design coordinates (512x512) ----------
# Art bounding box: x 60..426, y 96..490  => center (243, 293), extent 394
function Draw-WalletArt($g, $targetSize, $artFraction) {
  if ($artFraction -le 0) { return }
  $scale = ($targetSize * $artFraction) / 394.0
  $tx = $targetSize / 2.0 - 243 * $scale
  $ty = $targetSize / 2.0 - 293 * $scale

  $state = $g.Save()
  $g.TranslateTransform($tx, $ty)
  $g.ScaleTransform($scale, $scale)

  # Wallet body (white)
  $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
  $walletPath = New-RoundedRect 86 156 340 232 36
  $g.FillPath($white, $walletPath)
  $walletPath.Dispose(); $white.Dispose()

  # Top flap (light blue)
  $lightBlue = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(219, 234, 254))
  $flapPath = New-RoundedRect 126 126 180 80 28
  $g.FillPath($lightBlue, $flapPath)
  $flapPath.Dispose(); $lightBlue.Dispose()

  # Card (lighter blue)
  $cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(147, 197, 253))
  $cardPath = New-RoundedRect 146 96 140 90 18
  $g.FillPath($cardBrush, $cardPath)
  $cardPath.Dispose(); $cardBrush.Dispose()

  # Gold clasp button
  $goldOuter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 158, 11))
  $g.FillEllipse($goldOuter, 316, 230, 76, 76)
  $goldOuter.Dispose()
  $goldInner = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(251, 191, 36))
  $g.FillEllipse($goldInner, 330, 244, 48, 48)
  $goldInner.Dispose()
  $goldCore = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(217, 119, 6))
  $g.FillEllipse($goldCore, 342, 256, 24, 24)
  $goldCore.Dispose()

  # Gold coin (bottom left)
  $coinShadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 0, 0, 0))
  $g.FillEllipse($coinShadow, 68, 366, 132, 132)
  $coinShadow.Dispose()
  $coinOuter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 158, 11))
  $g.FillEllipse($coinOuter, 60, 358, 132, 132)
  $coinOuter.Dispose()
  $coinInner = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(252, 211, 77))
  $g.FillEllipse($coinInner, 76, 374, 100, 100)
  $coinInner.Dispose()

  # Currency glyph on coin
  $glyphBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 83, 9))
  $g.FillRectangle($glyphBrush, 118, 392, 14, 64)
  $glyphBrush.Dispose()
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 83, 9), 13)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($pen, 106, 412, 146, 400)
  $g.DrawLine($pen, 106, 434, 146, 422)
  $pen.Dispose()

  $g.Restore($state)
}

# ---------- Create one icon image ----------
function New-Icon($size, $artFraction, $withBg, $outPath) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

  if ($withBg) { Draw-GradientBg $g $size }
  Draw-WalletArt $g $size $artFraction

  $g.Dispose()
  $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host ("  OK " + $outPath + " (" + $size + ")")
}

# ==============================================================
#  1) PWA icons (repo root)
# ==============================================================
Write-Host "PWA icons:"
New-Icon 512 0.78 $true  "$root\icon.png"
New-Icon 192 0.78 $true  "$root\icon-192.png"

# ==============================================================
#  2) Android assets (Capacitor Assets - custom mode)
# ==============================================================
$assetsDir = "$root\mobile\assets"
New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null

Write-Host "Android assets:"
# Full icon (legacy devices)
New-Icon 1024 0.75 $true  "$assetsDir\icon-only.png"
# Foreground layer (transparent, inside safe zone)
New-Icon 1024 0.58 $false "$assetsDir\icon-foreground.png"
# Background layer (gradient only)
New-Icon 1024 0.0  $true  "$assetsDir\icon-background.png"
# Splash screen (2732x2732)
New-Icon 2732 0.25 $true  "$assetsDir\splash.png"

Write-Host ""
Write-Host "All icons generated successfully!"
