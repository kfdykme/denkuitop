#include "window_configuration.h"
#include <windows.h>
int  screenWidth   =   GetSystemMetrics(   SM_CXSCREEN   );
int  screenHeight   =   GetSystemMetrics(   SM_CYSCREEN   );
const wchar_t* kFlutterWindowTitle = L"denkuitop";
const unsigned int kFlutterWindowWidth = 350;
const unsigned int kFlutterWindowHeight = 720;
const unsigned int kFlutterWindowOriginX = (screenWidth - kFlutterWindowWidth) / 2;
const unsigned int kFlutterWindowOriginY = 10;
