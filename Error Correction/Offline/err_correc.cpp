#include <iostream>
#include <stdio.h>
// #include <windows.h>

using namespace std;


bool ErrorDetection(string data, int m , float p , int gen){

    return false;
}

string ErrorCorrection(){

}

enum Color {
        FG_RED      = 31,
        FG_GREEN    = 32,
        FG_BLUE     = 34,
        FG_DEFAULT  = 39,
        BG_RED      = 41,
        BG_GREEN    = 42,
        BG_BLUE     = 44,
        BG_DEFAULT  = 49
};

int main(int argc, char const *argv[])
{
    /* code */

    for(int i = 0; i < 10; i++)
    {
        /* code */
        if(i%2 ==0)
            cout << "\033[1;"<<FG_BLUE<<"m"<<i<<"\033[m";
        else
            cout <<i;
    }
    cout<<endl;
    return 0;
}
