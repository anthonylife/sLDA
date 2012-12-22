#include <itpp/itbase.h>
#include <stdio.h>

using namespace itpp;

//These lines are needed for use of cout and endl
using std::cout;
using std::endl;

int main()
{
  //Declare vectors and matricies:
  vec a, b, c, d;
  mat A, B;

  //Use the function linspace to define a vector:
  a = linspace(1.0, 2.0, 10);

  //Use a string of values to define a vector:
  std::string e = "0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0";
  b = e;
  //Add two vectors:
  c = a + b;

  d = e;
  cout << b * d << endl;
  //Print results:
  cout << "a = " << a << endl;
  cout << "b = " << b << endl;
  cout << "c = " << c << endl;

  //Use a string to define a matrix:
  A = "1.0 2.0;3.0 4.0";

  //Calculate the inverse of matrix A:
  B = inv(A);

  //Print results:
  cout << "A = " << A << endl;
  cout << "B = " << B << endl;
  cout << B(0) << endl;

  int length = 0;
  char * charBuf  = new char[1000];
  std::string s;
  std::string s1;
  for (int i = 1; i < 10; i++){
      for (int j =1; j < 5; j++){
        sprintf(charBuf, "%d ", j);
        s1 = charBuf;
        s += s1;
        memset(charBuf, 0, 1000);
      }
  }      
  cout << s << endl;
  //Exit program:
  return 0;

}
