# zerocam
Pi Zero 2 W with Camera Module 3

The purpose of this is to build a small, relatively cheap dash camera setup.  The initial cam.sh script is used for testing different camera functions, outputs, conversion, etc.  

Don't expect anything groundbreaking here.  

The end goal is to write something in Python, add on/off buttons to start/stop the camera via GPIO, and configure rsync to transfer when connected to a specific Wi-Fi network.  The target server will be doing the h264 to mp4 conversion - it's just in the cam.sh for benchmarking.
