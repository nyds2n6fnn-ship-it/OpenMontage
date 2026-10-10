#!/usr/bin/env python3
"""Mini music video: DDT "Летели облака", verse 1 + chorus (song 34.85 s → 67.0 s), 9:16.

Every shot is cut to a lyric line on the song's beat grid (~152 BPM); shots reuse
the three source clips with different framing, speed, direction and double exposures.
"""
import subprocess, sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "assets/source"
SONG = ROOT / "assets/music/ddt_leteli_oblaka.mp3"
TMP = ROOT / "assets/video_clip"; TMP.mkdir(parents=True, exist_ok=True)
OUT = ROOT / "renders/final_clip.mp4"
FPS, W, H = 30, 1080, 1920
SONG_IN, SONG_OUT = 34.85, 67.0
HARD, SOFT = 2, 16          # transition length in frames (2 ≈ a cut, 16 ≈ dissolve)

LOOK = ("eq=brightness={b}:contrast=1.06:saturation={s},"
        "colorbalance=rs=-0.05:gs=0.01:bs=0.03:rm=0.03:gm=0.03:bm=-0.07:rh=0.07:gh=0.05:bh=-0.10,"
        "selectivecolor=greens='0.15 0 0.2 0':yellows='-0.1 0.05 -0.15 0':reds='-0.05 0.0 0.1 0'"
        ":blues='0.2 -0.1 0 0':magentas='0 -0.3 0 0'{extra},"
        "curves=master='0/0.04 0.5/0.52 1/0.97',"
        "format=gbrp,split[g0{k}][g1{k}];[g1{k}]gblur=sigma=18[gb{k}];[g0{k}][gb{k}]blend=all_mode=screen:all_opacity=0.18,"
        "vignette=angle=PI/5,noise=alls=5:allf=t,format=gbrp")

# Source framing presets: file, pre-crop, base brightness
SOURCES = {
    "fence":  ("a.mov", "", 0.02),
    "forest": ("b.mov", "", 0.03),
    "crows":  ("c.mp4", "crop=720:960:0:160,crop=540:960:90:0,", 0.13),
}

# (song_start, song_end, lyric, shot spec, transition INTO this shot)
# spec: src, t (source start), speed, z0→z1 zoom, cx, cy0→cy1 (frame-centre fractions),
#       flip, rev, dx (double-exposure source spec)
SHOTS = [
    (34.85, 38.84, "intro / Летели облака", dict(src="fence", t=0.0, speed=0.53, z=(1.55, 1.35), cx=0.5, cy=(0.22, 0.30)), "fadein"),
    (38.84, 42.41, "летели далеко",         dict(src="fence", t=0.0, speed=0.55, z=(1.0, 1.12), cx=0.5, cy=(0.75, 0.75)), SOFT),
    (42.41, 46.39, "как мамина рука",       dict(src="forest", t=42.0, speed=0.75, z=(2.0, 2.3), cx=0.49, cy=(0.74, 0.72)), HARD),
    (46.39, 48.82, "как папино трико",      dict(src="forest", t=16.0, speed=1.0, z=(3.2, 3.2), cx=0.48, cy=(0.86, 0.86)), HARD),
    (48.82, 52.77, "как рыбы-корабли",      dict(src="crows", t=0.4, speed=0.7, z=(1.6, 1.75), cx=0.5, cy=(0.25, 0.22)), HARD),
    (52.77, 54.77, "как мысли дурака",      dict(src="forest", t=4.0, speed=1.0, z=(2.8, 3.0), cx=0.48, cy=(0.80, 0.80), flip=True), HARD),
    (54.77, 58.00, "над стёклами земли",    dict(src="forest", t=20.0, speed=1.0, z=(1.9, 1.9), cx=0.5, cy=(0.15, 0.75)), HARD),
    (58.00, 61.55, "Летели облака",         dict(src="forest", t=11.5, speed=1.0, z=(1.0, 1.15), cx=0.5, cy=(0.75, 0.75),
                                                 dx=dict(src="fence", t=0.0, speed=0.53, z=(1.6, 1.6), cx=0.5, cy=(0.2, 0.2), op=0.45)), SOFT),
    (61.55, SONG_OUT, "летели облака",      dict(src="crows", t=0.0, speed=1.0, z=(1.0, 1.1), cx=0.5, cy=(0.6, 0.6),
                                                 dx=dict(src="fence", t=0.0, speed=0.4, z=(1.6, 1.6), cx=0.5, cy=(0.2, 0.2), op=0.30)), HARD),
]


def fr(t):
    return round(t * FPS)


