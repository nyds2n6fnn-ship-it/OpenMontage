#!/usr/bin/env bash
# American Halloween reel — 9:16, 18 s, no words. Cinematic pipeline, ffmpeg runtime.
set -euo pipefail
cd "$(dirname "$0")"
SRC=assets/source; OUT=renders; TMP=assets/video; mkdir -p "$OUT" "$TMP"
W=1080; H=1920; FPS=30

# Shared "American Halloween" look: day-for-dusk, teal shadows, amber highlights,
# muted greens, crushed blacks, vignette, live grain, faint candle flicker.
look() { # $1 = brightness offset, $2 = gamma, $3 = saturation
  echo "eq=brightness=$1:contrast=1.18:saturation=${3:-0.78}:gamma=$2:eval=frame,\
selectivecolor=greens='0 0.2 0.25 0':cyans='0.25 0 0 0':blues='0.25 0.08 0 0.15':yellows='-0.05 0.12 -0.25 0':reds='-0.1 0.1 0.15 0',\
colorbalance=rs=-0.06:gs=-0.01:bs=0.07:rm=0.04:bm=-0.03:rh=0.10:gh=0.03:bh=-0.08,\
curves=master='0/0.03 0.25/0.18 0.6/0.57 1/0.93',\
vignette=angle=PI/3.4,noise=alls=11:allf=t,\
eq=brightness='0.012*sin(t*17)+0.008*sin(t*31)':eval=frame"
}
ENC="-c:v libx264 -preset medium -crf 16 -pix_fmt yuv420p -r $FPS -an"

# 1) Forest wide, figure stands facing camera — slow creeping push-in (4.0 s)
ffmpeg -v error -y -ss 0 -t 4 -i $SRC/b.mov -vf "fps=$FPS,scale=2160:3840:flags=lanczos,\
zoompan=z='1+0.0016*on':x='iw*0.5-iw/zoom/2':y='ih*0.70-ih/zoom*0.70':d=1:s=${W}x${H}:fps=$FPS,\
$(look -0.03 0.92),fade=in:st=0:d=1.0" $ENC $TMP/s1.mp4

# 2) Hard cut closer: she crouches among the pines (2.5 s)
ffmpeg -v error -y -ss 5.0 -t 2.5 -i $SRC/b.mov -vf "fps=$FPS,scale=2160:3840:flags=lanczos,\
zoompan=z='2.3+0.003*on':x='iw*0.49-iw/zoom/2':y='ih*0.78-ih/zoom/2':d=1:s=${W}x${H}:fps=$FPS,\
$(look -0.02 0.92),fade=out:st=2.2:d=0.3" $ENC $TMP/s2.mp4

# 3) Field & fence under rolling storm clouds, slowed ~0.53x (4.5 s)
ffmpeg -v error -y -i $SRC/a.mov -vf "setpts=PTS/0.53,minterpolate=fps=$FPS:mi_mode=blend,\
scale=${W}:${H}:flags=lanczos,trim=duration=4.5,setpts=PTS-STARTPTS,\
$(look -0.08 0.82 0.42),hue=s=0.55,fade=in:st=0:d=0.3,fade=out:st=4.2:d=0.3" $ENC $TMP/s3.mp4

# 4) Climax: a murder of crows sweeps over her — remove letterbox, reframe 9:16 (7.0 s)
ffmpeg -v error -y -ss 0 -t 7 -i $SRC/c.mp4 -vf "fps=$FPS,crop=720:960:0:160,crop=540:960:90:0,\
scale=2160:3840:flags=lanczos,zoompan=z='1+0.0006*on':x='iw/2-iw/zoom/2':y='ih*0.6-ih/zoom*0.6':d=1:s=${W}x${H}:fps=$FPS,\
$(look 0.07 1.12),fade=in:st=0:d=0.25,fade=out:st=5.4:d=1.6" $ENC $TMP/s4.mp4

printf "file '%s'\n" s1.mp4 s2.mp4 s3.mp4 s4.mp4 > $TMP/list.txt
ffmpeg -v error -y -f concat -safe 0 -i $TMP/list.txt -c copy $TMP/picture.mp4

# Sound: dark ambient drone + two synthesized sub-booms on the hard cuts (4.0 s, 11.0 s)
BOOM="aevalsrc='0.9*sin(2*PI*(42+38*exp(-t*7))*t)*exp(-t*1.8)':s=48000:d=3"
ffmpeg -v error -y -i $TMP/picture.mp4 -ss 2 -t 18 -i assets/music/dark_ambient_atlasaudio.mp3 \
  -f lavfi -i "$BOOM" -f lavfi -i "$BOOM" -filter_complex "\
[1:a]aresample=48000,afade=in:st=0:d=1.5,afade=out:st=15.5:d=2.5,volume=0.9[m];\
[2:a]adelay=4000|4000,volume=0.5[b1];[3:a]adelay=11000|11000,volume=0.8[b2];\
[m][b1][b2]amix=inputs=3:normalize=0,atrim=duration=18,loudnorm=I=-14:TP=-1.5:LRA=11,aformat=channel_layouts=stereo[a]" \
  -map 0:v -map "[a]" -c:v libx264 -preset slow -crf 20 -maxrate 12M -bufsize 24M -profile:v high -pix_fmt yuv420p -r $FPS -c:a aac -b:a 192k -ar 48000 -movflags +faststart $OUT/final.mp4
ffprobe -v error -show_entries format=duration,size -of compact $OUT/final.mp4
