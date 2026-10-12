# «Летели облака» — Instagram mini music video (9:16)

Warm "American autumn / Halloween" look, no horror. Cut to the first verse and chorus of
DDT «Летели облака» (song 0:34.85 → 1:07.0), from three source clips
(Google Drive folder `1dv8HsLY3ivG25avBysQyt_vzb7LSUmlp`).

- **File:** `leteli-oblaka-clip_9x16.mp4` — 1080×1920, 30 fps, 32.1 s, H.264 + AAC 256k, −14 LUFS
- Lyric timings come from a faster-whisper transcription; cuts are snapped to the beat grid (~152 BPM).

## Shot list

| Song | Line | Shot |
|------|------|------|
| 34.85 | intro / «Летели облака» | cloud sky close-up, slow drift down to her head, fade-in |
| 38.84 | «летели далеко» | her at the fence, clouds rolling (slow-mo), dissolve |
| 42.41 | «как мамина рука» | forest, medium, she raises her arm (slow-mo) |
| 46.39 | «как папино трико» | close on her walking legs |
| 48.82 | «как рыбы-корабли» | flock against the sky, like a school of fish (slow-mo) |
| 52.77 | «как мысли дурака» | close, mirrored: she crouches |
| 54.77 | «над стёклами земли» | tilt from the pine tops down to the ground |
| 58.00 | «Летели облака» | wide forest + clouds double exposure, dissolve |
| 61.55 | «летели облака» | birds over her + faint clouds double exposure, fade-out |

**Look:** golden-hour warmth, amber highlights, soft teal shadows, gentle glow (RGB screen blend),
light grain, soft vignette.

## Re-render

`render_clip.py` expects the project layout `projects/american-halloween-reel/`
(`assets/source/{a.mov,b.mov,c.mp4}`, `assets/music/ddt_leteli_oblaka.mp3`).
`python3 render_clip.py` renders all shots and assembles; pass shot indices to re-render
only those, or `assemble` to only rebuild the final file.
