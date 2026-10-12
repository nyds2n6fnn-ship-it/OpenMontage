# S.K.A.I. GYM — «на голодняк приперлась» (Instagram Reel, 9:16)

Talking-head reel with animated infographics and the speaker's head in a circle. No subtitles.

- **File:** `skai-gym-hungry-reel_9x16.mp4` — 1080×1920, 30 fps, 26.7 s, −14 LUFS
- **Source:** `IMG_8144.MOV` (Google Drive folder `1Pi4oSvzPrKaUoZ0Ubz9JRDsZg1UpM-Ys`)

## Structure (timed to the speech, faster-whisper word timestamps)

| Time | Speech | On screen |
|------|--------|-----------|
| 0.0–3.0 | «Чо, опять на тренировку на голодняк приперлась» | original full-screen footage (hook, untouched) → circle-close into the bubble |
| 3.0–7.3 | «сил нет, голова кружится, жим не идёт» | three symptom cards pop in on each phrase (draining battery, spinning spiral, barbell ↓) |
| 7.3–11.5 | «ехать собралась, а машину не заправил» | fuel gauge needle drops to E, pump light blinks, «тело = машина / еда = топливо» |
| 11.5–19.0 | «сжигает не жир… а мышцы» | «жир» crossed out on «не жир», «мышцы» card burns, bar drains |
| 19.0–22.2 | «тренировку в мусорку» | workout card is tossed into a bin |
| 22.2–25.3 | «поешь за час-два углеводы и немного белка» | clock «за 1–2 часа», donut 70% carbs / 30% protein |
| 25.3–26.7 | «это не так уж сложно» | check stamp «это не сложно» |

## Build

1. `hf/index.html` — HyperFrames composition (GSAP) for the infographic layer:
   `npx hyperframes render -o ../assets/infographic.mp4 --fps 30` (from the `hf/` dir).
2. `compose.sh` — ffmpeg: full-screen hook, `circleclose` transition, circular face crop
   overlaid into the lime ring, loudness normalisation.
   Expects `projects/skai-gym-hungry-reel/` layout (`assets/source/IMG_8144.MOV`,
   `assets/infographic.mp4`, `assets/circle_mask.png` — a 480×480 white anti-aliased circle).
