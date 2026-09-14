# Cloud texture provenance

Generated with the built-in image-generation tool on 2026-09-14 for Namaadhu.
These are synthetic assets, not photographs licensed from a third-party library.
Original generated PNGs and their embedded metadata/alpha are preserved byte-for-byte.
The original two assets and six additional generated variants live in
`Namaadhu/Assets.xcassets/AtmosphereCloud{Bank,Layer}{2,3,4}.imageset` (the originals
have no numeric suffix). The asset catalog is the single project copy of each PNG.
Sunrise and Asr select among four PNGs per family using a stable mounted seed.

## Candidates

- `cloud-bank-v1.png`: elongated cloud bank with internal density and shading.
- `cloud-layer-v1.png`: flatter layered variant edited from the bank, with softer detail.
- Both are 2048 × 768 RGBA PNGs. Render with uniform scaling.
The temporary review page, duplicate review PNGs, and atmosphere-specific SwiftUI
preview helpers were removed at the user's request. Runtime sky views are retained.

Alpha inspection using ImageIO/CoreGraphics confirmed fully transparent and
semi-transparent pixels in both PNGs, with no fully opaque pixels. Maximum alpha
on the outermost image borders is 1/255. The original images were visually
inspected; background composite inspection remains for the user because browser
security policy blocked opening the local review page.

The initial broken-wisp generations had rough cutout edges/colored fringe and
were rejected. The flatter layered edit is the accepted replacement; it is a
connected layer, not a completed sparse cirrus texture. The original card composition was subsequently accepted.

## Source files

Bank: `exec-be7f5e6c-3263-49b0-bf3b-477fac4abc67.png`.
Layer edit: `exec-87c3cc11-f870-451f-b35c-c349f3f6c9a2.png`.
Originals live in the generating task's Codex generated-images directory;
the asset-catalog copies are the durable project sources.

## Exact generation prompt — bank

Use case: photorealistic-natural. Asset type: high resolution RGBA cloud texture for a realistic iOS prayer-card sky, composited later over blue and dawn gradients. Genuinely transparent background with alpha, no sky color, no checkerboard pixels, no ground, no sun, no text, no frame. Landscape canvas. Photographic atmospheric cloud density, neutral ivory highlights and subtle cool gray internal shading, delicate semi-transparent wispy margins, natural uneven structure, soft diffuse illumination with a faint lower-right light bias. Cloud fully contained with transparent margin on all four sides, taper irregularly to zero density at ends. No cartoon humps, outlines, cotton balls, hard cutout edges, blur blobs or opaque rectangular background. Preserve fine natural vapor structure without crunchy excessive contrast. Subject: ONE elongated low cloud bank seen from a distance, gently layered stratocumulus with low relief, broad connected body with small breaks, roughly 5:1 width-to-height cloud silhouette, fills 85 percent of canvas width. Subtle volume and light/shadow, not a dramatic storm cloud. Single asset only.

## Exact edit prompt — layer

Input: the generated bank above.

Edit this transparent cloud asset into a different cloud variant. Keep the existing genuinely transparent background and its very smooth feathered alpha edges. Preserve the photographic neutral gray/ivory shading. Replace the dense bank with a much flatter, thinner elongated bank of layered soft stratus cloud, connected soft horizontal bands with a few small internal gaps. No tall cumulus lobes. Keep cloud edges soft and vapor-like exactly like the input, not cut out or fringed. Cloud must be fully contained with at least 7 percent transparent margin on ALL four sides. No sky, no black/white matte, no blue color, no text or extra objects. Maintain the input's panoramic canvas and natural photographic look. This is a single transparent cloud texture used as a subtle overlay over dawn sky.

## Additional PNG variants

Generated using the built-in image tool. Each is a separate generation referencing
its original family PNG. No crop, mirror, or scale transformation creates these variants.
All are 2048 × 768 with transparent and semi-transparent pixels. Outermost border
alpha is at most 3/255 (1/255 for all except layer v2/v3); original bytes are preserved.
Thin layers drift ±22 pt over a 190-second cycle; banks ±14 pt over 270 seconds,
with a seeded 0.88–1.12 speed multiplier. The render timeline remains capped at 15 Hz
and pauses offscreen, inactive, or with Reduce Motion.

### Bank2

Saved: `Namaadhu/Assets.xcassets/AtmosphereCloudBank2.imageset/cloud-bank-v2.png`.
Source: `exec-820bf21a-4618-4a23-84b6-8ece25ae247e.png`.

Exact prompt:

Generate a NEW cloud bank variant matching the reference's photographic style, not a crop or resize. One elongated low-relief stratocumulus bank, broad connected body, irregular low crests concentrated toward the right and a long thinning left end. Neutral ivory highlights, cool grey internal density, diffuse faint lower-right illumination. Genuine transparent RGBA PNG, 2048 x 768 panoramic canvas. Entire cloud contained with at least 8 percent transparent margin on all four sides, feathered semi-transparent vapor edges. No sky, background matte, checkerboard pixels, text, sun, hard outlines, cartoon balls or excessive crunchy detail. Single asset for compositing over a prayer-card sky.

