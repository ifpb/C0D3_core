#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	void *m = malloc(100000000);
	memset(m,0,100000000);

	return 0;
}
