#include <bits/stdc++.h>
#include <stdio.h>
#include <cstring>
#include <stdlib.h>
#include <fstream>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <iostream>
//#include "Entry.h"

using namespace std;

#define INF -100000
string myIP;

class Entry
{
	string nexthop;
	int cost;
public:
	Entry(string n , int c);
	int getCost(){return cost;}
	string getNextHop(){return nexthop;}
	void setCost(int c){cost = c;}
	void setNextHop(string s){nexthop = s;}

};

Entry::Entry(string n , int c){
	nexthop = n;
	cost = c;
}

map<string, Entry*> routingtable;

void showRoutingTable(){
	cout<<"Routing Table for :"<<myIP<<"\n-------------------------\n";
	for (map<string, Entry*>::iterator i = routingtable.begin() ; i != routingtable.end() ; i++)
	{
		cout<<i->first<<" - "<<i->second->getNextHop()<<" - "<<i->second->getCost()<<endl;
	}
}

void sendRoutingUpdates(){
	return;
	struct sockaddr_in client_address;
	struct sockaddr_in server_address;
	int sockfd; 
	int bind_flag;

	client_address.sin_family = AF_INET;
	client_address.sin_port = htons(4747);
	client_address.sin_addr.s_addr = inet_addr(myIP.c_str());
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bind_flag = bind(sockfd, (struct sockaddr*) &client_address, sizeof(sockaddr_in));


	for (map<string, Entry*>::iterator j = routingtable.begin() ; j != routingtable.end() ; j++){

		string tmp = "Update-"+myIP+"\n";

		
		server_address.sin_family = AF_INET;
		server_address.sin_port = htons(4747);
		server_address.sin_addr.s_addr = inet_addr(j->first.c_str());
	
		for (map<string, Entry*>::iterator i = routingtable.begin() ; i != routingtable.end() ; i++)
		{
			if(i->second->getCost() != INF){
				tmp += i->first +"-"+i->second->getNextHop()+"-"+to_string(i->second->getCost())+"\n"; 
			}
			// cout<<i->first<<" - "<<i->second->getNextHop()<<" - "<<i->second->getCost()<<endl;
		}
		int n = tmp.length();  
		
		char buffer[n+1];  
		strcpy(buffer, tmp.c_str());
		sendto(sockfd, buffer, n, 0, (struct sockaddr*) &server_address, sizeof(sockaddr_in));
	}

}

