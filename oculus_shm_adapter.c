/*
   Oculus Rift shared memory adapter for Wine

   (C) 2014 Jared Stafford (jspenguin@jspenguin.org)

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <windows.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

int main(int argc, char** argv) {
    WIN32_FIND_DATA fdata;
    HANDLE ffhandle;
    printf("Oculus Rift shared memory adapter for Wine\n");
    printf("(C) 2014 Jared Stafford (jspenguin@jspenguin.org)\n");
    printf("Source available at https://jspenguin.org/software/ovrsdk/\n\n");
    if (chdir("/dev/shm") != 0) {
        printf("Could not change directory to /dev/shm: %s\n", strerror(errno));
        return 1;
    }
    if ((ffhandle = FindFirstFile("OVR*", &fdata)) == INVALID_HANDLE_VALUE) {
        DWORD err = GetLastError();
        if (err == 2) {
            printf("Could not find any OVR SHM objects: is service running?\n");
        } else {
            printf("FindFirstFile error: %s\n", strerror(err));
        }
        return 1;
    }

    do {
        HANDLE maph;
        HANDLE fd = CreateFile(fdata.cFileName, GENERIC_READ|GENERIC_WRITE, FILE_SHARE_READ|FILE_SHARE_WRITE,
                               NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
        if (fd == INVALID_HANDLE_VALUE) {
            printf("warning: could not open %s: %s\n", fdata.cFileName, strerror(GetLastError()));
            continue;
        }
        maph = CreateFileMapping(fd, NULL, PAGE_READWRITE, 0, 0, fdata.cFileName);
        if (maph == NULL) {
            printf("warning: could not create mapping for %s: %s\n", fdata.cFileName, strerror(GetLastError()));
            CloseHandle(fd);
            continue;
        }
        printf("Bridged /dev/shm/%s to Win32 named mapping \"%s\"\n", fdata.cFileName, fdata.cFileName);
    } while (FindNextFile(ffhandle, &fdata));

    printf("Done! Sleeping forever to keep objects alive, press Ctrl-C to stop\n");
    while (1) {
        Sleep(1000000);
    }
    return 0;
}
