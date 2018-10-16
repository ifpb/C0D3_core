
#include <iostream>
#include <vector>

using namespace std;


int main()
{
	int valor;
	cin >> valor; 
	cout << 2 * valor << endl;

    vector<int> x;
    x.push_back(10);
    x.push_back(20);
	
    for( int i=1000; i<1500; i++ )
        x[120000] = 10;
        
    cout << x[12] << endl;
    
	return 0;
}

