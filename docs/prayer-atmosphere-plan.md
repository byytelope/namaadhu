# Prayer card atmosphere implementation plan

## Working agreement

Implement one numbered substep at a time, then stop for the user's visual feedback.
Revise that substep until accepted before starting the next. A passing compiler
check is not visual acceptance. The user runs the app and reports back; do not
launch Simulator or loop on screenshots. Use focused static checks per change.

Keep card layout, countdown timing, sunnah labels, glass highlighting, navigation,
and prayer calculations intact. Atmospheres illustrate prayer time, not live weather.

## Direction

Small windows into a natural sky: broad directional light, clouds with internal
density and shading, subtle distant stars, restrained HDR sunlight. Use a hybrid
of sky shading, cloud textures, and small animated highlights. Establish the still
image first, then add motion. Prefer simple gradients for the initial sky study;
introduce a Metal shader when it improves cloud lighting/texture sampling rather
than assuming that a shader alone makes the result realistic.

## 1. Sunrise sky

- **1.1 — Accepted.** User feedback: "looks good." Add a separate static Sunrise
  sky background with muted blue upper sky, soft haze, and off-center warmth from
  a light source just below the card. Temporarily suppress the old Sunrise clouds
  and generic surface sheen so the lighting can be judged in isolation.
  Review: both phone and iPad, label/time readability, smooth color transitions,
  and a broad glow rather than a visible disc or hard orange band.
- **1.2 — Accepted.** User feedback: "looks good." Tune the accepted sky on compact and regular widths and at
  both normal and countdown card heights. Keep glow placement intentional as the
  card changes size. Add useful static preview variants for the user to inspect.
  Added phone (361 pt) and iPad (760 pt) previews in `SunriseSky.swift`, each using
  actual prayer rows in normal, current/glass, and upcoming/expanded states with
  an injected non-ticking mock countdown. The glow uses relative coordinates and
  radius fractions, so its placement follows card size. Retain the accepted colors
  and lighting until visual feedback indicates a specific adjustment is needed.

## 2. Cloud assets and still composition

- **2.1 — Accepted.** User feedback: "ok good." Create/source a small set of cloud textures with usable alpha,
  wispy edges, and internal density. Include elongated banks and broken thin cloud.
  Record provenance/license or generation details. Inspect on dark and light
  backdrops for halos, rectangular edges, repetition, and inadequate resolution.
  Review the assets before integrating them.
  Saved `docs/atmosphere-assets/cloud-bank-v1.png` and `cloud-layer-v1.png`,
  both 2048 × 768 with actual semi-transparent alpha and negligible border alpha
  (maximum 1/255). Generated with the built-in image tool; exact prompts and source
  details are in that directory's README. Rough-edged broken-wisp attempts were
  rejected; the second candidate is a flatter connected layer instead. Decide
  from user feedback whether a separate sparse wisp asset is still needed.
  `review.html` displays the candidates on light, dark, and sky backgrounds.
  Browser security policy blocked opening the local review page, so composite
  inspection is left to the user; the original images were inspected directly.
  Originals remain in docs; accepted copies are now included in the asset catalog.
- **2.2 — Accepted.** User feedback: "looks good." Add one still cloud composition to Sunrise. Tint and shade it
  for low warm sunlight; preserve blue/grey body shading and clear sky space.
  Use a lightweight Metal texture/lighting pass only if plain compositing cannot
  produce the desired shading. Check edges and color handling at actual card size.
  Added the bank and flatter layer to the asset catalog with their original alpha.
  Sunrise uses a fixed composition: a slightly cool, faint lower-left layer and
  a warmer bank toward the right. The accepted horizon glow overlays both clouds
  to unify their lighting with the sky. Original density/shading is preserved;
  no shader or animation is needed for this initial still composition. Texture
  aspect ratios are fixed and widths capped pending the iPad composition review.
- **2.3 — Accepted.** User feedback: "ok." Adapt composition to iPad by revealing more sky and cloud
  coverage, with uniform scaling rather than stretching. Keep the composition
  stable during card resizing. Review both widths before adding variation.
  Regular-width cards blend into a centered cloud field from 500 to 760 pt.
  Primary clouds retain their capped widths; two faint peripheral layers enter
  the visible area as the card widens. At full blend the cloud field is anchored
  to the 85 pt base height, so expansion reveals sky below rather than repositioning
  clouds. Compact cards retain the accepted composition. Added 500 pt split-view
  and 1024 pt landscape previews alongside the existing 361/760 pt previews.
