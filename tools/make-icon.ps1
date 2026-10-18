Add-Type -AssemblyName System.Drawing

$size = 512
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# ===== Background: blue diagonal gradient (full bleed for maskable) =====
$gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Point(0, 0)),
  (New-Object System.Drawing.Point($size, $size)),
  [System.Drawing.Color]::FromArgb(59, 130, 246),
  [System.Drawing.Color]::FromArgb(29, 78, 216)
)
$g.FillRectangle($gradBrush, 0, 0, $size, $size)

# ===== Helper: rounded rectangle path =====
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

# ===== Wallet body (white) =====
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$walletPath = New-RoundedRect 86 156 340 232 36
$g.FillPath($white, $walletPath)

# ===== Wallet card slot (light blue stripe at top of body) =====
$lightBlue = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(219, 234, 254))
$flapPath = New-RoundedRect 126 126 180 80 28
$g.FillPath($lightBlue, $flapPath)

# ===== Card peeking out =====
$cardBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(147, 197, 253))
$cardPath = New-RoundedRect 146 96 140 90 18
$g.FillPath($cardBrush, $cardPath)

# ===== Clasp button (gold circle with ring) =====
$goldOuter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 158, 11))
$g.FillEllipse($goldOuter, 316, 230, 76, 76)
$goldInner = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(251, 191, 36))
$g.FillEllipse($goldInner, 330, 244, 48, 48)
$goldCore = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(217, 119, 6))
$g.FillEllipse($goldCore, 342, 256, 24, 24)

# ===== Coin (gold, bottom left, overlapping wallet) =====
$coinShadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 0, 0, 0))
$g.FillEllipse($coinShadow, 68, 366, 132, 132)
$coinOuter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 158, 11))
$g.FillEllipse($coinOuter, 60, 358, 132, 132)
$coinInner = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(252, 211, 77))
$g.FillEllipse($coinInner, 76, 374, 100, 100)

# Riyal-ish glyph on coin: draw a simple "﷼"-like symbol with shapes
# Vertical stroke
$glyphBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 83, 9))
$g.FillRectangle($glyphBrush, 118, 392, 14, 64)
# Two diagonal strokes (like Arabic numeral strokes)
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 83, 9), 13)
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($pen, 106, 412, 146, 400)
$g.DrawLine($pen, 106, 434, 146, 422)

# ===== Cleanup =====
$g.Dispose()
$bmp.Save("C:\pinokio\api\finance-tracker\icon.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Also save 192x192 variant
$bmp192 = New-Object System.Drawing.Bitmap($bmp, 192, 192)
$g2 = [System.Drawing.Graphics]::FromImage($bmp192)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g2.Dispose()
$bmp192.Save("C:\pinokio\api\finance-tracker\icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)

$bmp192.Dispose()
$bmp.Dispose()

Write-Host "Icons created successfully"
