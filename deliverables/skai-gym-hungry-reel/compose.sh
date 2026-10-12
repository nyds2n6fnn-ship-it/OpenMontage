#!/usr/bin/env bash
# Final assembly: hook full-screen → circle-close → infographics (HyperFrames layer) + face bubble.
set -euo pipefail
cd "$(dirname "$0")"
SRC=assets/source/IMG_8144.MOV; INFO=assets/infographic.mp4; MASK=assets/circle_mask.png
T=2.75; D=0.5        # transition start / length (hook line ends ~3.0 s)
ffmpeg -v error -y -i "$SRC" -i "$INFO" -loop 1 -i "$MASK" -filter_complex "\
[0:v]split[v1][v2];\
[v1]fps=30,settb=1/30,scale=1080:1920:flags=lanczos,eq=contrast=1.04:saturation=1.05,setsar=1,format=yuv420p[full];\
[v2]fps=30,crop=440:440:180:480,scale=480:480:flags=lanczos,eq=contrast=1.04:saturation=1.05,format=rgba[face];\
[2:v]format=gray,trim=duration=26.7[m];[face][m]alphamerge[bubble];\
[1:v][bubble]overlay=300:1120:shortest=1,format=yuv420p,trim=start=$T,setpts=PTS-STARTPTS,fps=30,settb=1/30[info];\
[full][info]xfade=transition=circleclose:duration=$D:offset=$T,format=yuv420p[v];\
[0:a]loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[a]" \
  -map "[v]" -map "[a]" -r 30 -c:v libx264 -preset slow -crf 20 -maxrate 10M -bufsize 20M -profile:v high \
  -c:a aac -b:a 192k -movflags +faststart -t 26.69 renders/final.mp4
ffprobe -v error -show_entries format=duration,size -of compact renders/final.mp4
