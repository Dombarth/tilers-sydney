# Update suburb page titles and subtitles for better SEO
# Pattern: "Tiler [Suburb] | Bathroom & Floor Tiling [Suburb] NSW"

$suburbDirs = Get-ChildItem -Path "areas/ryde" -Directory

foreach ($dir in $suburbDirs) {
    $indexPath = Join-Path $dir.FullName "index.md"
    
    if (Test-Path $indexPath) {
        $content = Get-Content $indexPath -Raw -Encoding UTF8
        
        # Extract suburb name from directory (convert slug to proper name)
        $suburbSlug = $dir.Name
        
        # Convert slug to proper suburb name
        $suburbName = switch ($suburbSlug) {
            "concord" { "Concord" }
            "denistone" { "Denistone" }
            "denistone-east" { "Denistone East" }
            "denistone-west" { "Denistone West" }
            "east-ryde" { "East Ryde" }
            "eastwood" { "Eastwood" }
            "epping" { "Epping" }
            "ermington" { "Ermington" }
            "gladesville" { "Gladesville" }
            "homebush" { "Homebush" }
            "huntleys-cove" { "Huntleys Cove" }
            "lidcombe" { "Lidcombe" }
            "macquarie-park" { "Macquarie Park" }
            "marsfield" { "Marsfield" }
            "meadowbank" { "Meadowbank" }
            "melrose-park" { "Melrose Park" }
            "north-ryde" { "North Ryde" }
            "north-strathfield" { "North Strathfield" }
            "putney" { "Putney" }
            "rhodes" { "Rhodes" }
            "rydalmere" { "Rydalmere" }
            "ryde" { "Ryde" }
            "silverwater" { "Silverwater" }
            "tennyson-point" { "Tennyson Point" }
            "west-ryde" { "West Ryde" }
            default { $suburbSlug -replace '-', ' ' -replace '\b(\w)', { $_.Groups[1].Value.ToUpper() } }
        }
        
        # New title format: "Tiler [Suburb] | Bathroom & Floor Tiling NSW" (suburb only once)
        $newTitle = "Tiler $suburbName | Bathroom & Floor Tiling NSW"
        
        # New subtitle format: "Professional tiling services in [Suburb] - bathrooms, kitchens, waterproofing"
        $newSubtitle = "Professional tiling services in $suburbName - bathrooms, kitchens, waterproofing"
        
        # New description format
        $newDescription = "Expert tiler in $suburbName NSW. Bathroom tiling, kitchen tiling, wall & floor tiling, waterproofing. Licensed and insured. Local service from Ryde."
        
        # Replace title (matches both old and new formats)
        $content = $content -replace 'title: "Tiler [^"]+"', "title: `"$newTitle`""
        $content = $content -replace 'title: "Tiling in [^"]+"', "title: `"$newTitle`""
        
        # Replace subtitle
        $content = $content -replace 'subtitle: "[^"]+"', "subtitle: `"$newSubtitle`""
        
        # Replace description
        $content = $content -replace 'description: "[^"]+"', "description: `"$newDescription`""
        
        # Save file
        $content | Set-Content $indexPath -Encoding UTF8 -NoNewline
        
        Write-Host "Updated: $suburbName"
    }
}

Write-Host ""
Write-Host "All suburb pages updated!"
