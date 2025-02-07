#!/bin/bash
#export DISPLAY=:0

# Camera Settings
libcamera-vid -t 3601s --bitrate 6000000 --autofocus-mode manual --width 1280 --height 720 --framerate 30 --nopreview --output $(date +%Y%m%d_%H%M.h264) --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json

# Video Conversion
for video in `ls *.h264`; do ffmpeg -framerate 24 -i $video -c copy $video\ converted.mp4; done

# Let's free up space by removing the original file.  Will remove this section later in the Python version
rm -rf *.h264
