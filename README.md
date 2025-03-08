# zerocam
Pi Zero 2 W with Camera Module 3

The purpose of this is to build a small, relatively cheap dash camera setup.  The initial cam.sh script is used for testing different camera functions, outputs, conversion, etc.  

Don't expect anything groundbreaking here.  

The end goal is to:
1) Write something in Python, even if Python uses too many Zero 2 resources.
2) Add on/off buttons to start/stop the camera via GPIO.
3) Configure rsync to transfer when connected to a <i>specific</i> Wi-Fi network.  The target server will be doing the h264 to mp4 conversion - it's just in the cam.sh for benchmarking.
4) Add a battery backup.
5) Add a graceful shutdown if 12v power has been cut, using the backup battery with NUT to power down the Zero 2.


Also, I don't know how to use github or versioning properly.  Leave me alone.
