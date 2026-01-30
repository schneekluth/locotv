$BASE_PATH = $PSScriptRoot
$INPUT_VIDEO_FILE = "$BASE_PATH\00_videos.txt"

$fileContent = Get-Content -Encoding UTF8 $INPUT_VIDEO_FILE

foreach ($line in $fileContent) {
    $name = $line.Split('/')[-1]

    Write-Host "Downloading $line"
    yt-dlp $line -o "$BASE_PATH\$name"
}

$files = Get-ChildItem -Path $BASE_PATH\* -File -Exclude @("*.ps1", "*.txt")

foreach ($file in $files) {
    Write-Host "Converting $($file.FullName)"
    $filenameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($file)

    ffmpeg -y -i $($file.FullName) -pix_fmt yuvj420p -q:v 7 -vf "fps=24,crop=in_w:in_w*4/3:0:(in_h-in_w*4/3)/2,scale=240:-1:flags=lanczos" $BASE_PATH\$filenameNoExt.mjpeg

    Write-Host "Deleting $($file.FullName)"
    Remove-Item -Path $file
}

Write-Host "`n$($files.Length) videos files found. Please adjust MAX_FILES to this value in locotv.ino.`n" -ForegroundColor Yellow
