#!/bin/bash
#export DISPLAY=0
# Camera Settings
# -t = time limit is ~1 hour
# --bitrate = ~6000kbps
# --autofocus-mode manual or auto
# --width & --height = normal stuff
# --framerate should be 30 max for our purposes.  24 is used now.
# --nopreview means it won't try to show it on a screen
# --output = defined in the raw variable
# --tuning-file is based on your sensor.  For this purpose, I'm using the Camera Module 3. 

# Let's make a variable for the raw file
raw=$(date +%Y%m%d_%H%M).raw

# Run libcamera with these options, defined above.
libcamera-vid -t 3601s --bitrate 6000000 --autofocus-mode auto --width 1920 --height 1080 --framerate 24 --nopreview --output $raw --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json

# Video Conversion
for video in `ls $raw`
  do
    ffmpeg -framerate 24 -i $video -c copy "$video.mp4"
  done

# Strip out the .raw to make the file name cleaner
for rename in `ls *.mp4`
  do
    mv "$rename" "`echo $rename | sed 's/.raw//'`"
  done

# This checks for a connection to a server. If there isn't a connection, it dies.  If there is a connection, it'll rsync the files, remove the local files, then quit.
SERVER=10.0.0.1
for i in `ls *.mp4`; do
  /usr/bin/ping -c 1 $SERVER &> /dev/null
    if [[ $? -ne 0 ]]; then
      /usr/bin/printf "Couldn't rsync - files not deleted"
    else
      /usr/bin/rsync -avu --ignore-existing "/home/blane/cam/$i" /mnt/tgz/recordings/
      /usr/bin/sleep 3
      /usr/bin/rm -rf *.raw *.mp4
      /usr/bin/printf "\n\nLocal files deleted\n\n"
    fi
done
