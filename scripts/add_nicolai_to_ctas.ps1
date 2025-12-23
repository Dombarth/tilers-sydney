# Add "Nicolai" to all call CTAs in markdown files
$files = Get-ChildItem -Path . -Include *.md -Recurse | Where-Object { $_.FullName -notmatch 'node_modules|vendor' }

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $original = $content
    
    # Update "Call {{ site.data.site.contact.phone_display }}" to "Call Nicolai: {{ site.data.site.contact.phone_display }}"
    $content = $content -replace 'Call \{\{ site\.data\.site\.contact\.phone_display \}\}', 'Call Nicolai: {{ site.data.site.contact.phone_display }}'
    
    # Update "call <a href=..." patterns (inline text)
    $content = $content -replace ', call (<a href="tel:[^"]+">)', ', call Nicolai on $1'
    
    # Update "**Call:**" to "**Call Nicolai:**" in suburb pages
    $content = $content -replace '\*\*Call:\*\*', '**Call Nicolai:**'
    
    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "Done!"
