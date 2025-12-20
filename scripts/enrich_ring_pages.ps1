$ErrorActionPreference = 'Stop'

# Target: Wave-2 ring suburb pages we generated (high-value, not thin)
$ring = @(
  @{ suburb = 'Rhodes'; slug = 'rhodes'; notes = @(
      'High apartment density: access planning (lifts, loading, protection) often matters more than the tiling itself.'
      'Expect stricter noise windows for demolition and cutting in many buildings.'
      'If it is a bathroom/laundry retile, sequence and cure time are the difference between a smooth job and rework.'
    )
  },
  @{ suburb = 'Epping'; slug = 'epping'; notes = @(
      'Mixed stock (older houses + newer apartments): the biggest variable is what is under the existing surface (timber vs concrete).'
      'Large-format tiles demand flatter substrates; prep scope is often what changes the quote.'
      'If you are in an apartment, confirm lift/parking rules early so the schedule is realistic.'
    )
  },
  @{ suburb = 'Concord'; slug = 'concord'; notes = @(
      'A lot of work is house renovations and re-tiles: expect variation in older waterproofing history.'
      'Timber floors and movement are common drivers of extra prep in older bathrooms.'
      'Setout planning (where cuts land) is often the main quality differentiator on feature walls and bathrooms.'
    )
  },
  @{ suburb = 'North Strathfield'; slug = 'north-strathfield'; notes = @(
      'A mix of apartments and houses: access logistics and substrate type both matter.'
      'Where parking is tight, deliveries and waste runs can extend the schedule (it is not just labour time).' 
      'For wet areas, plan waterproofing coordination and cure time into your timeline upfront.'
    )
  },
  @{ suburb = 'Homebush'; slug = 'homebush'; notes = @(
      'Higher density means access and noise rules can dominate the plan (lift bookings, protection, working hours).' 
      'If you are comparing quotes, check what preparation is actually included — that is where pricing diverges.'
      'For bathrooms, confirm the waterproofing provider and cure time before locking a start date.'
    )
  },
  @{ suburb = 'Lidcombe'; slug = 'lidcombe'; notes = @(
      'Mixed building types: treat every quote as a scope document (prep + waterproofing + setout), not just a price.'
      'If the floor is timber-framed, movement control and sheeting/underlay decisions often drive longevity.'
      'If the job is in a unit block, access planning reduces delays (parking, delivery windows, waste disposal).' 
    )
  },
  @{ suburb = 'Rydalmere'; slug = 'rydalmere'; notes = @(
      'You can see both older housing and newer medium-density: substrate type (timber vs concrete) is a common variable.'
      'For renovation re-tiles, unknown waterproofing history is a frequent scope driver.'
      'If you are changing layouts (moving fixtures), confirm sequencing with the plumber and waterproofer early.'
    )
  },
  @{ suburb = 'Silverwater'; slug = 'silverwater'; notes = @(
      'Traffic and access constraints can affect delivery and waste runs; plan logistics so the tiling days are productive.'
      'If the job is a wet area, waterproofing sequencing and cure time is the non-negotiable part of the schedule.'
      'For floors, tile selection (slip rating/finish) should match how the space is actually used.'
    )
  }
)

foreach ($r in $ring) {
  $path = Join-Path -Path 'areas/ryde' -ChildPath (Join-Path -Path $r.slug -ChildPath 'index.md')

  if (!(Test-Path $path)) {
    Write-Warning "Missing: $path"
    continue
  }

  $text = Get-Content -Raw -Encoding UTF8 $path

  if ($text -match '## Local notes') {
    continue
  }

  $notesBlock = "`n## Local notes (what usually matters in {0})`n`n" -f $r.suburb
  foreach ($n in $r.notes) {
    $notesBlock += "- $n`n"
  }
  $notesBlock += "`n"

  if ($text -match '## Useful Ryde guides') {
    $text = $text -replace '## Useful Ryde guides', ($notesBlock + '## Useful Ryde guides')
  }
  else {
    # Fallback append
    $text = $text + $notesBlock
  }

  [System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host "Enriched ring suburb pages with local notes." -ForegroundColor Green
