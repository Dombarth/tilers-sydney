# Fix old service links in suburb pages after slug updates
$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Recurse -File -Filter '*.md' -Path 'areas\ryde'

foreach ($f in $files) {
  $path = $f.FullName
  $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

  $newContent = $content
  $newContent = $newContent.Replace('href="/bathroom-tiling/"', 'href="/bathroom-tiling-ryde/"')
  $newContent = $newContent.Replace('href="/kitchen-tiling/"', 'href="/kitchen-tiling-ryde/"')
  $newContent = $newContent.Replace('href="/apartment-tiling/"', 'href="/apartment-tiling-ryde/"')
  $newContent = $newContent.Replace('](/bathroom-tiling/)', '](/bathroom-tiling-ryde/)')
  $newContent = $newContent.Replace('](/kitchen-tiling/)', '](/kitchen-tiling-ryde/)')
  $newContent = $newContent.Replace('](/apartment-tiling/)', '](/apartment-tiling-ryde/)')

  if ($newContent -ne $content) {
    [System.IO.File]::WriteAllText($path, $newContent, [System.Text.Encoding]::UTF8)
    Write-Host "Updated: $($f.FullName)" -ForegroundColor Green
  }
}

Write-Host "Done - suburb service links updated" -ForegroundColor Cyan
