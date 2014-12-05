/* The Oculus service calls XSelectInput on the X window that the game
 * gives it, but Windows games send the HWND instead, which causes the
 * service to fail. Just dummy the function out.  */

int XSelectInput(void* display, int w, long valuemask) {
    return 0;
}