int main(int argc, char *argv[]){

	int sockfd; 
	int bind_flag;
	int bind_flag2;

	int bytes_received;
	socklen_t addrlen;
	char buffer[1024];
	struct sockaddr_in server_address;
	struct sockaddr_in client_address;

	map<string, Entry*>::iterator it;

	if(argc != 3){//Takes ip address as command line arguments
		printf("%s <ip address> <topology>\n", argv[0]);
		exit(1);
	}

	myIP = argv[1];
	ifstream inFile;
	inFile.open(argv[2]);
	string str;


	while(getline(inFile, str ))
    {
        //Each line
		// cout<<str<<endl;
		istringstream iss(str);
		string s;
		vector<string> line;
		while ( getline( iss, s, ' ' ) ) {
			line.push_back(s);
			// if(line[0] == argv[1]){
			// 	cout<<"my ip->"<<line[0]<<endl;
			// }
			// printf( "%s\n", s.c_str() );
		}
		if(line[0] == argv[1]){
			it = routingtable.find(line[1]);
			if (it != routingtable.end()){
				routingtable.erase (it);
				routingtable.insert(pair<string, Entry*>(line[1].c_str(), new Entry(line[1].c_str(),stoi(line[2])))); 
			}
			else
				routingtable.insert(pair<string, Entry*>(line[1].c_str(), new Entry(line[1].c_str(),stoi(line[2])))); 
		}
		else if(line[1] == argv[1]){
			it = routingtable.find(line[0]);
			if (it != routingtable.end()){
				routingtable.erase (it);
				routingtable.insert(pair<string, Entry*>(line[0].c_str(), new Entry(line[0].c_str(),stoi(line[2])))); 
			}
			else
				routingtable.insert(pair<string, Entry*>(line[0].c_str(), new Entry(line[0].c_str(),stoi(line[2])))); 
		}
		else{
			routingtable.insert(pair<string, Entry*>(line[0].c_str(), new Entry(" undefined  ",INF))); 
			routingtable.insert(pair<string, Entry*>(line[1].c_str(), new Entry(" undefined  ",INF))); 
		}
		
    }
	showRoutingTable();

	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(4747);
	server_address.sin_addr.s_addr = inet_addr(argv[1]);

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bind_flag = bind(sockfd, (struct sockaddr*) &server_address, sizeof(sockaddr_in));

	
	printf("Router running...\n");
	while(true){
		bytes_received = recvfrom(sockfd, buffer, 1024, 0, (struct sockaddr*) &client_address, &addrlen);
		printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
		string str(buffer);

		if (str.find("clk") != string::npos)
			sendRoutingUpdates();
		else if(str.find("show") != string::npos)
			showRoutingTable();
		else if(str.find("cost") != string::npos){
			// cost 192.168.10.1 192.168.10.2 2
			string ip1="";
			string ip2="";
			string value="";
			for(int i= 4; i < 8 ; i++){
				int tmp = (int) buffer[i];
				if(tmp<0)
					tmp+= 256;
				ip1+=to_string(tmp);
				if(i != 7){
					ip1 += ".";
				}
			}
			for(int i= 8; i < 12 ; i++){
				int tmp = (int) buffer[i];
				if(tmp<0) //returns unsigned char from python
					tmp+= 256;
				ip2+=to_string(tmp);
				if(i != 11){
					ip2 += ".";
				}
			}
			
			int val = (int) buffer[12];
			// value+=to_string(tmp);
			
			if(myIP == ip1){
				cout<<"update cost <"<<ip1<<"> <"<<ip2<<"> "<<to_string(val)<<endl;
				it = routingtable.find(ip2);
				if (it != routingtable.end()){
					// routingtable.erase (it);
					// routingtable.insert(pair<string, Entry*>(ip2.c_str(), new Entry(ip2.c_str(),val))); 
					it->second->setCost(val);
					it->second->setNextHop(ip2.c_str());

				}
				
			}
			else{
				cout<<"update cost <"<<ip1<<"> <"<<ip2<<"> "<<to_string(value)<<endl;
				it = routingtable.find(ip1);
				if (it != routingtable.end()){
					// routingtable.erase (it);
					// routingtable.insert(pair<string, Entry*>(ip2.c_str(), new Entry(ip2.c_str(),val))); 
					it->second->setCost(val);
					it->second->setNextHop(ip1.c_str());

				}
			
			}
			cout<<"Link cost updated"<<endl;
			showRoutingTable();
		}
		// else if(str.find("show") != string::npos)
		// 	showRoutingTable();
		// else if(str.find("show") != string::npos)
		// 	showRoutingTable();
		
	}

/*
	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(4747);
	server_address.sin_addr.s_addr = inet_addr("192.168.10.100");

	client_address.sin_family = AF_INET;
	client_address.sin_port = htons(4747);
	client_address.sin_addr.s_addr = inet_addr(argv[1]);

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bind_flag = bind(sockfd, (struct sockaddr*) &server_address, sizeof(sockaddr_in));
	bind_flag2 = bind(sockfd, (struct sockaddr*) &client_address, sizeof(sockaddr_in));

	printf("Server running...\n");
	while(true){
		bytes_received = recvfrom(sockfd, buffer, 1024, 0, (struct sockaddr*) &client_address, &addrlen);
		printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
		cin>>buffer;
		if(!strcmp(buffer, "shutdown")) break;
		sendto(sockfd, buffer, 1024, 0, (struct sockaddr*) &server_address, sizeof(sockaddr_in));
	
	}
	close(sockfd);
*/

	return 0;

}
