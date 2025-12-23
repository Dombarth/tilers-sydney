$ErrorActionPreference = 'Stop'

function Normalize-Url {
  param([string]$Url)
  if (-not $Url) { return $null }

  $u = $Url.Trim()
  if ($u -eq '' -or $u -eq '#') { return $null }

  # Ignore external / non-file schemes
  if ($u -match '^(https?:)?//') { return $null }
  if ($u -match '^(mailto:|tel:|javascript:)') { return $null }

  # Strip query/hash
  $u = ($u -split '[#?]')[0]
  if ($u -eq '') { return $null }

  # Liquid and templates are not resolvable statically
  if ($u -match '\{\{|\{%') { return $null }

  return $u
}

function Should-Ignore-SourceFile {
  param([string]$RelativePath)
  return $RelativePath -match '^(?:_includes|_layouts|_sass|_data|assets|scripts|vendor|node_modules)(/|\\)' -or $RelativePath -match '^\.git(\\|/)' 
}

function Get-JekyllRoute {
  param(
    [string]$RepoRelativePath
  )

  $p = $RepoRelativePath.Replace('\\','/')
  $ext = [System.IO.Path]::GetExtension($p)
  $noExt = $p.Substring(0, $p.Length - $ext.Length)

  if ($p -match '(^|/)index\.(md|html)$') {
    $dir = [System.IO.Path]::GetDirectoryName($p).Replace('\\','/')
    if (-not $dir -or $dir -eq '.') { return '/' }
    return '/' + $dir.Trim('/') + '/'
  }

  return '/' + $noExt.Trim('/') + '/'
}

function Try-Get-FrontMatterPermalink {
  param([string]$FilePath)

  # Only supports simple YAML front matter at top of file.
  # Looks for:
  # ---
  # permalink: /some-path/
  # ---
  try {
    $raw = Get-Content -LiteralPath $FilePath -Raw
  } catch {
    return $null
  }

  # Match YAML front matter strictly at start of file
  # ---\n ... \n---\n
  $fm = [regex]::Match($raw, '(?s)\A---\s*\r?\n(.*?)\r?\n---\s*\r?\n')
  if (-not $fm.Success) { return $null }

  $frontMatter = $fm.Groups[1].Value
  $m = [regex]::Match($frontMatter, '(?im)^\s*permalink\s*:\s*([^\r\n#]+)')
  if (-not $m.Success) { return $null }

  $p = $m.Groups[1].Value.Trim().Trim('"').Trim("'")
  if ($p -eq '') { return $null }
  if (-not $p.StartsWith('/')) { $p = '/' + $p }
  if (-not $p.EndsWith('/')) { $p = $p + '/' }
  return $p
}

function Read-RedirectRoutesFromNetlify {
  param([string]$NetlifyTomlPath)
  if (-not (Test-Path -LiteralPath $NetlifyTomlPath)) { return @() }

  $txt = Get-Content -LiteralPath $NetlifyTomlPath -Raw

  $fromMatches = [regex]::Matches($txt, '(?im)^\s*from\s*=\s*"([^"]+)"\s*$')
  $routes = New-Object System.Collections.Generic.List[string]
  foreach ($m in $fromMatches) {
    $r = $m.Groups[1].Value
    if (-not $r.StartsWith('/')) { $r = '/' + $r }
    if (-not $r.EndsWith('/')) { $r = $r + '/' }
    $routes.Add($r)
  }

  return $routes
}

$repoRoot = (Get-Location).Path

# Discover all page routes (based on permalink: pretty)
$pageFiles = Get-ChildItem -Recurse -File -Include *.md,*.html | Where-Object {
  $_.FullName -notmatch '\\(_site|vendor|node_modules|\.git)\\'
}

$routes = @{}
foreach ($pf in $pageFiles) {
  $rel = $pf.FullName.Replace($repoRoot + '\\','')
  if (Should-Ignore-SourceFile -RelativePath $rel) { continue }

  # ignore sitemap/seo verification as a "route" target
  if ($rel -match '\.xml$' -or $rel -match 'google.*\.html$') { continue }

  $permalink = Try-Get-FrontMatterPermalink -FilePath $pf.FullName
  if ($permalink) {
    $routes[$permalink] = $rel
  } else {
    $routes[(Get-JekyllRoute -RepoRelativePath $rel)] = $rel
  }
}