### Bank3

Saved: `Namaadhu/Assets.xcassets/AtmosphereCloudBank3.imageset/cloud-bank-v3.png`.
Source: `exec-19590fc8-57ee-494b-b2c1-54e5c2e0cbab.png`.

Exact prompt:

Generate a NEW bank cloud variant matching the reference's photographic style, not a crop or resize. A low connected bank with two unequal shallow masses, larger left-of-center mass and a long wispy right shoulder. Neutral ivory highlights and cool grey internal density; diffuse illumination with faint lower-right light bias. Genuine transparent RGBA PNG, 2048 x 768 panoramic canvas. Cloud occupies middle band with 8 percent fully transparent margin on ALL sides; natural semi-transparent feathered vapor edges. Match the reference's softness, scale and realistic detail. No sky, background matte, checkerboard pixels, sun, text, hard cutout outlines, cartoon circles or crunchy noise. Single texture for compositing over a prayer-card gradient.

### Bank4

Saved: `Namaadhu/Assets.xcassets/AtmosphereCloudBank4.imageset/cloud-bank-v4.png`.
Source: `exec-918da09e-642b-4a71-a090-d25a315e29dd.png`.

Exact prompt:

Generate a NEW bank cloud variant matching the reference's photographic style, not a crop or resize. A long low bank with an uneven ridge, a shallow central saddle and small connected crests at both ends; asymmetrical wispy margins. Neutral ivory highlights and cool grey internal density; diffuse illumination with faint lower-right light bias. Genuine transparent RGBA PNG, 2048 x 768 panoramic canvas. Cloud occupies middle band with 8 percent fully transparent margin on ALL sides; natural semi-transparent feathered vapor edges. Match the reference's softness, scale and realistic detail. No sky, background matte, checkerboard pixels, sun, text, hard cutout outlines, cartoon circles or crunchy noise. Single texture for compositing over a prayer-card gradient.

### Layer2 (removed)

Removed from the asset catalog and all runtime selection at the user's request.
The remaining layer variants retain their original names: Layer, Layer3, Layer4.
The generation record below is historical provenance only.
Source: `exec-65a01c56-048b-46f3-a3a1-dea6c6011f29.png`.

Exact prompt:

Generate a NEW layer cloud variant matching the reference's photographic style, not a crop or resize. A very flat stratus layer of long horizontal ribbons, denser on the left tapering gently to the right, a few narrow translucent internal gaps. No tall lobes. Neutral ivory highlights and cool grey internal density; diffuse illumination with faint lower-right light bias. Genuine transparent RGBA PNG, 2048 x 768 panoramic canvas. Cloud occupies middle band with 8 percent fully transparent margin on ALL sides; natural semi-transparent feathered vapor edges. Match the reference's softness, scale and realistic detail. No sky, background matte, checkerboard pixels, sun, text, hard cutout outlines, cartoon circles or crunchy noise. Single texture for compositing over a prayer-card gradient.

### Layer3

Saved: `Namaadhu/Assets.xcassets/AtmosphereCloudLayer3.imageset/cloud-layer-v3.png`.
Source: `exec-57e4d29d-6a0f-4b0d-b9c1-100500371af6.png`.

Exact prompt:

Generate a NEW layer cloud variant matching the reference's photographic style, not a crop or resize. A very flat stratus layer with a thin wispy left extension, slightly denser middle-right body, subtle horizontal folds and diffuse edges. No tall lobes. Neutral ivory highlights and cool grey internal density; diffuse illumination with faint lower-right light bias. Genuine transparent RGBA PNG, 2048 x 768 panoramic canvas. Cloud occupies middle band with 8 percent fully transparent margin on ALL sides; natural semi-transparent feathered vapor edges. Match the reference's softness, scale and realistic detail. No sky, background matte, checkerboard pixels, sun, text, hard cutout outlines, cartoon circles or crunchy noise. Single texture for compositing over a prayer-card gradient.

### Layer4

Saved: `Namaadhu/Assets.xcassets/AtmosphereCloudLayer4.imageset/cloud-layer-v4.png`.
Source: `exec-dd7178cc-a1e1-42cf-94f5-8ea9da124fd2.png`.

Exact prompt:

Generate a NEW layer cloud variant matching the reference's photographic style, not a crop or resize. A very flat wide stratus layer with two overlapping soft horizontal bands of unequal length and small internal gaps; connected, wispy, no tall lobes. Neutral ivory highlights and cool grey internal density; diffuse illumination with faint lower-right light bias. Genuine transparent RGBA PNG, 2048 x 768 panoramic canvas. Cloud occupies middle band with 8 percent fully transparent margin on ALL sides; natural semi-transparent feathered vapor edges. Match the reference's softness, scale and realistic detail. No sky, background matte, checkerboard pixels, sun, text, hard cutout outlines, cartoon circles or crunchy noise. Single texture for compositing over a prayer-card gradient.
