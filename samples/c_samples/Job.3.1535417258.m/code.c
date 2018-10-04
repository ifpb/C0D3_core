#include <stdio.h>
#include <stdlib.h>
#include <string.h>


long long int a[1024*1024]; /* ~ 8 MB */
long long int b[1024*1024]; /* ~ 8 MB */
long long int c[1024*1024]; /* ~ 8 MB */
long long int d[1024*1024]; /* ~ 8 MB */
long long int e[1024*1024]; /* ~ 8 MB */
long long int f[1024*1024]; /* ~ 8 MB */
long long int g[1024*1024]; /* ~ 8 MB */
long long int h[1024*1024]; /* ~ 8 MB */
long long int i[1024*1024]; /* ~ 8 MB */
long long int j[1024*1024]; /* ~ 8 MB */
long long int k[1024*1024]; /* ~ 8 MB */
long long int l[1024*1024]; /* ~ 8 MB */
long long int m[1024*1024]; /* ~ 8 MB */
long long int n[1024*1024]; /* ~ 8 MB */
long long int o[1024*1024]; /* ~ 8 MB */
long long int p[1024*1024]; /* ~ 8 MB */
long long int q[1024*1024]; /* ~ 8 MB */
long long int r[1024*1024]; /* ~ 8 MB */
long long int s[1024*1024]; /* ~ 8 MB */
long long int t[1024*1024]; /* ~ 8 MB */
long long int u[1024*1024]; /* ~ 8 MB */
long long int v[1024*1024]; /* ~ 8 MB */
long long int w[1024*1024]; /* ~ 8 MB */
long long int x[1024*1024]; /* ~ 8 MB */
long long int y[1024*1024]; /* ~ 8 MB */
long long int z[1024*1024]; /* ~ 8 MB */

/* Total memory = 26*8 = 208 MB */
    
int main()
{
	void * m;
    
	while( 1 )
	{
		/* 1 MB per iteration of this loop */
		m = malloc(1024 * 1024 * sizeof( char ));
		memset(m,0,1024 * 1024 * sizeof( char ));
	}

	return 0;
}
