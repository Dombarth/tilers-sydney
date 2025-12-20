$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Recurse -Path 'areas/ryde' -Filter '*.md'

# Build mojibake sequences without typing special characters (avoids parser/encoding issues).
# Common UTF-8→Windows-1252 mojibake patterns:
#  ’  => â€™  => "â" + "€" + "™"
#  ‘  => â€˜  => "â" + "€" + "˜"
#  –  => â€“  => "â" + "€" + "“"
#  —  => â€”  => "â" + "€" + "”"
$chA = [char]0x00E2
$chEuro = [char]0x20AC
$chTM = [char]0x2122
$chTilde = [char]0x02DC
$chLdq = [char]0x201C
$chRdq = [char]0x201D

$badRsq = "$chA$chEuro$chTM"
$badLsq = "$chA$chEuro$chTilde"
$badEnDash = "$chA$chEuro$chLdq"
$badEmDash = "$chA$chEuro$chRdq"

foreach ($f in $files) {
  $t = Get-Content -Raw -Encoding UTF8 $f.FullName

  # Fix mojibake punctuation
  $t = $t.Replace($badRsq, "'")
  $t = $t.Replace($badLsq, "'")
  $t = $t.Replace($badEnDash, "-")
  $t = $t.Replace($badEmDash, "-")

  [System.IO.File]::WriteAllText($f.FullName, $t, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ("Normalised punctuation in {0} area files" -f $files.Count) -ForegroundColor Green
