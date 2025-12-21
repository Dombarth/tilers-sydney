# Fix trailing spaces in title fields

$ErrorActionPreference = 'Stop'

# Get all markdown files
$mdFiles = Get-ChildItem -Recurse -Filter "*.md" | Where-Object { 
    $_.FullName -notmatch '\\_site\\' -and 
    $_.Name -ne "README.md" -and 
    $_.Name -ne "CLINE_INSTRUCTIONS.md"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$fixed = 0

foreach ($file in $mdFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $originalContent = $content
    
    # Remove trailing spaces before closing quote in title fields
    $content = $content -replace '(title:\s*"[^"]*)\s+"', '$1"'
    $content = $content -replace '(seo_title:\s*"[^"]*)\s+"', '$1"'
    
    if ($content -ne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        Write-Host "Fixed: $($file.FullName)" -ForegroundColor Green
        $fixed++
    }
}

Write-Host ""
Write-Host "Done - fixed $fixed files" -ForegroundColor Cyan
