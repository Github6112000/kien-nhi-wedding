# Temporary: preview pages + headless Edge screenshots at an exact 390px mobile width. Deleted after verification.
$web = "d:\VTVLive\thiepcuoi\web"
$out = "d:\VTVLive\thiepcuoi\_shots"
New-Item -ItemType Directory -Force -Path $out | Out-Null
Remove-Item "$out\*.png", "$out\log.txt" -ErrorAction SilentlyContinue
$html = Get-Content "$web\index.html" -Raw -Encoding UTF8

$site = "document.querySelectorAll('img[loading=lazy]').forEach(function(i){i.loading='eager'});" +
        "document.getElementById('env-screen').hidden=true;document.getElementById('site').hidden=false;" +
        "document.body.classList.remove('is-locked');document.querySelectorAll('.reveal').forEach(function(n){n.classList.add('is-visible')});"
$inject = "<script>window.addEventListener('DOMContentLoaded',function(){setTimeout(function(){" + $site + "},50)});</script></body>"
($html -replace "</body>", $inject) | Set-Content -Path "$web\_p_site.html" -Encoding UTF8

function Wrap($name, $src, $h, $offset) {
  $w = "<!doctype html><html><body style='margin:0;background:#fff'><iframe src='$src' width='390' height='$h' style='border:0;display:block;margin-top:-${offset}px'></iframe></body></html>"
  Set-Content -Path "$web\$name.html" -Value $w -Encoding UTF8
}
Wrap "_w_intro" "index.html?khach=Anh%20Minh%20%26%20Ch%E1%BB%8B%20Lan" 844 0
$offsets = 0, 1250, 2500, 3750, 5000, 6250
foreach ($o in $offsets) { Wrap "_w_site_$o" "_p_site.html" 8200 $o }

$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$base = "http://localhost:8081"
$jobs = @(@{ name = "1-intro"; url = "$base/_w_intro.html"; size = "520,844" })
foreach ($o in $offsets) { $jobs += @{ name = "4-site-$o"; url = "$base/_w_site_$o.html"; size = "520,1250" } }
$jobs += @{ name = "5-desk"; url = "$base/index.html"; size = "1280,900" }

foreach ($j in $jobs) {
  $file = "$out\$($j.name).png"
  $p = Start-Process -FilePath $edge -PassThru -WindowStyle Hidden -ArgumentList @(
    "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
    "--user-data-dir=$out\profile", "--window-size=$($j.size)",
    "--virtual-time-budget=8000", "--screenshot=$file", $j.url)
  $p.WaitForExit(60000) | Out-Null
  Add-Content "$out\log.txt" "$($j.name): $(Test-Path $file)"
}
Add-Content "$out\log.txt" "ALL DONE"
