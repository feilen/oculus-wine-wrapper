Oculus Wine Wrapper
===================

This is a wrapper which allows some Windows Oculus games to run on Linux under
Wine, using the native Linux runtime.

* Main page: https://www.jspenguin.org/software/ovrsdk/
* Discussion: https://www.reddit.com/r/oculus/comments/2k8fuq/run_windows_rift_games_on_linux_using_wine/
* Development: https://github.com/jspenguin/oculus-wine-wrapper

To run Oculus games under Wine,  run:

    cd /PATH/TO/GAME
    oculus_wine_wrapper.sh <-o /path/to/oculusd> <-u /path/to/utilsdir> game.exe

This assumes you have installed oculus_wine_wrapper.sh to /usr/bin, and the 
utilities it needs to /usr/share/oculus-wine-wrapper. If you have unpacked 
them somewhere else, just replace the paths.

The Oculus runtime daemon (oculusd) uses shm_open to create the shared memory
object that games use to access the tracker with low latency. On Windows,
instead of using a regular file, the Oculus service creates a named file mapping
object which games open using OpenFileMapping.

This script starts oculus_shm_adapter.exe under wine, which opens the file
/dev/shm/OVRObjectXX, and registers a named mapping with wineserver so that
games can access it. It also launches 'oculusd' with an injected library which
prevents it from trying to treat the HWND that the game sends as an X Window ID.

You may have to fiddle around with changing the primary display in order for the
game to actually show up on the Rift.
