import os
import subprocess
import datetime
from picamera2 import Picamera2, PiCameraConfig, FileOutput

def main():
    # Set working directory to script location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # Create raw filename
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M")
    raw_filename = f"{timestamp}.raw"

    try:
        # Initialize camera and set configuration
        camera = Picamera2()
        config = PiCameraConfig(
            resolution=(1920, 1080),
            framerate=24,
            bitrate=6000000,
            autofocus_mode="auto",
            preview_enabled=False,
            tuning_file="/usr/share/libcamera/ipa/rpi/vc4/imx708.json"
        )

        # Start recording
        output = FileOutput(raw_filename)
        camera.start_recording(config, output, wait=True)

        # Record for 3601 seconds (1 hour)
        camera.wait_recording(3601)

        # Stop recording
        camera.stop_recording()
        del camera

        # Convert raw video to MP4 using ffmpeg
        raw_files = os.listdir('.')
        for file in raw_files:
            if file.endswith('.raw'):
                input_file = file
                output_file = f"{os.path.splitext(file)[0]}.mp4"
                subprocess.run([
                    'ffmpeg', '-framerate', '24', '-i', input_file,
                    '-c', 'copy', output_file
                ], check=True)

        # Rename files by stripping .raw extension if necessary
        for mp4_file in os.listdir('.'):
            if mp4_file.endswith('.mp4'):
                new_name = mp4_file.replace('.raw', '')
                if new_name != mp4_file:
                    os.rename(mp4_file, new_name)

        # Check NFS mount and sync files
        nfs_mounted = False
        mounts = subprocess.run(['mount'], capture_output=True, text=True)
        if "nfs" in mounts.stdout.lower():
            nfs_mounted = True

        media_files = [f for f in os.listdir('.') if f.endswith('.mp4')]
        for file in media_files:
            # Sync to server
            if nfs_mounted:
                subprocess.run([
                    'rsync', '-avu', '--ignore-existing',
                    file, '/mnt/tgz/recordings/'
                ], check=True)
                # Remove local files after sync
                os.remove(file)
            else:
                print("Couldn't rsync - files not deleted")

    except Exception as e:
        print(f"Error occurred: {str(e)}")
        # Log the error or send notification if needed

if __name__ == "__main__":
    main()