# Include redirect-only routes (Netlify) so they aren't flagged as broken
foreach ($r in (Read-RedirectRoutesFromNetlify -NetlifyTomlPath (Join-Path $repoRoot 'netlify.toml'))) {
  if (-not $routes.ContainsKey($r)) {
    $routes[$r] = 'netlify.toml (redirect)'
  }
}

# Collect all references from content files
$contentFiles = Get-ChildItem -Recurse -File | Where-Object {
  $_.FullName -notmatch '\\(_site|vendor|node_modules|\.git)\\' -and
  $_.Extension -in @('.html','.md','.yml','.xml','.scss','.js')
}

$brokenAssets = New-Object System.Collections.Generic.List[object]
$brokenRoutes = New-Object System.Collections.Generic.List[object]

$hrefSrcRegex = '(?i)(?:href|src)\s*=\s*(["''])([^"''>]+)\1'
$mdLinkRegex = '(?i)\]\(([^\)\s]+)(?:\s+"[^"]*")?\)'

foreach ($f in $contentFiles) {
  $relFile = $f.FullName.Replace($repoRoot + '\\','')
  $content = Get-Content -LiteralPath $f.FullName -Raw

  $candidates = New-Object System.Collections.Generic.List[string]
  foreach ($m in [regex]::Matches($content, $hrefSrcRegex)) { $candidates.Add($m.Groups[2].Value) }
  foreach ($m in [regex]::Matches($content, $mdLinkRegex)) { $candidates.Add($m.Groups[1].Value) }

  foreach ($raw in $candidates) {
    $u = Normalize-Url -Url $raw
    if (-not $u) { continue }

    # Only validate absolute site paths and explicit relative paths
    $isAbsolute = $u.StartsWith('/')
    $isRelative = $u.StartsWith('./') -or $u.StartsWith('../')
    if (-not ($isAbsolute -or $isRelative)) { continue }

    # Asset file check (absolute)
    if ($u -match '\.(css|js|png|jpe?g|svg|webp|gif|ico|pdf|xml|json)$') {
      $assetRel = $u
      if ($assetRel.StartsWith('/')) { $assetRel = $assetRel.TrimStart('/') }

      # resolve relative assets against the referencing file folder
      if ($isRelative) {
        $baseDir = [System.IO.Path]::GetDirectoryName($relFile)
        if (-not $baseDir) { $baseDir = '' }
        $assetRel = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $repoRoot $baseDir) $u))
        $assetRel = $assetRel.Replace($repoRoot + '\\','')
      }

      $candidate = Join-Path $repoRoot $assetRel
      if (-not (Test-Path -LiteralPath $candidate)) {
        $brokenAssets.Add([pscustomobject]@{
          file = $relFile
          ref = $raw
          resolved = $assetRel.Replace('\\','/')
        })
      }

      continue
    }

    # Route check (absolute only)
    if ($isAbsolute) {
      $route = $u
      if (-not $route.EndsWith('/')) { $route = $route + '/' }

      if (-not $routes.ContainsKey($route)) {
        $brokenRoutes.Add([pscustomobject]@{
          file = $relFile
          ref  = $raw
          normalized = $route
        })
      }
    }
  }
}

if ($brokenAssets.Count -eq 0 -and $brokenRoutes.Count -eq 0) {
  Write-Host 'No broken internal links found.'
  exit 0
}

if ($brokenAssets.Count -gt 0) {
  Write-Host ('Broken internal asset links found: ' + $brokenAssets.Count)
  $brokenAssets | Sort-Object file, resolved | Format-Table -AutoSize
}

if ($brokenRoutes.Count -gt 0) {
  Write-Host ('Broken internal page routes found: ' + $brokenRoutes.Count)
  $brokenRoutes | Sort-Object file, normalized | Format-Table -AutoSize
}

exit 1
