#!/bin/bash

# Oculus Wine Wrapper
#
# (C) 2014 Jared Stafford (jspenguin@jspenguin.org)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

IFS=

[ -z "$WINE" ] && WINE=wine

while [[ ${1:0:1} = "-" ]]; do
	case "$1" in
		-o|--ovrd)			OVRD="$2"; shift;;
		-r|--norestart)		NORESTART=1;;
		-k|--nokill)		NOKILL=1;;
		-u|--utilsdir)		UTILSDIR="$2"; shift;;
	esac
	shift
done

if [ -z $OVRD ]; then
    OVRD=/usr/bin/ovrd
fi

if [ -z $UTILSDIR ]; then
	UTILSDIR=/usr/share/oculus-wine-wrapper
fi

if [ ! -x $OVRD ]; then
    echo "Cannot run $OVRD"
    exit 1
fi

if [ ! -d $UTILSDIR ]; then
	echo "Cannot find utilities"
	exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 [options] /path/to/game.exe [arguments]"
	echo "$0 options:"
	echo "  -o, --ovrd       specify location of ovrd (default /usr/bin/ovrd)"
	echo "  -u, --utilsdir      specify location of wrapper utilities (default /usr/share/oculus-wine-wrapper)"
	echo "  -r, --norestart     don't re-execute ovrd after game exits"
	echo "  -k, --nokill        don't kill running ovrd service"
    exit 1
fi

if [ -z $NOKILL ]; then
	old_oculus_pid=$(pidof ovrd)
	kill -TERM $old_oculus_pid
	# wait 3 seconds for it to quit
	i=15
	while [ ! -z $(pidof ovrd) -o $i -gt 0 ]; do
		sleep 0.2
		i=$(($i - 1))
	done
	if [ ! -z $(pidof ovrd) ]; then
		echo "Unable to kill running $OVRD process"
		exit 1
	fi
fi

LD_PRELOAD=$UTILSDIR/no_xselectinput.so $OVRD & oculus_pid=$!
sleep .5
if ! kill -0 $oculus_pid 2>/dev/null; then
    echo "oculus service exited prematurely: is another instance already running?"
    exit 1
fi

while [ ! -e /dev/shm/OVR* ]; do
    if ! kill -0 $oculus_pid $ 2>/dev/null; then
        wait
        echo "ovrd exited without creating SHM"
        exit 1
    fi
    sleep .1
done
$WINE $UTILSDIR/oculus_shm_adapter.exe & wine_pid=$!
sleep .1

$WINE "$@"
echo
echo "Game exited, stopping service..."
echo
kill $wine_pid
kill $oculus_pid
wait

if [ -z $NORESTART ]; then
	echo "Killing and re-forking $OVRD"
	nohup $OVRD > /dev/null &
fi
