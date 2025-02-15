from picamera2.encoders import H264Encoder, Quality
from picamera2 import Picamera2, MappedArray
from picamera2.outputs import FfmpegOutput
import time


picam2 = Picamera2()
video_config = picam2.create_video_configuration(main={"size":(1920,1080)})
picam2.configure(video_config)

encoder = H264Encoder(bitrate=8000000)
output = FfmpegOutput("/mnt/tgz/recordings/pi5cam.mp4", audio=False)

picam2.start_recording(encoder, output, quality=Quality.VERY_HIGH)
time.sleep(10)
picam2.stop_recording()
