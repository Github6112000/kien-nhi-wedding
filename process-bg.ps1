# Re-run only the background step: re-copy the original (3) and rebuild the tile.
$src = Get-ChildItem "d:\VTVLive\thiepcuoi" -Directory | Where-Object { $_.Name -like "chi ti*" } | Select-Object -First 1
$orig = Get-ChildItem -LiteralPath $src.FullName -Filter "*(3).png" | Select-Object -First 1
$img = "d:\VTVLive\thiepcuoi\web\assets\images"
Copy-Item -LiteralPath $orig.FullName -Destination (Join-Path $img "bg-wine.png") -Force

# reuse the C# helper from process-assets.ps1 (only its type definition)
$text = Get-Content "d:\VTVLive\thiepcuoi\process-assets.ps1" -Raw
$code = [regex]::Match($text, '(?s)\$code = @"\r?\n(.*?)\r?\n"@').Groups[1].Value
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing
$info = [ImgTool]::MakeBgTile((Join-Path $img "bg-wine.png"), (Join-Path $img "bg-wine.jpg"), 92)
Remove-Item (Join-Path $img "bg-wine.png")
Add-Content "d:\VTVLive\thiepcuoi\process.txt" "bg v2: $info"
