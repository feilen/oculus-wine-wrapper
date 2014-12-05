To run Oculus games under Wine, first make sure the service is NOT running (the
wrapper starts the service itself with an injected library), then run:

cd /PATH/TO/GAME
~/Downloads/oculus_wine_wrapper/oculus_wine_wrapper.sh ~/Downloads/ovr_sdk_linux_0.4.3 game.exe

This assumes you have unpacked both the wrapper and the SDK in ~/Downloads. If
you have unpacked then somewhere else, just replace the paths.

The Oculus runtime daemon (oculusd) uses shm_open to create the shared memory
object that games use to access the tracker with low latency. On Windows,
instead of using a regular file, the Oculus service creates a named file mapping
object which games open using OpenFileMapping

This program is a bridge which opens the file /dev/shm/OVRObjectXX, and
registers a named mapping with wineserver so that games can access it.

Just run 'oculus_shm_adapter.exe' in a terminal, then run your game. The
adapter has to stay running so that the objects aren't deleted by wineserver,
but does not need to do anything else; it just sleeps forever.

You may have to fiddle around with changing the primary display in order for the
game to actually show up on the Rift.
