# eydl.sh - Enhanced YouTube Downloader Script
### by dieselbaby

`eydl.sh` is a powerful bash script that allows you to download videos from YouTube, extract audio, create video clips, and more. It utilizes the `yt-dlp` and `ffmpeg` tools to provide a comprehensive set of features for working with YouTube content while attempting to remain true to the idea of being a **SIMPLE** command-line tool that any bozo can use.  The hope is that even a novice user can copy and paste the source to the .sh file and save it on their PC, and (provided that they have the prerequisite tools installed), can be downloading and modifying content from YouTube within 30 seconds.  I personally felt a bit overwhelmed when I first started working with tools like `ffmpeg` due to the *many* options it comes with, and this was only compounded when `yt-dlp` and other YouTube downloader scripts came into the mix, so I put this together to cover what I considered the base functionality and most popular features your average user would want.

## Prerequisites

To use `eydl.sh`, you need the following:

- `bash` (duh...if you are on Windows—ugh—you should be using Windows Subsystem for Linux aka WSL2)
- `yt-dlp` (a fork of the popular `youtube-dl` tool, github.com/yt-dlp/yt-dlp)
- `ffmpeg`
- `curl`
- `jq` (for the optional file.io upload feature)


## Features

`eydl.sh` provides the following features:

1. **Download YouTube Videos**: Download videos from YouTube in various resolutions and frame rates.  This should be self-explanatory.
2. **Download YouTube Playlists**: Download entire playlists from YouTube, either as individual video files or as an audio-only playlist.
3. **Create Video Clips**: Extract specific time segments from a downloaded video and save them as separate clips.  *Working to enable the ability to generate/create these clips from the underlying source file without having to download the entire video first, feature not stable yet.*
4. **Extract Audio**: Extract the audio from a downloaded video and save it as an MP3 or WAV file.  Can be combined with the clip feature to make very fast audio clips for use as "sounders" or soundboard clips on livestream or group calls, set the parameters, run the command then drag-and-drop the files into your Elgato Stream Deck directory and click away.
5. **Zip and Upload**: Create a ZIP archive of downloaded audio files and upload it to file.io (optional).  Why audio?  Well, I originally created this as a way to quickly grab different full album playlists on YouTube, ditch the video and strip out the audio only, convert them to mp3s and then put the whole bunch into an archive, uploaded to the free file io service so I could download the archive to my phone or another device, for listening to in the car.  Yeah, I know...lazy, but whatever, I already made it.

## Usage/syntax and examples

Run the command by calling `eydl.sh` via the direct path in bash, or, preferably, add it to your $PATH and do it that way.

### General Arguments

- `--videoid <video_id>`: The YouTube video ID or URL to download.  The "video ID" in this case is the alphanumeric hash that comes after the `?v=` part in the YouTube URL, i.e. `https://youtube.com/watch?v={video ID}`.  **Note**:  This script also accepts the submission of the ID hash itself, as well as URLs in the `https://youtu.be` format, it will automatically recognize the input.
- `-s, --source <directory>`: The source directory for the input file(s), for use if you are making clips from downloaded videos, etc.  Specify the full path, do not include the trailing `/`
- `-d, --destination <directory>`: The destination directory for the downloaded files...aka where you want your stuff.

### Video Download Options

- `--360p`, `--480p`, `--720p`, `--1080p`, `--1440p`, `--4k`: Set the desired video resolution.
- `--30fps`, `--60fps`: Set the desired video framerate.
- `--audio-only`: Download the audio-only version of the video.  This defaults to 192kbps VBR (I think...I forgot what I set it to lol).
- `--mp3`, `--wav`: Set the audio format for the extracted audio.

### Other Options

- `--multiclip`: Create multiple video clips from the downloaded video.  See the examples below, this will let you create numerous individual clips (that can cross over each other if you wish, you just have to specify the timespan ranges for the clips and `eydl.sh` will automatically map them out into respective individual files.)
- `-t, --timestamps <start-end,start-end,...>`: Specify the time ranges for creating video clips.
- `--strip-audio`: Extract the audio from the downloaded video.
- `--playlist`: Download a YouTube playlist instead of a single video.
- `--zip`: Create a ZIP archive of the downloaded audio files.
- `--upload`: Upload the ZIP archive to file.io.

### Examples

1. Download a video in 1080p resolution:

`./eydl.sh --videoid 52h3CRiDHoo --1080p` or `./eydl.sh https://www.youtube.com/watch?v=52h3CRiDHoo --1080p` (**note** it will automatically download at the highest available resolution if you don't specify one)

2. Download a playlist in audio-only format:

`./eydl.sh --videoid https://www.youtube.com/playlist?list=PL-osiE80TeTtoQCKZ03TU5fNfx2UY6U4p --audio-only`

3. Create multiple video clips from a downloaded video:

`./eydl.sh --videoid 52h3CRiDHoo --multiclip -t 00:00:10-00:00:20,00:00:30-00:00:40`

4. Extract the audio from a downloaded video and upload the ZIP archive:
   
`./eydl.sh --videoid 52h3CRiDHoo --strip-audio --zip --upload`

For more information and detailed usage, please refer to the comments and documentation within the `eydl.sh` script itself.

## Contributing

If you find any issues or have suggestions for improvement, feel free to open an issue or submit a PR.  I'll frankly just be happy if anyone even winds up using this, after all the of the tinkering I've done with the thing.

## License

This project is licensed under the [MIT License](LICENSE).

