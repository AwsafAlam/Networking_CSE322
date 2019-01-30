/********************************
Offline 5 : Error Correction and detection
Pg : 141, Tanenbaum; Ch: 3.2

/******************************/
#include <bits/stdc++.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

int datablock[10000][10000];

void ConvertToBinary(int n)
{
    if (n / 2 != 0) {
        ConvertToBinary(n / 2);
    }
    printf("%d", n % 2);
    
}

// function to convert decimal to binary 
void decToBinary(int n, int k,int l) 
{ 
    // array to store binary number 
    int binaryNum[1000]; 
  
    // counter for binary array 
    int i = 0; 
    while (n > 0) { 
  
        // storing remainder in binary array 
        binaryNum[i] = n % 2; 
        n = n / 2; 
        i++; 
    } 

    // printing binary array in reverse order 
    while(i < 8){
        /* code */
        ///cout<<"0";
        //datablock[k][l] = 0;
        //l++;
        i++;
    }
    
    for (int j = i - 1; j >= 0; j--){
        cout << binaryNum[j]; 
        datablock[k][l] = binaryNum[j];
        l++;
    } 


} 

bool ErrorDetection(string data, int m , float p , string polynomial_gen){


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

    string data,polynom;
    int m;
    float p;

    cout<<"enter data string: ";
    // cin>>data;
    getline(cin,data);
    cout<<"enter number of data bytes in a row <m>: ";
    cin>>m;
    cout<<"enter probability <p>: ";
    cin>>p;
    cout<<"enter generator polynomial: ";
    cin>>polynom;
    
    while(data.length() %m != 0 ){
        data += "~";
    }
    cout<<"\ndata string after padding: "<<data<<endl;
    int row_siz = 8*m;
    int col_siz = data.length()/m;
    int total_bits = data.length()*8;
    
    cout<<"\ndata block <ascii code of m characters per row>:\n";

    int k = 0;
    for(int i = 0; i < data.length(); i++)
    {
        for(int j = 0; j < m; j++)
        {
            decToBinary(data[i],k,j*8);
            if(j != m-1)
                i++;
            if(i == data.length())
                break;
        }
        k++;
        cout<<endl;
    }
    cout<<"\ndata block after adding check bits:\n";
    
    for(int j = 0; j < k; j++){
        for(int i = 0; i < m*8 ; i++){
        
            cout<<datablock[j][i];
        }
        cout<<endl;
    }

    for(int i = 0; i < 4; i++)
    {
        if(i%2 ==0)
            cout << "\033[1;"<<FG_GREEN<<"m"<<i<<"\033[0m";
        else
            cout <<i;
    }
    cout<<endl;
    
    return 0;
}
