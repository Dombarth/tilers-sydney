$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Recurse -Path 'areas/ryde' -Filter 'index.md'

$guideBlock = @'
## Useful Ryde guides

- [Bathroom tiling cost in Ryde (what drives price)](/bathroom-tiling-cost-ryde/)
- [Waterproofing before tiling in Ryde (sequence + cure time)](/waterproofing-before-tiling-ryde/)
- [Apartment tiling in Ryde (strata logistics)](/apartment-tiling-ryde-strata/)

'@

foreach ($f in $files) {
  $text = Get-Content -Raw -Encoding UTF8 $f.FullName

  if ($text -match '## Useful Ryde guides') {
    continue
  }

  if ($text -match '## Where to go next') {
    $text = $text -replace '## Where to go next', ($guideBlock + '## Where to go next')
  }
  else {
    # Fallback: append near end
    $text = $text + "`n`n" + $guideBlock
  }

  [System.IO.File]::WriteAllText($f.FullName, $text, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ("Inserted guide links into suburb pages: {0}" -f $files.Count) -ForegroundColor Green
