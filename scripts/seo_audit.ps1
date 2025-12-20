$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -Recurse -File -Filter '*.md' | Where-Object { $_.FullName -notmatch '\\_site\\' }

$rows = foreach ($f in $files) {
  $c = Get-Content -Raw -Encoding UTF8 $f.FullName

  $mTitle = [regex]::Match($c, '(?m)^title:\s*"([^"]+)"\s*$')
  $mSeo = [regex]::Match($c, '(?m)^seo_title:\s*"([^"]+)"\s*$')
  $mDesc = [regex]::Match($c, '(?m)^description:\s*"([^"]+)"\s*$')
  $mPerm = [regex]::Match($c, '(?m)^permalink:\s*([^\r\n]+)\s*$')

  [pscustomobject]@{
    file        = $f.FullName.Replace((Get-Location).Path + '\\', '')
    permalink   = $mPerm.Groups[1].Value
    seo_title   = $mSeo.Groups[1].Value
    title       = $mTitle.Groups[1].Value
    description = $mDesc.Groups[1].Value
  }
}

$rows | Sort-Object file | Export-Csv -NoTypeInformation -Encoding UTF8 .\seo_audit.csv
Write-Host 'Wrote seo_audit.csv' -ForegroundColor Green
