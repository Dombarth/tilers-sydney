$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Recurse -Path 'areas/ryde' -Filter 'index.md'

foreach ($f in $files) {
  $t = Get-Content -Raw -Encoding UTF8 $f.FullName

  # Fix accidental triple braces
  $t = $t -replace '\{\{\{', '{{'
  $t = $t -replace '\}\}\}', '}}'

  # Ensure spacing between the guide list and the next heading
  $t = $t -replace '(\)\r?\n)## Where to go next', "`$1`n## Where to go next"

  [System.IO.File]::WriteAllText($f.FullName, $t, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ("Fixed formatting in {0} suburb pages" -f $files.Count) -ForegroundColor Green
