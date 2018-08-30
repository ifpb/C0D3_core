#include <stdio.h>

int main()
{
	int valor=10;
    long long int i, j;
    
    /* writes 20 MB */
    for( j=0; j<20; j++ )
        /* Each iteration writes 1 MB */
        for( i=0ll; i<52400ll; i++ )
            printf("%d%d%d%d%d%d%d%d%d%d\n", 2ll * valor, valor, valor, valor, valor, valor, valor, valor, valor, valor);
	
	return 0;
}
