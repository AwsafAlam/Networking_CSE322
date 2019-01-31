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

}

vi Division(){
    int divisor_len = key.size();
    vi temp(serialized.begin(), serialized.begin()+divisor_len);

    while(divisor_len < serialized.size()){
        if(temp[0] == 1){//First element 1
            temp = XOR(key , temp);
            temp.push_back(serialized[divisor_len]);
        }
        else{
            vi zero(divisor_len,0);
            temp = XOR( zero, temp);
            temp.push_back(serialized[divisor_len]);
        }
        divisor_len++;
    }
    if(temp[0] == 1){
        temp = XOR(key,temp);
    }
    else
    {
        vi zero(divisor_len,0);
        temp = XOR(zero,temp);
    }
    
    return temp; 
}


int main(int argc, char const *argv[])
{

    string data,polynom;
    int m;
    float p;

    cout<<"enter data string: ";
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
    for(int i = 0; i < polynom.length(); i++)
    {
        if(polynom[i] == '1')
            key.push_back(1);
        else
            key.push_back(0);
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
            binary_Convert(data[i],k,j*8);
            if(j != m-1)
                i++;
            if(i == data.length())
                break;
        }
        k++;
        cout<<endl;
    }
    cout<<"\ndata block after adding check bits:\n";
    
    for(int j = 0; j < col_siz; j++){
        int i =0, k=1;
        while(i< m*8){
            if(!(k == 0) && !(k & (k - 1))){
                data_frame[j].insert(data_frame[j].begin()+i ,-1);
                k++;i++;
                continue;
            }
            //cout<<data_frame[j][i];
            i++;k++;
        }
        //cout<<endl;
    }

    for(int i =0 ; i< col_siz ; i++){
        for(int j = 0; j < data_frame[i].size(); j++)
        {
            if(data_frame[i][j] == -1){
                data_frame[i][j] =  getParity(i,j+1);
                cout << "\033[1;"<<FG_GREEN<<"m"<<data_frame[i][j]<<"\033[0m";
            }
            else
            {
                cout<<data_frame[i][j];
            }
            
        }
        cout<<endl;
    }
    row_siz = data_frame[0].size();
    cout<<"\ndata bits after column-wise serialization:\n";
    for(int i = 0; i < row_siz; i++)
    {
        for (int j = 0; j < col_siz; j++)
        {
            cout<<data_frame[j][i];
            serialized.push_back(data_frame[j][i]);
        }
    }
    for(int i =0 ; i< polynom.length()-1 ; i++)
        serialized.push_back(0);

    cout<<"\n\ndata bits after appending CRC checksum <sent frame>:\n";
    vi remainder = Division();
    for(int i = 0; i < serialized.size(); i++)
    {
        cout<<serialized[i];
    }
    for(int i = 0; i < remainder.size(); i++)
    {
        cout << "\033[1;"<<FG_GREEN<<"m"<<remainder[i]<<"\033[0m";
        serialized.push_back(remainder[i]);
    }
    
    
    
    return 0;
}
