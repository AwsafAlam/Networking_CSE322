/********************************
Offline 5 : Error Correction and detection
Pg : 141, Tanenbaum; Ch: 3.2

/******************************/
#include <bits/stdc++.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define vi vector<int>

using namespace std;

vi data_frame[1000];
vi serialized;
vi key;

enum Color {
    FG_BLACK    = 30,
    FG_RED      = 31,
    FG_GREEN    = 32,
    FG_BROWN    = 33,
    FG_BLUE     = 34,
    FG_MAGENTA  = 35,
    FG_CYAN     = 36,
    FG_LIGHTGREY= 37,
    FG_DEFAULT  = 39,
    BG_RED      = 41,
    BG_GREEN    = 42,
    BG_BLUE     = 44,
    BG_DEFAULT  = 49
};

void binary_Convert(int n, int k,int l) 
{ 
    // array to store binary number 
    int binaryNum[1000]; 
    memset(binaryNum,0,sizeof(binaryNum));
    // counter for binary array 
    int i = 0; 
    while (n > 0) { 
        // storing remainder in binary array 
        binaryNum[i] = n % 2; 
        n = n / 2; 
        i++; 
    } 

    while(i < 8)
        i++;
    
    // printing binary array in reverse order 
    for (int j = i - 1; j >= 0; j--){
        cout << binaryNum[j]; 
        data_frame[k].push_back(binaryNum[j]);
        l++;
    } 

} 

bool getParity(int row , int idx) 
{ 
    bool parity = 0;
    int count = 0; 
    for(int i = 0; i < data_frame[row].size(); i++)
    {
        if( (i+1) & idx && data_frame[row][i]== 1){
            count++;
        }
    }
    if(count %2 == 0)
        return false;
    else
        return true;
    
} 

vi XOR(vi a, vi b){
    vi tmp;
    int i =0;
    cout<<"\n---------\nb: ";
    for(int i = 0; i < b.size(); i++)
        cout<<b[i];
    cout<<"\n***********\na: ";
    for(int i = 0; i < a.size(); i++)
        cout<<a[i];
    cout<<"\n---------\n";
    
    
    for(int i = 0; i < b.size(); i++)
    {
        if(a[i] == b[i])
            tmp.push_back(0);
        else
            tmp.push_back(1);
        // tmp.push_back(a[i]^b[i]);
    }
    return tmp;
}

vi Division(){
    int divisor_len = key.size();
    int zer_len = divisor_len;
    vi temp(serialized.begin(), serialized.begin()+divisor_len);
    for(int i = 0; i < temp.size(); i++)
        cout<<temp[i];
    cout<<"\n---------\n";
    
    while(divisor_len < serialized.size()){
        if(temp[0] == 1){//First element 1
            vi tmp = XOR(key , temp);
            temp.clear();
            temp = tmp;
            temp.push_back(serialized[divisor_len]);
        }
        else{
            vi zero(zer_len,0);
            vi tmp = XOR( zero, temp);
            temp.clear();
            temp = tmp;
            temp.push_back(serialized[divisor_len]);
        }
        divisor_len++;
        if(temp[0] == 0){
            temp.erase(temp.begin(), temp.begin()+1);
        }
        for(int i = 0; i < temp.size(); i++)
            cout<<temp[i];
        cout<<"\n=========\n";
        
    }
    if(temp[0] == 1){
        vi tmp = XOR(key,temp);
        temp.clear();
        temp = tmp;
    }
    else
    {
        vi zero(zer_len,0);
        vi tmp = XOR(zero,temp);
        temp.clear();
        temp = tmp;
    }

    return temp; 
}


int main(int argc, char const *argv[])
{

    string data = "0101100010110000000000011111110111010000001100011110000101010001100111100000001110111111111110000000000110100110110010101100110000",polynom = "10101";
    // string data = "11010110110000";
    // string polynom = "10011";
    
    int m;
    float p;

    for(int i = 0; i < polynom.length(); i++)
    {
        if(polynom[i] == '1')
            key.push_back(1);
        else
            key.push_back(0);
    }
    for(int i = 0; i < data.length(); i++)
    {
        if(data[i] == '1')
            serialized.push_back(1);
        else
            serialized.push_back(0);
    }
    
    
    cout<<"\n\ndata bits after appending CRC checksum <sent frame>:\n";
    vi remainder = Division();
    for(int i = 0; i < remainder.size(); i++)
    {
        cout << "\033[1;"<<FG_CYAN<<"m"<<remainder[i]<<"\033[0m";
        serialized.push_back(remainder[i]);
    }
    cout<<"\n-----------\n";
    for(int i = 0; i < serialized.size(); i++)
    {
        cout<<serialized[i];
    }

    for(int i = 0; i < remainder.size(); i++)
    {
        cout << "\033[1;"<<FG_CYAN<<"m"<<remainder[i]<<"\033[0m";
        serialized.push_back(remainder[i]);
    }
    
    cout<<endl;
    
    return 0;
}
