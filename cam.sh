#!/bin/bash
# export DISPLAY=0
# Camera Settings
# -t = my time limit is ~1 hour
# --bitrate = ~6000kbps, but you can go as high as the camera allows.
# --autofocus-mode manual or auto.
# --width & --height = normal resolution stuff.
# --framerate should be 30 max for our purposes.  24 is my use case.
# --nopreview means it won't try to show it on a screen.
# --output = defined in the raw variable.
# --tuning-file is based on your sensor.  For this purpose, I'm using the Camera Module 3. 

# First, let's define our working directory so it works in cron.
cd "$(dirname "${BASH_SOURCE[0]}")"

# Let's make a variable for the raw file.
raw=$(date +%Y%m%d_%H%M).raw

# Run libcamera with these options, defined above.
libcamera-vid -t 3601s --bitrate 6000000 --autofocus-mode auto --width 1920 --height 1080 --framerate 24 --nopreview --output $raw --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json

# Video Conversion -- match the framerate in the libcamera-vid command above.
for video in `ls $raw`
  do
    ffmpeg -framerate 24 -i $video -c copy "$video.mp4"
  done

# Strip out the .raw to make the file name cleaner
for rename in `ls *.mp4`
  do
    mv "$rename" "`echo $rename | sed 's/.raw//'`"
  done

# This checks to see if the NFS mount is available (for my storage). If there isn't a connection, it dies.  If there is a connection, it'll rsync the files, remove the local files, then quit.
# You can comment the mount command and uncomment the SERVER and ping lines, or put your own NFS/SMB moutn in the rsync line.

#SERVER=10.0.0.1
for i in `ls *.mp4`; do
#  /usr/bin/ping -c 1 $SERVER &> /dev/null
   /usr/bin/mount | grep nfs &> /dev/null
    if [[ $? -ne 0 ]]; then
      /usr/bin/printf "Couldn't rsync - files not deleted"
    else
      /usr/bin/rsync -avu --ignore-existing $i /mnt/tgz/recordings/
      /usr/bin/sleep 3
      /usr/bin/rm -rf $raw *.mp4
      /usr/bin/printf "\n\nLocal files deleted\n\n"
    fi
done


