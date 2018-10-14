import java.util.Scanner;

public class Main
{
	public static void main(String[] args)
	{
		Scanner input = new Scanner(System.in);

		int num = input.nextInt();

		System.out.println(num*2);
        
        // An endless loop
        for( int i=0; i<100; i++ )
        {
            i=i-1;
        }
	}
}
