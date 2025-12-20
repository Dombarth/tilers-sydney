# Remove UTF-8 BOM from text files so Jekyll can reliably parse front matter.
# (A BOM before '---' can prevent Jekyll from detecting YAML front matter.)

$ErrorActionPreference = 'Stop'

# Files we care about for Jekyll
$patterns = @('*.md', '*.yml', '*.yaml', '*.html', '*.scss', '*.js')

$targets = foreach ($pattern in $patterns) {
  Get-ChildItem -Recurse -File -Filter $pattern | Where-Object { $_.FullName -notmatch '\\_site\\' }
}

# de-dupe
$targets = $targets | Sort-Object FullName -Unique

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$fixed = 0
foreach ($f in $targets) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    # strip BOM
    $text = $utf8NoBom.GetString($bytes, 3, $bytes.Length - 3)
    [System.IO.File]::WriteAllText($f.FullName, $text, $utf8NoBom)
    Write-Host "Removed BOM: $($f.FullName)" -ForegroundColor Green
    $fixed++
  }
}

Write-Host "`nDone - removed BOM from $fixed files" -ForegroundColor Cyan
