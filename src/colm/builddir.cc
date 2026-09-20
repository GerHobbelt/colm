#include "config.h"
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <string.h>

#ifdef __APPLE__
#include <mach-o/dyld.h>
#endif

#define COLM_PATH_1 ABS_BUILDDIR "/" LT_OBJDIR "colm"
#define COLM_PATH_2 ABS_BUILDDIR "/colm"

char *defaultBuildDir() {

#if defined(__linux__)
	struct stat self;
	if ( stat( "/proc/self/exe", &self ) == 0 ) {
		struct stat colm;

		if ( stat ( COLM_PATH_1, &colm ) == 0 &&
				self.st_dev == colm.st_dev && self.st_ino == colm.st_ino )
		{
			return (char*)ABS_TOP_BUILDDIR;
		}

		if ( stat ( COLM_PATH_2, &colm ) == 0 &&
				self.st_dev == colm.st_dev && self.st_ino == colm.st_ino )
		{
			return (char*)ABS_TOP_BUILDDIR;
		}
	} 
#elif defined(__APPLE__)
    static char path[PATH_MAX];
    uint32_t size = sizeof(path);
    if (_NSGetExecutablePath(path, &size) == 0) {
        char *rp = realpath(path, NULL);
		if ( rp != NULL ) {
			// Check if we're running from the build directory
			if ( strcmp(rp, COLM_PATH_1) == 0 || 
			     strcmp(rp, COLM_PATH_2) == 0 ) {
				free(rp);
				return (char*)ABS_TOP_BUILDDIR;
			}
			
			free(rp);
		}
	}
#endif
	return 0;
}