- **2.4 — Accepted.** User feedback: "ok." Add bounded, seeded variation in cloud selection, crop, and
  placement. Keep light direction consistent and prevent random clutter around
  labels. A seed stays stable while the card is mounted.
  Sunrise owns a seed in view state. Each cloud slot deterministically derives
  scale (90–100%), position (±14 pt horizontal, ±3 pt vertical), and opacity
  (90–105% of its established value). Peripheral slots choose either accepted
  texture; the two primary slots retain a bank and a flatter layer. Shifts change
  the card-edge crop without cutting new hard edges into the texture. No mirrors
  or rotations alter the lighting direction. Slot seeds are independent of size
  class, card dimensions, countdown and array iteration order. Previews share an
  explicit seed across all states and include a "Next cloud variation" button.
  Later refinement: three additional PNGs were generated for each family, giving
  four distinct bank textures and initially four distinct layer textures. Layer2
  was later rejected and removed; three layer textures remain. Each slot chooses
  a PNG from its stable seed. The rejected crop/scale presets were removed.
  Atmosphere-specific preview helpers, seed/motion preview environment keys,
  the HTML review page, and duplicate review PNGs were removed as requested.
  Runtime assets and provenance remain in the asset catalog and README.

## 3. Cloud motion and Asr

- **3.1 — Accepted.** User feedback: "ok." Add very slow cloud translation with padded coverage so no
  texture edge enters the card. Preserve texture shape; avoid obvious pulsing or
  morphing. Stop animation offscreen/inactive and honor Reduce Motion.
  A pausable TimelineView updates only the cloud field at no more than 15 Hz.
  The thin layer moves up to 18 pt on a roughly four-minute smooth excursion;
  the bank moves up to 12 pt over roughly five minutes. A seeded speed multiplier
  keeps the layers slightly independent. This bounded drift has no wrap seam,
  shape morph, opacity cycling, or sudden reset. Alpha margins and peripheral
  coverage remain intact. Scroll visibility, scene phase, disappearance, Reduce
  Motion, and the preview toggle gate the timeline. Accumulated active time is
  retained on pause so returning does not jump ahead. Existing previews include
  an "Animate clouds" switch. Device behavior and performance remain user-reviewed.
- **3.2 — Accepted.** User feedback: "ok." Adapt the accepted sky/cloud treatment to Asr, with deeper blue,
  warmer haze, and a distinct but related cloud composition. Review still and moving.
  AsrSky adds a deeper blue-to-warm-grey sky with broad upper-right afternoon
  illumination. Shared DaytimeClouds retains the accepted Sunrise parameters and
  motion/lifecycle handling; Asr places a less opaque bank higher and left of
  center, with a thin layer to the right and its own seed salt. Legacy Asr
  silhouettes and the generic surface sheen are suppressed. Cloud drift now uses
  type-specific timing: the thin layer travels farther on a shorter period than
  the slower, broader bank. Asr previews cover phone, iPad, split-view and
  landscape widths with seed and motion controls.

## 4. Dhuhr sun and lens flares

- **4.1 — Accepted.** User feedback: "ok." Refine daylight sky, reduce the apparent sun core, and create
  a broad natural halo. Concentrate HDR in the brightest highlights and soften
  geometric rays. Review both HDR appearance and ordinary SDR readability.
  DhuhrSun now uses a 192 pt low-contrast atmospheric halo, an 84 pt warm inner
  bloom, and a 31 pt HDR center. Rays are irregularly spaced, lower opacity,
  thinner, and more blurred. This keeps the highlight concentrated while the
  surrounding light remains legible in SDR. Existing flare artifacts are unchanged
  for the separate 4.2 composition review.
- **4.2 — Accepted.** User feedback: "ok." Compose restrained lens-flare artifacts along a coherent axis
  from the sun through an optical center. Replaced the outlined circles with
  three varied, softly blurred elliptical ghosts: a broad cool center ghost, a
  smaller lavender mid-axis ghost, and a compact white near-axis highlight.
  Their existing positions still trace the line from the sun toward the lower
  left, while the blur and missing stroke remove the artificial ring effect.
  The existing motion and gyro offsets remain attached to each artifact.
- **4.3 — Implemented; awaiting visual feedback.** Reconnect device tilt to flare positions while keeping
  the sun, halo, and rays fixed. Device motion now uses the corrected-Z-vertical
  reference frame, captures a neutral attitude when the view becomes active, and
  applies a bounded, low-pass-filtered offset to the flare group. The update is
  gated by sensor availability, active scene phase, and Reduce Motion; stopping
  the view clears both the offset and calibration so it cannot jump on return.
  Sensitivity is intentionally small but now large enough to be perceptible on a
  physical device, with closer flare ghosts receiving proportionally less motion.

