# This scripts downloads YouTube videos stored in file '00_videos.txt'
# ans converts them to MJPEG format with 320x240 resolution.
#
# This script requires ffmpeg, ffprobe and yt-dlp to be installed.
# https://www.ffmpeg.org/
# https://github.com/yt-dlp/yt-dlp

$BASE_PATH = $PSScriptRoot
$INPUT_VIDEO_FILE = "$BASE_PATH\00_videos.txt"

if (-not (Test-Path -Path "$BASE_PATH\mjpeg")) {
    New-Item -ItemType Directory -Path "$BASE_PATH\mjpeg"
    Write-Host "Folder created: "$BASE_PATH\mjpeg"" -ForegroundColor Yellow
}

$fileContent = Get-Content -Encoding UTF8 $INPUT_VIDEO_FILE

foreach ($line in $fileContent) {
    if ($line -like "*/shorts/*") {
        $name = $line.Split('/')[-1]
    } elseif ($line -like "https://www.youtube.com/watch?v=*") {
        $name = $line.Split('=')[-1]
    } else {
        name = $line.Split('/')[-1]
    }

    Write-Host "Downloading $line"
    yt-dlp $line -o "$BASE_PATH\$name"
}

$files = Get-ChildItem -Path $BASE_PATH\* -File -Exclude @("*.ps1", "*.txt")

foreach ($file in $files) {
    Write-Host "Converting $($file.FullName)"
    $filenameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($file)

    if (Video-IsPortrait($file)) {
        ffmpeg -y -i $($file.FullName) -pix_fmt yuvj420p -q:v 7 -vf "fps=24,crop=in_w:in_w*4/3:0:(in_h-in_w*4/3)/2,scale=240:-1:flags=lanczos" "$BASE_PATH\mjpeg\portrait_$filenameNoExt.mjpeg"
    } else {
        ffmpeg -y -i $($file.FullName) -pix_fmt yuvj420p -q:v 7 -vf  "transpose=1,fps=24,crop=in_w:in_w*4/3:0:(in_h-in_w*4/3)/2,scale=240:-1:flags=lanczos" "$BASE_PATH\mjpeg\landscape_$filenameNoExt.mjpeg"
    }

    Write-Host "Deleting $($file.FullName)"
    Remove-Item -Path $file
}

Write-Host "`n$($files.Length) video files found. Please adjust line 'MAX_FILES = $($files.Length)' in 'locotv.ino'.`n" -ForegroundColor Yellow

function Video-IsPortrait {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    # Check if file exists
    if (-not (Test-Path $FilePath)) {
        Write-Error "Datei nicht gefunden: $FilePath"
        return $null
    }

    # ffprobe: Extract video dimensions
    $dimensions = ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x $FilePath

    # ffprobe: extract height and width of video e.g. '1080x1920'
    $width, $height = $dimensions.Split('x') | ForEach-Object { [int]$_ }

    # boolean return value if video is in portrait or landscape mode
    if ($height -gt $width) {
        return $true
    } else {
        return $false
    }
}
