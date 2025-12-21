# Fix page titles across all pages:
# 1. Remove " | Harbour Tiling" from endings
# 2. Replace " | " with ": " (proper spacing)

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
    
    # Step 1: Remove " | Harbour Tiling" suffix from title and seo_title
    $content = $content -replace '(title:\s*"[^"]*)\s*\|\s*Harbour Tiling"', '$1"'
    $content = $content -replace '(seo_title:\s*"[^"]*)\s*\|\s*Harbour Tiling"', '$1"'
    
    # Step 2: Replace all " | " with ": " in title field (handles multiple pipes)
    # Loop until no more replacements needed
    while ($content -match '(title:\s*"[^"]*)\s+\|\s+') {
        $content = $content -replace '(title:\s*"[^"]*)\s+\|\s+', '$1: '
    }
    
    # Step 3: Replace all " | " with ": " in seo_title field
    while ($content -match '(seo_title:\s*"[^"]*)\s+\|\s+') {
        $content = $content -replace '(seo_title:\s*"[^"]*)\s+\|\s+', '$1: '
    }
    
    if ($content -ne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        Write-Host "Fixed: $($file.FullName)" -ForegroundColor Green
        $fixed++
    }
}

Write-Host ""
Write-Host "Done - fixed $fixed files" -ForegroundColor Cyan
