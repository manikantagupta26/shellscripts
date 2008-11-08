#!/bin/sh
#
# SCRIPT: icons2dim.sh
# AUTHOR: Janos Gyerik <janos.gyerik@gmail.com>
# DATE:   2008-11-08
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent
#
# PURPOSE: Resize icon images to have specified width and height.
#		* extra pixels are sliced off evenly from all edges
#		* pad with transparent pixels evenly to all edges
#		* resized icons are saved in specified target directory
#		* requires ImageMagick ('convert')
#
# REV LIST:
#        DATE:	DATE_of_REVISION
#        BY:	AUTHOR_of_MODIFICATION   
#        MODIFICATION: Describe what was modified, new features, etc-
#
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo "Resize icon images to have specified width and height."
    echo
    echo "  -w, --width WIDTH    default = $width"
    echo "  -h, --height HEIGHT  default = $height"
    echo "  -o, --outdir OUTDIR  default = $outdir"
    echo
    echo "  -h, --help           Print this help"
    echo
    exit 1
}

neg=0
args=
#arg=
#flag=off
#param=
width=16
height=16
outdir=out
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
#    !) neg=1; shift; continue ;;
#    -f|--flag) test $neg = 1 && flag=off || flag=on ;;
#    -p|--param) shift; param=$1 ;;
    -w|--width) shift; width=$1 ;;
    -h|--height) shift; height=$1 ;;
    -o|--outdir) shift; outdir=$1 ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
    neg=0
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

test $# = 0 && usage

# params: cmd
require_cmd() {
    if ! type "$1" | grep -o /.\* >/dev/null; then
	echo "Required command '$1' is missing, install it first. Exit." >&2
	exit 1
    fi
}
require_cmd convert
require_cmd expr

workdir=/tmp/.$$-icons2dim.sh
trap 'rm -fr $workdir; exit 1' 1 2 3 15

mkdir $workdir
sourcefile=$workdir/source.png
outfile=$workdir/out.png
x1=$workdir/1x1.png
cat $0 | sed -ne '/^# eof/ {
:next
n
p
b next
}' > $x1

mkdir -p "$outdir"

for i in "$@"; do
    wh=$(identify -format '%w %h' "$i" 2>/dev/null) || continue
    set -- $wh
    w=$1
    h=$2
    test $w = $width -a $h = $height && continue
    echo resizing $i ...
    convert "$i" $sourcefile
    if test $w -lt $width; then
	diff=$(expr $width - $w)
	half=$(expr $diff / 2)
	mod=$(expr $diff % 2)
	before=$half
	after=$(expr $half + $mod)
	args=
	for j in $(seq 1 $before); do
	    args="$args$x1 "
	done
	args="$args$sourcefile "
	for j in $(seq 1 $after); do
	    args="$args$x1 "
	done
	convert -background transparent +append $args $outfile
	cp $outfile $sourcefile
    fi
    if test $w -gt $width; then
	echo to cut width
    fi
    if test $h -lt $height; then
	diff=$(expr $height - $h)
	half=$(expr $diff / 2)
	mod=$(expr $diff % 2)
	before=$half
	after=$(expr $half + $mod)
	args=
	for j in $(seq 1 $before); do
	    args="$args$x1 "
	done
	args="$args$sourcefile "
	for j in $(seq 1 $after); do
	    args="$args$x1 "
	done
	convert -background transparent -append $args $outfile
	cp $outfile $sourcefile
    fi
    if test $h -gt $height; then
	echo to cut height
    fi
    convert $outfile "$outdir"/$(basename "$i")
done

rm -fr $workdir
exit

# eof
�PNG

   IHDR         ��A   bKGD���Y]   	pHYs   H   H F�k>   	vpAg   	    d�KG   IDAT�c````    ^�*:    IEND�B`�
