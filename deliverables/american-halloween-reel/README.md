# American Halloween — Instagram Reel

Atmospheric, wordless 9:16 reel built from three source clips
(Google Drive folder `1dv8HsLY3ivG25avBysQyt_vzb7LSUmlp`).

- **File:** `american-halloween-reel_9x16.mp4` — 1080×1920, 30 fps, 18.0 s, H.264 + AAC, -14 LUFS
- **Pipeline:** `cinematic`, render runtime `ffmpeg` (footage-only grade + cut; Remotion not installed)

## Edit

| Time | Source | Treatment |
|------|--------|-----------|
| 0.0–4.0 | `IMG_8092` pine forest, figure facing camera | fade in from black, slow creeping push-in |
| 4.0–6.5 | `IMG_8092` 5.0–7.5 s, figure crouches | hard cut closer + sub-boom, dip to black |
| 6.5–11.0 | `IMG_8080` fence & cloud timelapse | slowed ~0.53× with frame blending, steel storm sky |
| 11.0–18.0 | `IMG_8100` crows over the figure | letterbox removed, reframed 9:16, sub-boom, long fade out |

**Look:** day-for-dusk, teal shadows / amber highlights, muted greens, crushed blacks,
vignette, live film grain, faint candle-like flicker.

**Sound:** "Dark Ambient" by AtlasAudio (Pixabay Content License — free, no attribution
required) + two synthesized sub-booms on the hard cuts. No voice, no text.

## Re-render

`render.sh` expects the project layout `projects/american-halloween-reel/`
(`assets/source/{a.mov,b.mov,c.mp4}`, `assets/music/dark_ambient_atlasaudio.mp3`).
