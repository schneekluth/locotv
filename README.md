# LocoTV

LocoTV is a portrait video player device for children based on the Cheap Yellow Display (CYD). The project name originates from my nephew, who enthusiastically enjoys watching videos of old steam locomotives.

![alt text](final-iso.png)

The device is housed in a [3D printed case](stl/) and plays a series of MJPEG files stored on an SD card. A [PowerShell script](script/00_convert.ps1) for batch downloading and video conversion is included in this repository.

> [!NOTE]
> For detailed instructions on wiring, the bill of materials, and assembly, please refer to the accompanying [blog post](https://jbetzen.net/posts/locotv/).

## Quick Setup

1. [Download](https://github.com/schneekluth/locotv/archive/refs/heads/main.zip) the code and extract the ZIP archive.
2. Rename folder from `locotv-main` to `locotv`.
3. Open [`locotv.ino`](locotv.ino) in the Arduino IDE.
4. Format SD card in FAT32 and copy folder [`mjpeg/`](SD%20Content/mjpeg/) content to the SD card.
5. Connect the CYD to your computer.
6. In Arduino IDE:
    + Got to Preferences and make sure the following URL is present in Additional Board Manager URLs:

        ```
        https://espressif.github.io/arduino-esp32/package_esp32_index.json
        ```
    + Open Board Manager and select/install `esp32` version `3.2.0`
    + Open Library Manager and install two libraries:
        + [GFX Library for Arduino](https://github.com/moononournation/Arduino_GFX) version `1.6.0`
        + [JPEGDEC](https://github.com/bitbank2/JPEGDEC) version `1.8.2`
    + Install touchscreen library [`TFT_Touch_v0.3.zip`](TFT_Touch_v0.3.zip) using `Sketch > Include Library > Import .ZIP Library…`
    + Select the board variant `ESP32 Dev Module` and set correct USB port.
    + Set baudrate to `115200` under `Tools > Upload Speed`
    + Upload code to the board using `Sketch > Upload`

## Convert your own videos

1. Open [`00_videos.txt`](script/00_videos.txt) and paste links to videos line by line. Use videos in portrait mode e.g. YouTube shorts.
2. Open a terminal and run the PowerShell script [`00_convertps1`](script/00_convert.ps1).
3. Copy converted MJPEG files to the `mjpeg/` folder on the SD card.
4. Adjust value [`MAX_FILES`](https://github.com/schneekluth/locotv/blob/main/locotv.ino#L38) to match the amount of videos copied to the SD card.
5. Reupload code to the board in Arduino IDE

## Credits

+ [thelastoutpostworkshop](https://github.com/thelastoutpostworkshop) for provding the initial code: [esp32-2432S028_video_player](https://github.com/thelastoutpostworkshop/esp32-2432S028_video_player)
+ [https://github.com/kiwiholmberg](https://github.com/kiwiholmberg) for his fork with improved touchscreen support: [cyd-video-player](https://github.com/kiwiholmberg/cyd-video-player)
