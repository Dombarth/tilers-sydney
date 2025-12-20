# Remove em dashes from all markdown files
$ErrorActionPreference = 'Stop'

# Em dash is Unicode U+2014
$emDash = [char]0x2014

$files = Get-ChildItem -Recurse -File -Filter '*.md' | Where-Object { $_.FullName -notmatch '\\_site\\' }

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $newContent = $content.Replace($emDash, '-')
    
    if ($content -ne $newContent) {
        [System.IO.File]::WriteAllText($f.FullName, $newContent, [System.Text.Encoding]::UTF8)
        Write-Host "Fixed: $($f.Name)" -ForegroundColor Green
    }
}

Write-Host "`nDone - em dashes removed from all markdown files" -ForegroundColor Cyan
