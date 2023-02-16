#!/bin/sh
CMD_STATUS="pamixer --get-volume-human"

if [[ `command -v pamixer` == '' ]]; then
	notify-send "Please install pamixer!!"
	exit 1
fi

if [[ $1 == '+' ]]; then
	pamixer -i 5
elif [[ $1 == "-" ]]; then
	pamixer -d 5
elif [[ $1 == "m" ]]; then
	pamixer -t
elif [[ "$1" =~ ^[0-9]+$ ]]; then
	pamixer --set-volume $1
elif [[ $1 != "s" ]]; then
	echo $1
	notify-send "Volume widget error!" "Unknown argument: $1"
	exit 1
fi

echo $($CMD_STATUS)
