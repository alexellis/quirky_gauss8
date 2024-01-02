#!/bin/bash

set -e -x -o pipefail

# Example by Alex Ellis

# Rex Kruger: Should you get a Japanese pull saw?
TARGET=https://www.youtube.com/watch?v=Q7bL61cSUpw

export DEBIAN_FRONTEND=noninteractive

# Add ffmpeg to convert to mp4 later
sudo -E apt-get update -qqqy && \
  time sudo -E apt-get install -qqqy ffmpeg

DL_URL=https://github.com/yt-dlp/yt-dlp/releases/download/2023.11.16/yt-dlp_linux

if [ "$(uname -m)" == "aarch64" ]; then
  DL_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux_aarch64"
fi

sudo curl -LSls -o /usr/local/bin/yt-dlp \
  $DL_URL && \
  sudo chmod +x /usr/local/bin/yt-dlp

mkdir -p videos
mkdir -p uploads

yt-dlp -o "./videos/video.flv" "$TARGET" && \
  du -h -d 0 ./videos/*


mkdir -p audio

# Convert to mp3
cd videos
for i in *; do time ffmpeg -i "$i"  -b:a 128K -vn ../audio/"$i".mp4; done

# Install openai-whisper

pip install -U openai-whisper

# Transcribe using the tiny model

cd ../audio/
whisper audio/*.mp3 --model tiny > ../uploads/"$i".txt
