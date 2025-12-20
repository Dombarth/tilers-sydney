$ErrorActionPreference = 'Stop'

$suburbs = @(
  'Rhodes',
  'Epping',
  'Concord',
  'North Strathfield',
  'Homebush',
  'Lidcombe',
  'Rydalmere',
  'Silverwater'
)

# NOTE: Curly braces must be escaped for PowerShell string formatting (-f).
$template = @'
---
layout: page
title: "Tiling in {0}"
subtitle: "Bathroom, kitchen and apartment tiling in {0} - planned properly and coordinated"
description: "Harbour Tiling services {0} from a West Ryde base. Practical tiling planning: access logistics, waterproofing sequencing, substrate checks, and layout planning."
permalink: /areas/ryde/{1}/
---

Harbour Tiling services **{0}** from a **West Ryde** base.

This page is designed to answer the practical questions that matter before you get quotes: **prep**, **waterproofing sequencing**, **layout planning**, and (where relevant) **apartment access logistics**.

## Quick actions

- **Call:** <a href="tel:{{{{ site.data.site.contact.phone_tel }}}}">{{{{ site.data.site.contact.phone_display }}}}</a>
- **Ryde areas hub:** <a href="/areas/ryde/">All suburb guides</a>

---

## What usually changes scope in {0}

- **What’s under the existing surface** (concrete, timber, old tiles)
- **Wet-area history** (previous leaks, unknown waterproofing)
- **Tile size and finish** (large format needs flatter substrates)
- **Access constraints** (parking, deliveries, strata rules)

## Useful Ryde guides

- [Bathroom tiling cost in Ryde (what drives price)](/bathroom-tiling-cost-ryde/)
- [Waterproofing before tiling in Ryde (sequence + cure time)](/waterproofing-before-tiling-ryde/)
- [Apartment tiling in Ryde (strata logistics)](/apartment-tiling-ryde-strata/)

## Where to go next

- <a href="/tiling-in-ryde-nsw/">Tiling in Ryde NSW - planning guide</a>
- <a href="/bathroom-tiling/">Bathroom tiling</a>
- <a href="/kitchen-tiling/">Kitchen tiling</a>
- <a href="/apartment-tiling/">Apartment tiling</a>
'@

foreach ($suburb in $suburbs) {
  $slug = ($suburb.ToLower() -replace ' ', '-')
  $dirPath = Join-Path -Path 'areas/ryde' -ChildPath $slug
  New-Item -ItemType Directory -Force -Path $dirPath | Out-Null

  $filePath = Join-Path -Path $dirPath -ChildPath 'index.md'
  $content = $template -f $suburb, $slug

  [System.IO.File]::WriteAllText($filePath, $content, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ("Generated {0} ring suburb pages under areas/ryde/" -f $suburbs.Count) -ForegroundColor Green
