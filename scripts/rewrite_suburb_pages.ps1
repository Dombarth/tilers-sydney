# Rewrite suburb pages with human writing style
# Uses the specific patterns from the human writing prompt

$suburbs = @{
    "concord" = "Concord"
    "denistone" = "Denistone"
    "denistone-east" = "Denistone East"
    "denistone-west" = "Denistone West"
    "east-ryde" = "East Ryde"
    "eastwood" = "Eastwood"
    "epping" = "Epping"
    "ermington" = "Ermington"
    "gladesville" = "Gladesville"
    "homebush" = "Homebush"
    "huntleys-cove" = "Huntleys Cove"
    "lidcombe" = "Lidcombe"
    "macquarie-park" = "Macquarie Park"
    "marsfield" = "Marsfield"
    "meadowbank" = "Meadowbank"
    "melrose-park" = "Melrose Park"
    "north-ryde" = "North Ryde"
    "north-strathfield" = "North Strathfield"
    "putney" = "Putney"
    "rhodes" = "Rhodes"
    "rydalmere" = "Rydalmere"
    "ryde" = "Ryde"
    "silverwater" = "Silverwater"
    "tennyson-point" = "Tennyson Point"
    "west-ryde" = "West Ryde"
}

foreach ($slug in $suburbs.Keys) {
    $name = $suburbs[$slug]
    $filePath = "areas/ryde/$slug/index.md"
    
    # Create human-style content for each suburb
    $content = @"
---
layout: page
title: "Tiler $name`: Bathroom & Floor Tiling NSW"
subtitle: "Professional tiling services in $name"
description: "Expert tiler in $name NSW. Bathroom tiling, kitchen tiling, wall & floor tiling, waterproofing. Licensed and insured. Local service from Ryde."
permalink: /areas/ryde/$slug/
---

At Harbour Tiling we specialise in the areas of bathroom tiling, kitchen tiling, floor tiling and waterproofing for customers in $name and surrounding suburbs. The team have been providing tiling services across the Ryde region for many years and are fully licensed to carry out all aspects of wall and floor tiling work.

We service customers throughout $name for residential and commercial tiling projects. Harbour Tiling are fully insured and all work carried out comes with a guarantee on workmanship. As such we are able to offer customers quality results while still remaining competitive on pricing.

The tilers at Harbour Tiling pride themselves on attention to detail and proper preparation before tiling commences. This includes checking substrate conditions, coordinating waterproofing for wet areas and planning tile layouts to avoid awkward cuts in visible areas.

Our tiling services in $name include bathroom tiling, kitchen splashback tiling, floor tiling, wall tiling, outdoor tiling and waterproofing coordination. We work with ceramic tiles, porcelain tiles, natural stone and large format tiles depending on what is required for the job.

For apartment tiling in $name we have experience with strata logistics including lift bookings, parking coordination and working within building noise restrictions. The team have completed tiling projects across the Ryde area including West Ryde, Eastwood, Epping, Gladesville and surrounding suburbs areas.

At Harbour Tiling we take pride in providing quality tiling services to customers in $name.

<div class="cta-actions" style="margin-top: 2rem;">
  <a href="tel:{{ site.data.site.contact.phone_tel }}" class="btn btn-primary btn-lg">Call Nicolai: {{ site.data.site.contact.phone_display }}</a>
  <a href="/contact/" class="btn btn-secondary btn-lg">Request a Quote</a>
</div>
"@

    # Write the file
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
    
    Write-Host "Updated: $filePath"
}

Write-Host "`nDone - rewrote all suburb pages with human writing style"
