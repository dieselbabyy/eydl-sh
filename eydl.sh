#!/bin/bash

# Function to extract video title from YouTube page
get_video_title() {
    local video_id="$1"
    local url="https://www.youtube.com/watch?v=$video_id"
    local title=$(curl -s "$url" | grep -oP '(?<=<meta name="title" content=").*(?=">)')
    echo "$title" | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_//; s/_$//'
}

# Function to show progress
show_progress() {
    local video_title="$1"
    local percentage="$2"

    LR='\033[1;31m'
    LG='\033[1;32m'
    LY='\033[1;33m'
    LC='\033[1;36m'
    LW='\033[1;37m'
    NC='\033[0m'

    if [ "${percentage}" = "0" ]; then TME=$(date +"%s"); fi
    SEC=`printf "%04d\n" $(($(date +"%s")-${TME}))`; SEC="$SEC sec"
    PRC=`printf "%.0f" ${percentage}`
    SHW=`printf "%3d\n" ${PRC}`
    LNE=`printf "%.0f" $((${PRC}/2))`
    LRR=`printf "%.0f" $((${PRC}/2-12))`; if [ ${LRR} -le 0 ]; then LRR=0; fi;
    LYY=`printf "%.0f" $((${PRC}/2-24))`; if [ ${LYY} -le 0 ]; then LYY=0; fi;
    LCC=`printf "%.0f" $((${PRC}/2-36))`; if [ ${LCC} -le 0 ]; then LCC=0; fi;
    LGG=`printf "%.0f" $((${PRC}/2-48))`; if [ ${LGG} -le 0 ]; then LGG=0; fi;
    LRR_=""
    LYY_=""
    LCC_=""
    LGG_=""

    for ((i=1;i<=13;i++))
    do
        DOTS=""; for ((ii=${i};ii<13;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LRR_="${LRR_}#"; else LRR_="${LRR_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${DOTS}${LY}............${LC}............${LG}............ ${SHW}%  ${video_title}${NC}\r"
        if [ ${LNE} -ge 1 ]; then sleep .05; fi
    done
    for ((i=14;i<=25;i++))
    do
        DOTS=""; for ((ii=${i};ii<25;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LYY_="${LYY_}#"; else LYY_="${LYY_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${DOTS}${LC}............${LG}............ ${SHW}%  ${video_title}${NC}\r"
        if [ ${LNE} -ge 14 ]; then sleep .05; fi
    done
    for ((i=26;i<=37;i++))
    do
        DOTS=""; for ((ii=${i};ii<37;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LCC_="${LCC_}#"; else LCC_="${LCC_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${LC}${LCC_}${DOTS}${LG}............ ${SHW}%  ${video_title}${NC}\r"
        if [ ${LNE} -ge 26 ]; then sleep .05; fi
    done
    for ((i=38;i<=49;i++))
    do
        DOTS=""; for ((ii=${i};ii<49;ii++)); do DOTS="${DOTS}."; done
        if [ ${i} -le ${LNE} ]; then LGG_="${LGG_}#"; else LGG_="${LGG_}."; fi
        echo -ne "  ${LW}${SEC}  ${LR}${LRR_}${LY}${LYY_}${LC}${LCC_}${LG}${LGG_}${DOTS} ${SHW}%  ${video_title}${NC}\r"
        if [ ${LNE} -ge 38 ]; then sleep .05; fi
    done
}

# Function to download video with progress
download_video() {
    local video_id="$1"
    local output_template="$2"
    local video_title=$(get_video_title "$video_id")
    yt-dlp -f "$resolution[fps=$framerate]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
           --merge-output-format mp4 \
           -o "$output_template" \
           --newline \
           --progress \
           "https://www.youtube.com/watch?v=$video_id" | \
    while IFS= read -r line; do
        if [[ $line =~ ^[0-9.]+% ]]; then
            percentage=$(echo "$line" | cut -d' ' -f1 | tr -d '%')
            show_progress "$video_title" $percentage
        fi
    done
    echo
    echo -e "     \033[1;32;5mOperation Successfully Completed!\033[0m"
    echo -e "     Your requested file has been downloaded to ${destination_directory}/${video_title}.mp4"
}

# Function to download playlist with progress
download_playlist() {
    local playlist_url="$1"
    local output_dir="$2"
    local audio_only="$3"

    if [ "$audio_only" = true ]; then
        yt-dlp -o "$output_dir/%(playlist_index)02d-%(title)s.%(ext)s" \
               --restrict-filenames \
               --extract-audio \
               --audio-format mp3 \
               --audio-quality 192K \
               --yes-playlist \
               --newline \
               --progress \
               "$playlist_url" | \
        while IFS= read -r line; do
            if [[ $line =~ ^[0-9.]+% ]]; then
                percentage=$(echo "$line" | cut -d' ' -f1 | tr -d '%')
                show_progress "%(title)s" $percentage
            fi
        done
        echo
        echo -e "     \033[1;32;5mOperation Successfully Completed!\033[0m"
        echo -e "     Your audio playlist has finished downloading and is located at ${destination_directory}"
    else
        yt-dlp -o "$output_dir/%(playlist_index)02d-%(title)s.%(ext)s" \
               --restrict-filenames \
               --yes-playlist \
               --newline \
               --progress \
               "$playlist_url" | \
        while IFS= read -r line; do
            if [[ $line =~ ^[0-9.]+% ]]; then
                percentage=$(echo "$line" | cut -d' ' -f1 | tr -d '%')
                show_progress "%(title)s" $percentage
            fi
        done
        echo
        echo -e "     \033[1;32;5mOperation Successfully Completed!\033[0m"
        echo -e "     The individual video files from your playlist URL have been downloaded to the directory located at: ${destination_directory}"
    fi
}

# Function to create clips
create_clips() {
    local input_file="$1"
    local timestamps="$2"
    local output_template="$3"
    local is_audio_only="$4"
    local audio_format="$5"
    local video_title="$6"

    IFS=',' read -ra RANGES <<< "$timestamps"
    for range in "${RANGES[@]}"; do
        start=$(echo $range | cut -d'-' -f1)
        end=$(echo $range | cut -d'-' -f2)
        start_seconds=$(date -d "1970-01-01 $start" +%s.%N)
        end_seconds=$(date -d "1970-01-01 $end" +%s.%N)
        duration=$(echo "$end_seconds - $start_seconds" | bc)
        if [ "$is_audio_only" = true ]; then
            output_file="${output_template}_audio_clip_$(echo $start | tr ':.' '')_$(echo $end | tr ':.' '').$audio_format"
            ffmpeg -ss "$start" -i "$input_file" -t "$duration" -vn -acodec copy "$output_file"
        else
            output_file="${output_template}_clip_$(echo $start | tr ':.' '')_$(echo $end | tr ':.' '').mp4"
            ffmpeg -ss "$start" -i "$input_file" -t "$duration" -c copy "$output_file"
        fi
        echo "Created clip: $output_file"
    done
    echo -e "     \033[1;32;5mOperation Successfully Completed!\033[0m"
    echo -e "     Your requested clips from ${video_title} have been saved to ${destination_directory}"
}

# Function to strip audio
strip_audio() {
    local input_file="$1"
    local output_file="$2"
    local audio_format="$3"
    local video_title="$4"

    if [ "$audio_format" == "mp3" ]; then
        ffmpeg -i "$input_file" -vn -ar 44100 -ac 2 -ab 192k "$output_file"
    elif [ "$audio_format" == "wav" ]; then
        ffmpeg -i "$input_file" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$output_file"
    else
        echo -e "     \033[1;31;5mError: Invalid audio format: $audio_format\033[0m"
        exit 1
    fi
    echo -e "     \033[1;32;5mOperation Successfully Completed!\033[0m"
    echo -e "     Your audio-only version of the video ${video_title} has finished downloading to ${destination_directory}/${video_title}_audio.$audio_format"
}

# Function to generate timestamp
generate_timestamp() {
    date +'%Y-%b-%d-%H%M'
}

# Function to create zip archive from downloaded YouTube playlist of mp3s
create_archive() {
    local output_dir="$1"
    local timestamp="$2"
    local zip_name="archive-$timestamp.zip"
    zip -j "$output_dir/$zip_name" "$output_dir"/*
    echo -e "     \033[1;32;5mOperation Successfully Completed!\033[0m"
    echo -e "     Your audio playlist has finished downloading and is located at ${output_dir}/$zip_name, saved as an archive which was uploaded to ${url}"
}

# Function to upload file to file.io with progress indicators
upload_file() {
    local file_path="$1"
    echo "Uploading file to file.io..."
    local response=$(curl -# -F "file=@$file_path" https://file.io)
    local url=$(echo $response | jq -r '.link')
    echo -e "     \033[1;32;5mUpload Complete.\033[0m Download URL: $url"
}

# Function to extract video ID from different YouTube video page URL formats
get_video_id() {
    local input="$1"
    local video_id=""

    if [[ $input =~ ^https://youtu\.be/([^?]+) ]]; then
        video_id="${BASH_REMATCH[1]}"
    elif [[ $input =~ ^https://www\.youtube\.com/watch\?v=([^&]+) ]]; then
        video_id="${BASH_REMATCH[1]}"
    elif [[ $input =~ ^[a-zA-Z0-9_-]{11}$ ]]; then
        video_id="$input"
    else
        echo -e "     \033[1;31;5mError: Invalid YouTube URL or video ID\033[0m"
        exit 1
    fi

    echo "$video_id"
}

# Primary script components and default parameters
video_id=""
source_directory=""
destination_directory=""
is_audio_only=false
audio_format="mp3"
multiclip=false
timestamps=""
strip_audio_flag=false
is_playlist=false
create_zip=false
upload=false

resolution="bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]/best"
framerate="60"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --videoid)
            video_id="$2"
            shift 2
            ;;
        -s|--source)
            source_directory="$2"
            shift 2
            ;;
        -d|--destination)
            destination_directory="$2"
            shift 2
            ;;
        --audio-only)
            is_audio_only=true
            shift
            ;;
        --mp3)
            audio_format="mp3"
            shift
            ;;
        --wav)
            audio_format="wav"
            shift
            ;;
        --multiclip)
            multiclip=true
            shift
            ;;
        -t|--timestamps)
            timestamps="$2"
            shift 2
            ;;
        --strip-audio)
            strip_audio_flag=true
            shift
            ;;
        --playlist)
            is_playlist=true
            shift
            ;;
        --zip)
            create_zip=true
            shift
            ;;
        --upload)
            upload=true
            shift
            ;;
        --360p)
            resolution="bestvideo[ext=mp4][height<=360]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            shift
            ;;
        --480p)
            resolution="bestvideo[ext=mp4][height<=480]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            shift
            ;;
        --720p)
            resolution="bestvideo[ext=mp4][height<=720]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            shift
            ;;
        --1080p)
            resolution="bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            shift
            ;;
        --1440p)
            resolution="bestvideo[ext=mp4][height<=1440]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            shift
            ;;
        --4k)
            resolution="bestvideo[ext=mp4][height<=2160]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            shift
            ;;
        --30fps)
            framerate="30"
            shift
            ;;
        --60fps)
            framerate="60"
            shift
            ;;
        *)
            if [ -z "$video_id" ]; then
                video_id=$(get_video_id "$1")
            else
                echo -e "     \033[1;31;5mError: Invalid argument: $1\033[0m"
                exit 1
            fi
            shift
            ;;
    esac
done
