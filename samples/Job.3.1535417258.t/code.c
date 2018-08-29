#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	void *m;
    
	while( 1 )
	{
		/* 1 MB per iteration of this loop */
		m = malloc(1024 * 1024 * sizeof( char ));
		memset(m,0,1024 * 1024 * sizeof( char ));
	}

	return 0;
}
