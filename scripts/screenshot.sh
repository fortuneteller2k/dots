#!/bin/sh
#

screenshot() {
	case $1 in
	area)
		selection=$(hacksaw -c e95678 -f "-i %i -g %g")
		shotgun $selection - | xclip -t 'image/png' -selection clipboard
		;;
	full)
		shotgun ~/Pictures/screenshots/$(date "+%B-%d-%Y-%I:%M-%p").png
		;;
	wind)
		shotgun -i $(xdo id) - | xclip -t 'image/png' -selection clipboard
		;;
	*)
		;;
	esac;
}

screenshot $1
