Add-Type -AssemblyName System.Drawing
# folder name has Vietnamese characters; find it by wildcard to avoid script-encoding issues
$dir = (Get-ChildItem "d:\VTVLive\thiepcuoi" -Directory | Where-Object { $_.Name -like "chi ti*" } | Select-Object -First 1).FullName
$log = "d:\VTVLive\thiepcuoi\inspect.txt"
Set-Content $log "start dir=$dir" -Encoding UTF8

# copy the detail images into the site with ASCII names
$dest = "d:\VTVLive\thiepcuoi\web\assets\images"
$map = @{ "*(1).png" = "hands-envelope.png"; "*(2).png" = "flowers.png"; "*(3).png" = "bg-wine.png" }
foreach ($k in $map.Keys) {
  $src = Get-ChildItem -LiteralPath $dir -Filter $k | Select-Object -First 1
  Copy-Item -LiteralPath $src.FullName -Destination (Join-Path $dest $map[$k]) -Force
  Add-Content $log "copied $($src.Name) -> $($map[$k])"
}
Get-ChildItem -LiteralPath $dir -Filter *.png | Sort-Object Name | ForEach-Object {
  $b = New-Object System.Drawing.Bitmap($_.FullName)
  # count transparent pixels on a sparse grid
  $t = 0; $n = 0
  for ($y = 0; $y -lt $b.Height; $y += 4) { for ($x = 0; $x -lt $b.Width; $x += 4) { $n++; if ($b.GetPixel($x,$y).A -lt 20) { $t++ } } }
  Add-Content $log ("{0}: {1}x{2} fmt={3} transparent={4:P0}" -f $_.Name, $b.Width, $b.Height, $b.PixelFormat, ($t / [math]::Max(1,$n)))
  $b.Dispose()
}

# (1) locate the gold wax seal: warm, bright, saturated pixels
$f1 = Get-ChildItem -LiteralPath $dir -Filter "*(1).png" | Select-Object -First 1
$b = New-Object System.Drawing.Bitmap($f1.FullName)
$minX=1e9;$minY=1e9;$maxX=-1;$maxY=-1;$c=0
for ($y = 0; $y -lt $b.Height; $y++) { for ($x = 0; $x -lt $b.Width; $x++) {
  $p = $b.GetPixel($x,$y)
  if ($p.A -gt 200 -and $p.R -gt 150 -and $p.G -gt 100 -and $p.B -lt 120 -and ($p.R - $p.B) -gt 70 -and ($p.G - $p.B) -gt 30) {
    $c++; if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}; if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
  } } }
Add-Content $log "SEAL gold px=$c bbox=($minX,$minY)-($maxX,$maxY) of $($b.Width)x$($b.Height)"
# envelope (burgundy) bbox
$minX=1e9;$minY=1e9;$maxX=-1;$maxY=-1
for ($y = 0; $y -lt $b.Height; $y+=2) { for ($x = 0; $x -lt $b.Width; $x+=2) {
  $p = $b.GetPixel($x,$y)
  if ($p.A -gt 200 -and $p.R -gt 60 -and $p.R -lt 170 -and $p.G -lt 60 -and $p.B -lt 80) {
    if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}; if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
  } } }
Add-Content $log "ENVELOPE bbox=($minX,$minY)-($maxX,$maxY)"
$b.Dispose()

# (3) background: brightness per horizontal band to find the line + dot
$f3 = Get-ChildItem -LiteralPath $dir -Filter "*(3).png" | Select-Object -First 1
$b = New-Object System.Drawing.Bitmap($f3.FullName)
$bands = 20; $bh = [math]::Max(1, [int]($b.Height / $bands))
for ($i = 0; $i -lt $bands; $i++) {
  $s=0;$k=0;$mx=0
  for ($y = $i*$bh; $y -lt [math]::Min($b.Height, ($i+1)*$bh); $y++) { for ($x = 0; $x -lt $b.Width; $x += 3) {
    $p = $b.GetPixel($x,$y); $l = ($p.R + $p.G + $p.B)/3; $s += $l; $k++; if ($l -gt $mx) { $mx = $l } } }
  Add-Content $log ("BG band {0,2} y{1}: avg={2:N1} max={3:N0}" -f $i, ($i*$bh), ($s/[math]::Max(1,$k)), $mx)
}
# average colour
$r=0;$g=0;$bb=0;$k=0
for ($y = 0; $y -lt $b.Height; $y += 3) { for ($x = 0; $x -lt $b.Width; $x += 3) { $p=$b.GetPixel($x,$y); $r+=$p.R;$g+=$p.G;$bb+=$p.B;$k++ } }
Add-Content $log ("BG avg #{0:X2}{1:X2}{2:X2}" -f [int]($r/$k),[int]($g/$k),[int]($bb/$k))
$b.Dispose()
Add-Content $log "done"
