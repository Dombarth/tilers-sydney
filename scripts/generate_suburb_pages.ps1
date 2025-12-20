$ErrorActionPreference = 'Stop'

$suburbs = @(
  'Ryde',
  'West Ryde',
  'North Ryde',
  'East Ryde',
  'Macquarie Park',
  'Marsfield',
  'Eastwood',
  'Denistone',
  'Denistone East',
  'Denistone West',
  'Meadowbank',
  'Melrose Park',
  'Ermington',
  'Putney',
  'Gladesville',
  'Tennyson Point',
  'Huntleys Cove'
)

# ASCII-only template to avoid encoding issues in some shells.
# Use {0}=suburb, {1}=slug.
# NOTE: Curly braces must be escaped for PowerShell string formatting (-f).
$template = @'
---
layout: page
title: "Tiling in {0}"
subtitle: "Bathroom, kitchen and apartment tiling in {0} - prep-first, planned properly"
description: "Harbour Tiling services {0} from a West Ryde base. What to consider before getting quotes: building type, waterproofing, access logistics, and layout planning."
permalink: /areas/ryde/{1}/
---

Harbour Tiling works across the Ryde district and services **{0}** from a **West Ryde** base.

This page is here to help you make better decisions before you start - especially around **preparation**, **waterproofing coordination**, **layout planning**, and (for apartments) **access logistics**.

## Quick actions

- **Call:** <a href="tel:{{{{ site.data.site.contact.phone_tel }}}}">{{{{ site.data.site.contact.phone_display }}}}</a>
- **Ask a question:** <a href="/contact/#question">Ask a tiling question</a>

---

## What tends to change from job to job in {0}

Even within the same suburb, tiling scope varies depending on what's underneath the existing surface and how the building was constructed.

Typical variables to check:

- **Substrate type** (concrete slab, timber floor, existing tiles)
- **Wet-area history** (older waterproofing, previous leaks, mould)
- **Tile format** (large format needs flatter substrates; mosaics have more grout)
- **Cut placement / setout** (where grout lines and cuts land changes the feel of the room)

## Apartments in {0}: access + strata logistics

If your job is in an apartment block, planning often includes:

- Lift bookings / loading rules
- Noise windows and work hours
- Parking and material delivery
- Waterproofing sequencing + curing time

## What to avoid (common causes of rework)

These are some of the issues that create expensive rework later:

- Tiling over a substrate that isn't flat/solid
- Rushing waterproofing cure times
- Poor setout leading to thin slivers in visible areas
- Selecting tiles not suited to wet areas or floors

## Where to go next

- <a href="/tiling-in-ryde-nsw/">Read: Tiling in Ryde NSW - planning guide</a>
- <a href="/areas/ryde/">Ryde areas hub (all suburb guides)</a>
- <a href="/bathroom-tiling/">Bathroom tiling (scope + what's involved)</a>
- <a href="/kitchen-tiling/">Kitchen tiling (splashbacks, floors)</a>
- <a href="/apartment-tiling/">Apartment tiling (strata & access)</a>
'@

foreach ($suburb in $suburbs) {
  $slug = ($suburb.ToLower() -replace ' ', '-')
  $dirPath = Join-Path -Path 'areas/ryde' -ChildPath $slug
  New-Item -ItemType Directory -Force -Path $dirPath | Out-Null

  $filePath = Join-Path -Path $dirPath -ChildPath 'index.md'
  $content = $template -f $suburb, $slug

  # Explicit UTF-8 without BOM
  [System.IO.File]::WriteAllText($filePath, $content, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ("Generated {0} suburb pages under areas/ryde/" -f $suburbs.Count) -ForegroundColor Green
