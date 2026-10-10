#!/usr/bin/env bash
# v2 — positive, cozy "American autumn / Halloween" reel. 9:16, ~17 s, no words.
# Audio is left silent: add DDT "Летели облака" in Instagram's music library (licensed there).
set -euo pipefail
cd "$(dirname "$0")"
SRC=assets/source; OUT=renders; TMP=assets/video_v2; mkdir -p "$OUT" "$TMP"
W=1080; H=1920; FPS=30
# Warm golden-hour look: orange/amber highlights, soft teal shadows, gentle glow, light grain.
look() { # $1 = brightness, $2 = saturation
  echo "eq=brightness=$1:contrast=1.06:saturation=$2,\
colorbalance=rs=-0.05:gs=0.01:bs=0.03:rm=0.03:gm=0.03:bm=-0.07:rh=0.07:gh=0.05:bh=-0.10,\
selectivecolor=greens='0.15 0 0.2 0':yellows='-0.1 0.05 -0.15 0':reds='-0.05 0.0 0.1 0':blues='0.2 -0.1 0 0':magentas='0 -0.3 0 0',\
curves=master='0/0.04 0.5/0.52 1/0.97',\
split[g0][g1];[g1]gblur=sigma=18[gb];[g0][gb]blend=all_mode=screen:all_opacity=0.18,\
vignette=angle=PI/5,noise=alls=5:allf=t"
}
ENC="-c:v libx264 -preset medium -crf 16 -pix_fmt yuv420p -r $FPS -an"

# 1) Clouds fly over the field & fence — the opening image (4.5 s)
ffmpeg -v error -y -i $SRC/a.mov -vf "setpts=PTS/0.53,minterpolate=fps=$FPS:mi_mode=blend,\
scale=${W}:${H}:flags=lanczos,trim=duration=4.5,setpts=PTS-STARTPTS,$(look 0.02 1.08),fade=in:st=0:d=0.6" $ENC $TMP/s1.mp4

# 2) Golden pine forest, she reaches up to the sky — gentle push-in (6.0 s)
ffmpeg -v error -y -ss 39.0 -t 6 -i $SRC/b.mov -vf "fps=$FPS,scale=2160:3840:flags=lanczos,\
zoompan=z='1.30+0.0012*on':x='iw*0.49-iw/zoom/2':y='ih*0.72-ih/zoom/2':d=1:s=${W}x${H}:fps=$FPS,\
$(look 0.03 1.12)" $ENC $TMP/s2.mp4

# 3) Birds fly over her across the autumn field — letterbox removed, 9:16 (7.9 s)
ffmpeg -v error -y -i $SRC/c.mp4 -vf "fps=$FPS,crop=720:960:0:160,crop=540:960:90:0,\
scale=2160:3840:flags=lanczos,zoompan=z='1+0.0006*on':x='iw/2-iw/zoom/2':y='ih*0.6-ih/zoom*0.6':d=1:s=${W}x${H}:fps=$FPS,\
$(look 0.13 1.10),selectivecolor=neutrals='0.10 0.03 0.07 0':blues='0.15 0 0.05 0',fade=out:st=6.6:d=1.3" $ENC $TMP/s3.mp4

# Soft dissolves between shots; silent stereo track so Instagram accepts it and music can be added there.
ffmpeg -v error -y -i $TMP/s1.mp4 -i $TMP/s2.mp4 -i $TMP/s3.mp4 -f lavfi -i anullsrc=r=48000:cl=stereo -filter_complex "\
[0:v][1:v]xfade=transition=fade:duration=0.7:offset=3.8[v01];\
[v01][2:v]xfade=transition=fade:duration=0.7:offset=9.1,format=yuv420p[v]" \
  -map "[v]" -map 3:a -shortest -c:v libx264 -preset slow -crf 20 -maxrate 12M -bufsize 24M -profile:v high -r $FPS \
  -c:a aac -b:a 128k -movflags +faststart $OUT/final_v2.mp4
ffprobe -v error -show_entries format=duration,size -of compact $OUT/final_v2.mp4
