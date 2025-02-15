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

# Let's define a couple variables first...
raw=$(date +%Y%m%d_%H%M).raw
mount=$(mount | grep nfs)
server=/mnt/tgz/recordings

# Run libcamera with these options, defined above.
#
# I can't write directly to the server or all processing would be done there.  The Zero 2 Wi-Fi connection (in my case) is too slow to stream (write) 1080p@24 recorded at 6k bitrate.
# 720p@30 may be more suitable and will be tested.
if [ -z "$mount" ]; then
        printf "NFS mount not found.  Running locally\n\n"

# Run libcamera with these options, defined above.
#
# I can't write directly to the server or all processing would be done there.  The Zero 2 Wi-Fi connection (in my case) is too slow to stream (write) 1080p@24 recorded at 6k bitrate.
# 720p@30 may be more suitable and will be tested.

        libcamera-vid -t 3599s --bitrate 8000000 --width 1920 --height 1080 --framerate 24 --nopreview --output $raw --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json

# Video Conversion -- match the framerate in the libcamera-vid command above.
        for video in `ls $raw`
          do
            ffmpeg -framerate 24 -i $video -c copy "$video.mp4"
          done

# Strip out the .raw to make the file name cleaner
        for rename in `ls *.mp4`
          do
            mv "$rename" "`echo $rename | sed 's/.raw//'`"
            rm $raw
          done

else
        printf "NFS Available. Writing to Server!\n\n"
# Run libcamera with these options, defined above.
# Quick variable for the server mount point.



        libcamera-vid -t 3599s --bitrate 8000000 --width 1920 --height 1080 --framerate 24 --nopreview --output $server/$raw --tuning-file /usr/share/libcamera/ipa/rpi/vc4/imx708.json

# Video Conversion -- match the framerate in the libcamera-vid command above.
        for video in `ls $server/$raw`
          do
            ffmpeg -framerate 24 -i $video -c copy "$video.mp4"
          done

# Strip out the .raw to make the file name cleaner
        for rename in `ls $server/*.raw.mp4`
          do
            mv "$rename" "`echo $rename | sed 's/.raw//'`"
          done

#  This line is no longer needed
#  /usr/bin/rsync -avu --ignore-existing $i /mnt/tgz/recordings/

/usr/bin/sleep 3
/usr/bin/rm -rf $server/$raw
/usr/bin/printf "\n\nRaw files deleted\n\n"
    fi
