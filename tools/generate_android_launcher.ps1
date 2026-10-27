# Package the owner-approved artwork at Android launcher density sizes.
# Does not alter the design, install the app or publish any artifact.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $projectRoot 'assets/branding/centerly-launcher-v2-approved.png'
$source = [System.Drawing.Image]::FromFile($sourcePath)
try {
    if ($source.Width -ne $source.Height) { throw 'Launcher source must be square' }
    $densities = @{ mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192 }
    foreach ($density in $densities.Keys) {
        $size = $densities[$density]
        $target = Join-Path $projectRoot "android/app/src/main/res/mipmap-$density/ic_launcher.png"
        $bitmap = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.DrawImage($source, 0, 0, $size, $size)
            $bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $graphics.Dispose()
            $bitmap.Dispose()
        }
        $check = [System.Drawing.Image]::FromFile($target)
        try {
            if ($check.Width -ne $size -or $check.Height -ne $size) { throw 'Incorrect launcher dimensions' }
        } finally { $check.Dispose() }
    }
    Write-Output 'PASS: five Android launcher density resources generated and dimensions verified.'
} finally { $source.Dispose() }
