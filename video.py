from picamera2.encoders import H264Encoder, Quality
from picamera2 import Picamera2, MappedArray
from picamera2.outputs import FfmpegOutput
import time
import datetime
import os


# Get current time for timestamp
now = datetime.datetime.now()
timestamp = now.strftime("%Y%m%d_%H%M%S")
filename = f"{timestamp}.mp4"
path = "/mnt/tgz/recordings"

# Ensure the directory exists
os.makedirs(path, exist_ok=True)

# Define the full path for the video file
full_path = os.path.join(path, filename)

# Start the camera and configure video settings
picam2 = Picamera2()
video_config = picam2.create_video_configuration(
    main={"size":(1920,1080), "format": "RGB888"})
picam2.configure(video_config)
picam2.set_controls({"FrameRate": 60})

# Set up H264 encoder with bitrate
encoder = H264Encoder(bitrate=8000000)

# Set up the output path for the video file
output = FfmpegOutput(full_path)

# Print where the video will be saved
print(f"Video saving to {full_path}")

# Start recording
picam2.start_recording(encoder, output, quality=Quality.VERY_HIGH)
time.sleep(3600)

# Stop recording
picam2.stop_recording()
