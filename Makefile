
MINGW_PFX = i686-w64-mingw32

.DUMMY: all

all: oculus_shm_adapter.exe no_xselectinput.so

oculus_shm_adapter.exe: oculus_shm_adapter.c
	$(MINGW_PFX)-gcc $< -o $@ -Os -shared-libgcc
	$(MINGW_PFX)-strip --strip-unneeded $@

no_xselectinput.so: no_xselectinput.c
	gcc $< -o $@ -shared -fPIC -Os
	strip --strip-unneeded $@