def chain(spec, frames, label):
    """Filter chain turning input `label` into a graded W×H stream of `frames` frames."""
    file, pre, bright = SOURCES[spec["src"]]
    speed = spec["speed"]
    z0, z1 = spec["z"]; cy0, cy1 = spec["cy"]; cx = spec["cx"]; n = max(frames - 1, 1)
    f = [f"[{label}]"]
    if spec.get("rev"):
        f.append("reverse,")
    if spec["src"] == "fence":   # 30 fps timelapse → blend frames for smooth slow motion
        f.append(f"setpts=(PTS-STARTPTS)/{speed},minterpolate=fps={FPS}:mi_mode=blend,")
    else:
        f.append(f"setpts=(PTS-STARTPTS)/{speed},fps={FPS},")
    f.append(pre)
    if spec.get("flip"):
        f.append("hflip,")
    f.append("scale=1620:2880:flags=lanczos,")
    f.append(f"zoompan=z='{z0}+({z1}-{z0})*on/{n}':x='iw*{cx}-iw/zoom/2'"
             f":y='ih*({cy0}+({cy1}-{cy0})*on/{n})-ih/zoom/2':d=1:s={W}x{H}:fps={FPS},")
    f.append(LOOK.format(b=bright, s=1.10 if spec["src"] == "crows" else 1.08,
                         extra="", k=label[0]))
    f.append(f",trim=end_frame={frames},setpts=PTS-STARTPTS")
    return "".join(f)


def src_args(spec, frames):
    file = SOURCES[spec["src"]][0]
    need = frames / FPS * spec["speed"] + 0.3
    return ["-ss", f"{spec['t']:.3f}", "-t", f"{need:.3f}", "-i", str(SRC / file)]


def render_shot(i):
    s0, s1, lyric, spec, _ = SHOTS[i]
    # each shot covers its slot plus half of the transitions on both sides
    t_in = SHOTS[i][4] if i > 0 else 0
    t_out = SHOTS[i + 1][4] if i + 1 < len(SHOTS) else 0
    t_in = 0 if t_in == "fadein" else t_in
    frames = fr(s1 - SONG_IN) - fr(s0 - SONG_IN) + t_in // 2 + t_out // 2
    args = ["ffmpeg", "-v", "error", "-y", *src_args(spec, frames)]
    g = chain(spec, frames, "0:v") + "[base]"
    if "dx" in spec:
        args += src_args(spec["dx"], frames)
        g += ";" + chain(spec["dx"], frames, "1:v") + "[ov]"
        g += f";[base][ov]blend=all_mode=screen:all_opacity={spec['dx']['op']}[b2];[b2]format=yuv420p[base2]"
        last = "[base2]"
    else:
        g += ";[base]format=yuv420p[base2]"
        last = "[base2]"
    if SHOTS[i][4] == "fadein":
        g += f";{last}fade=in:d=0.6[o]"; last = "[o]"
    if i == len(SHOTS) - 1:
        g += f";{last}fade=out:st={frames / FPS - 2.2:.3f}:d=2.2[o2]"; last = "[o2]"
    out = TMP / f"shot{i:02d}.mp4"
    subprocess.run([*args, "-filter_complex", g, "-map", last, "-frames:v", str(frames),
                    "-c:v", "libx264", "-preset", "medium", "-crf", "16", "-pix_fmt", "yuv420p",
                    "-r", str(FPS), "-an", str(out)], check=True)
    got = int(subprocess.check_output(["ffprobe", "-v", "error", "-count_frames", "-select_streams", "v:0",
                                       "-show_entries", "stream=nb_read_frames", "-of", "csv=p=0", str(out)]))
    print(f"shot {i:02d} {lyric:26s} {frames} fr (got {got})", flush=True)
    if got != frames:
        sys.exit(f"shot {i} frame mismatch")
    return frames


def main():
    # args: shot indices to (re)render only, or "assemble" to skip rendering
    assemble = sys.argv[1:] == ["assemble"]
    only = [] if assemble else [int(a) for a in sys.argv[1:]]
    if not assemble:
        with ThreadPoolExecutor(4) as ex:
            list(ex.map(render_shot, only or range(len(SHOTS))))
    if only:
        return
    # chain transitions: xfade offset = cut time − half the transition
    inputs, g, prev = [], [], "0:v"
    for i in range(len(SHOTS)):
        inputs += ["-i", str(TMP / f"shot{i:02d}.mp4")]
    for i in range(1, len(SHOTS)):
        d = SHOTS[i][4]
        cut = fr(SHOTS[i][0] - SONG_IN)
        off = (cut - d // 2) / FPS
        g.append(f"[{prev}][{i}:v]xfade=transition=fade:duration={d / FPS:.4f}:offset={off:.4f}[x{i}]")
        prev = f"x{i}"
    total = fr(SONG_OUT - SONG_IN) / FPS
    a = len(SHOTS)
    g.append(f"[{a}:a]atrim={SONG_IN}:{SONG_OUT},asetpts=PTS-STARTPTS,afade=in:d=0.5,"
             f"afade=out:st={total - 2.5:.3f}:d=2.5,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[a]")
    subprocess.run(["ffmpeg", "-v", "error", "-y", *inputs, "-i", str(SONG), "-filter_complex", ";".join(g),
                    "-map", f"[{prev}]", "-map", "[a]", "-t", f"{total:.3f}",
                    "-c:v", "libx264", "-preset", "slow", "-crf", "20", "-maxrate", "12M", "-bufsize", "24M",
                    "-profile:v", "high", "-pix_fmt", "yuv420p", "-r", str(FPS),
                    "-c:a", "aac", "-b:a", "256k", "-movflags", "+faststart", str(OUT)], check=True)
    print(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration,size",
                                   "-of", "compact", str(OUT)]).decode())


if __name__ == "__main__":
    main()
