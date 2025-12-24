# Add SEO-optimized intro paragraphs to suburb pages
# Adds keyword-rich content under H1 for better Google rankings

$suburbs = @{
    "concord" = "Concord"
    "denistone" = "Denistone"
    "denistone-east" = "Denistone East"
    "denistone-west" = "Denistone West"
    "east-ryde" = "East Ryde"
    "eastwood" = "Eastwood"
    "epping" = "Epping"
    "ermington" = "Ermington"
    "gladesville" = "Gladesville"
    "homebush" = "Homebush"
    "huntleys-cove" = "Huntleys Cove"
    "lidcombe" = "Lidcombe"
    "macquarie-park" = "Macquarie Park"
    "marsfield" = "Marsfield"
    "meadowbank" = "Meadowbank"
    "melrose-park" = "Melrose Park"
    "north-ryde" = "North Ryde"
    "north-strathfield" = "North Strathfield"
    "putney" = "Putney"
    "rhodes" = "Rhodes"
    "rydalmere" = "Rydalmere"
    "ryde" = "Ryde"
    "silverwater" = "Silverwater"
    "tennyson-point" = "Tennyson Point"
    "west-ryde" = "West Ryde"
}

foreach ($slug in $suburbs.Keys) {
    $name = $suburbs[$slug]
    $filePath = "areas/ryde/$slug/index.md"
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw -Encoding UTF8
        
        # Create SEO intro paragraph with important ranking keywords
        $seoIntro = @"

Looking for a **professional tiler in $name**? We provide expert **bathroom tiling**, **floor tiling**, **wall tiling**, and **waterproofing services** throughout $name NSW. Whether you need a **local tiler** for a bathroom renovation, kitchen splashback, or complete floor tiling project, our licensed and insured tiling services deliver quality results. Get a **free quote** from an experienced **$name tiler** today.

"@
        
        # Find the position after the front matter closing ---
        # The content after front matter typically starts with "Harbour Tiling services" or "Harbour Tiling works"
        $pattern = "(---\s*\r?\n\r?\n)(Harbour Tiling (?:services|works))"
        
        if ($content -match $pattern) {
            # Insert SEO intro after front matter and before existing content
            $newContent = $content -replace $pattern, "`$1$seoIntro`$2"
            
            # Write back with UTF8 no BOM
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($filePath, $newContent, $utf8NoBom)
            
            Write-Host "Updated: $filePath"
        } else {
            Write-Host "Pattern not found in: $filePath"
        }
    } else {
        Write-Host "File not found: $filePath"
    }
}

Write-Host "`nDone - added SEO intros to suburb pages"
