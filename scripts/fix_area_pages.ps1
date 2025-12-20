$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Recurse -Path 'areas/ryde' -Filter '*.md'

# Build mojibake sequences without typing special characters.
# Common UTF-8→Windows-1252 mojibake patterns:
#  ’  => â€™  => "â" + "€" + "™"
#  ‘  => â€˜  => "â" + "€" + "˜"
#  –  => â€“  => "â" + "€" + "“"
#  —  => â€”  => "â" + "€" + "”"
$chA = [char]0x00E2   # â
$chEuro = [char]0x20AC # €
$chTM = [char]0x2122   # ™
$chTilde = [char]0x02DC # ˜
$chLdq = [char]0x201C  # “
$chRdq = [char]0x201D  # ”

$badRsq = "$chA$chEuro$chTM"     # â€™
$badLsq = "$chA$chEuro$chTilde"  # â€˜
$badEnDash = "$chA$chEuro$chLdq" # â€“
$badEmDash = "$chA$chEuro$chRdq" # â€”

foreach ($f in $files) {
  $text = Get-Content -Raw -Encoding UTF8 $f.FullName

  # Fix Liquid braces that got lost (e.g. { site.data.site... })
  $text = $text -replace '\{\s*site\.data\.site', '{{ site.data.site'
  $text = $text -replace '\}\s*\}', '}}'

  # Fix mojibake punctuation
  $text = $text.Replace($badRsq, "'")
  $text = $text.Replace($badLsq, "'")
  $text = $text.Replace($badEnDash, "-")
  $text = $text.Replace($badEmDash, "-")

  [System.IO.File]::WriteAllText($f.FullName, $text, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ("Fixed {0} area page files" -f $files.Count) -ForegroundColor Green