## 5. Twilight and night

- **5.1 — Implemented; awaiting visual feedback.** Give Fajr a dim cool sky with restrained horizon light; give
  Maghrib warmer residual sunset light. Avoid simply reversing one palette.
  Fajr now uses a deeper blue-to-cool-lavender progression with a faint
  blue-violet horizon lift on the lower left. Maghrib has a separate deeper
  indigo-to-dusty-rose progression with a restrained apricot residual glow on
  the lower right. Both use broad, low-opacity light rather than a visible sun
  disc or hard horizon stripe. Existing stars and Fajr shooting stars are
  unchanged for their separate reviews.
- **5.2 — Implemented; awaiting visual feedback.** Refine Isha and the shared star field: predominantly faint small
  stars, a few brighter ones, and fading visibility toward bright horizons. Keep
  star positions stable and account for different card widths.
  Fajr and Maghrib now use sparse, low-exposure fields with different stable
  layouts and stronger horizon falloff against their brighter twilight bands.
  Isha has a denser field with only a few larger/brighter anchors. Twinkle
  contrast and speed are reduced so the stars breathe subtly rather than pulse;
  the existing Reduce Motion behavior remains intact. No positions depend on
  card width, so resizing does not reshuffle the field.
- **5.3 — Implemented; awaiting visual feedback.** Integrate the existing rare Fajr shooting stars with the new
  exposure, HDR highlights, and star field. Review tail direction and disappearance.
  Shooting stars remain Fajr-only, upper-sky, seeded, and infrequent. Their
  head-leading geometry still travels left/down with the tail trailing in the
  opposite direction. The HDR head and core remain concentrated, while the
  active fade-in/fade-out now uses smooth-step easing so the streak emerges and
  disappears naturally against the dim pre-dawn sky.

## 6. Integration and performance

- **6.1 — Implemented; awaiting visual feedback.** Consolidate accepted per-prayer settings and remove superseded
  cloud/lighting code. Keep background updates isolated from timer and row layout.
  Removed the unreachable procedural cloud scene and renderer from
  `PrayerAtmosphericDetails`: Sunrise and Asr are owned by `DaytimeClouds`, while
  the atmospheric-details layer only renders stars, Fajr shooting stars, and the
  Dhuhr sun. The remaining shooting-star seed is named for its actual purpose,
  and PrayerCardBackground now uses shared daytime/twilight composition flags
  instead of repeating layer conditions. No timer, countdown, card-size, or
  accepted visual path was changed.
- **6.2 — Pending.** Bound texture sizes, offscreen rendering, and refresh rates.
  Recheck inactive/offscreen lifecycle, Reduce Motion, and unsupported sensors.
  The user supplies physical-device observations/profiles; do not claim a frame
  rate or battery improvement without measurement.
- **6.3 — Pending.** Final user review across iPhone/iPad, expanded/collapsed cards,
  light/dark surroundings, and foreground/background transitions. Address each
  regression before marking the atmosphere work complete.

## Current handoff

Maghrib wisp follow-up: reuses the seeded flat-cloud PNGs and existing pausable
cloud clock. One faint rose-tinted layer on phone; an even fainter cool layer
fades in on wider regular-size-class cards. Cloud sizes and vertical positions
remain independent of card height. No new shaders or generated assets. Focused
Swift typechecking passed; visual review remains with the user.

Dhuhr cloud follow-up: added a sparse seeded pair using the existing generated
layer/bank PNG variants. Cloud dimensions and vertical positions do not depend
on card height. A paused-when-inactive/offscreen 15 Hz cloud clock gives the thin
layer faster drift than the distant bank, and respects Reduce Motion.

Metal color effects sample those same moving textures to attenuate the sun and
rays locally, and dim the gyro-controlled flare ghosts according to coverage of
the sun disc. A separate cloud lighting pass adds soft warm illumination near
the sun while preserving cooler cloud bodies. This is an artistic optical-depth
approximation, not volumetric rendering. Existing HDR sun settings are retained.

Focused Swift typechecking passed. Metal compilation could not run because the
selected Xcode installation reports a missing Metal Toolchain; no components
were downloaded. No Simulator or visual verification was performed.

Next action: user reviews Dhuhr on device, especially a cloud crossing the sun,
flare dimming, iPad spacing, and unchanged cloud sizes during card expansion.
Rendering/lifecycle bounds in 6.2 and the final cross-device review remain open.
