#!/bin/sh

/usr/local/bin/video-usbreset.py

ffmpeg -y -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel  \
	-probesize 10M \
	-analyzeduration 10M \
	-f v4l2 -video_size 1280x720 -i /dev/video2 -f alsa -sample_rate 48000 -channels 2 -i hw:1 \
	-threads:0 0 \
	-aspect 16:9 \
	-filter_complex "[1:a]channelsplit=channel_layout=stereo[left][right]; [0:v] format=nv12,hwupload [vout]" \
	-map '[vout]' \
	-c:v:0 h264_vaapi -rc_mode CQP\
	-g 45 \
	-maxrate:v:0 2000k -bufsize:v:0 8192k \
	-b:v:0 1000k \
	-qmin:v:0 1 \
	\
	-map '[left]:1' \
	-ac 1 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-map '[right]:2' \
	-ac 1 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-y -f mpegts - | /usr/local/bin/sproxy

