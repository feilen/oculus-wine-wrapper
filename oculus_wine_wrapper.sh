#!/bin/sh

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
mydir=`cd \`dirname $0\`; pwd`

[ -z "$WINE" ] && WINE=wine

if [ $# -lt 2 ]; then
    echo "Usage: $0 [path to oculusd] [path to game] [arguments]"
    exit 1
fi

OCULUSD=$1
if [ -d $OCULUSD ]; then
    OCULUSD=$OCULUSD/oculusd
fi

if [ ! -x $OCULUSD ]; then
    echo "Cannot run $OCULUSD"
    exit 1
fi

shift

LD_PRELOAD=$mydir/no_xselectinput.so $OCULUSD & oculus_pid=$!
sleep .5
if ! kill -0 $oculus_pid 2>/dev/null; then
    echo "oculus service exited prematurely: is another instance already running?"
    exit 1
fi
while [ ! -e /dev/shm/OVR* ]; do
    if ! kill -0 $oculus_pid $ 2>/dev/null; then
        wait
        echo "oculusd exited without creating SHM"
        exit 1
    fi
    sleep .1
done
$WINE $mydir/oculus_shm_adapter.exe & wine_pid=$!
sleep .1

$WINE "$@"
echo
echo "Game exited, stopping service..."
echo
kill $wine_pid
kill $oculus_pid
wait
