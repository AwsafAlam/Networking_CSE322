#include <bits/stdc++.h>
#include <stdio.h>
#include <cstring>
#include <stdlib.h>
#include <fstream>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <iostream>

using namespace std;

#define INF 999999
string myIP;
int routingupdate = 0;

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
vector<string> neighbours;

void showRoutingTable(){
	cout<<"Routing Table for :"<<myIP<<"\n-------------------------\n";
	for (map<string, Entry*>::iterator i = routingtable.begin() ; i != routingtable.end() ; i++)
	{
		cout<<i->first<<" - "<<i->second->getNextHop()<<" - "<<i->second->getCost()<<endl;
	}
}

void initRoutingTable(string file){
	string str;
	map<string, Entry*>::iterator it;
	ifstream inFile;
	inFile.open(file.c_str());
	
	while(getline(inFile, str ))
    {
        istringstream iss(str);
		string s;
		vector<string> line;
		while ( getline( iss, s, ' ' ) ) {
			line.push_back(s);
			
		}
		if(line[0] == myIP){
			it = routingtable.find(line[1]);
			if (it != routingtable.end()){
				routingtable.erase (it);
				routingtable.insert(pair<string, Entry*>(line[1].c_str(), new Entry(line[1].c_str(),stoi(line[2])))); 
			}
			else
				routingtable.insert(pair<string, Entry*>(line[1].c_str(), new Entry(line[1].c_str(),stoi(line[2])))); 
		}
		else if(line[1] == myIP){
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
	for (map<string, Entry*>::iterator i = routingtable.begin() ; i != routingtable.end() ; i++){
		if(i->second->getCost() != INF)
			neighbours.push_back(i->first.c_str());
	}
}

// void sendRoutingUpdates(string str){
// 	routingupdate++;
	
// 	struct sockaddr_in client_address;
// 	struct sockaddr_in server_address;
// 	int sockfd; 
// 	int bind_flag;

// 	client_address.sin_family = AF_INET;
// 	client_address.sin_port = htons(4747);
// 	client_address.sin_addr.s_addr = inet_addr(myIP.c_str());
// 	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
// 	bind_flag = bind(sockfd, (struct sockaddr*) &client_address, sizeof(sockaddr_in));
// 	map<string,int> sent;
	
// 	for (map<string, Entry*>::iterator j = routingtable.begin() ; j != routingtable.end() ; j++){

// 		string tmp = "Update-"+myIP+"-"+to_string(routingupdate)+"\n";

// 		server_address.sin_family = AF_INET;
// 		server_address.sin_port = htons(4747);
// 		if(sent.find(j->second->getNextHop()) == sent.end()){
// 			server_address.sin_addr.s_addr = inet_addr(j->second->getNextHop().c_str());
// 			sent.insert(pair<string, int>(j->second->getNextHop() ,j->second->getCost() ));
// 		}
// 		else
// 			continue;
		
// 		for (map<string, Entry*>::iterator i = routingtable.begin() ; i != routingtable.end() ; i++)
// 		{
// 			if(i->second->getCost() != INF){
// 				tmp += i->first +"-"+i->second->getNextHop()+"-"+to_string(i->second->getCost())+"\n"; 
// 			}
// 			// cout<<i->first<<" - "<<i->second->getNextHop()<<" - "<<i->second->getCost()<<endl;
// 		}
// 		int n = tmp.length();  
		
// 		char buffer[n+1];  
// 		strcpy(buffer, tmp.c_str());
// 		sendto(sockfd, buffer, n, 0, (struct sockaddr*) &server_address, sizeof(sockaddr_in));
// 	}
// 	close(sockfd);
// }

void sendRoutingUpdates(string str){
	routingupdate++;
	
	struct sockaddr_in client_address;
	struct sockaddr_in server_address;
	int sockfd; 
	int bind_flag;

	client_address.sin_family = AF_INET;
	client_address.sin_port = htons(4747);
	client_address.sin_addr.s_addr = inet_addr(myIP.c_str());
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bind_flag = bind(sockfd, (struct sockaddr*) &client_address, sizeof(sockaddr_in));
	// map<string,int> sent;
	
	// for (map<string, Entry*>::iterator j = routingtable.begin() ; j != routingtable.end() ; j++){
	for(int j =0 ; j< neighbours.size() ; j++){
		string tmp = "Update-"+myIP+"-"+to_string(routingupdate)+"\n";

		server_address.sin_family = AF_INET;
		server_address.sin_port = htons(4747);
		map<string, Entry*>::iterator nei = routingtable.find(neighbours[j]);
		if(nei != routingtable.end()){
			server_address.sin_addr.s_addr = inet_addr(neighbours[j].c_str());
			// server_address.sin_addr.s_addr = inet_addr(nei->second->getNextHop().c_str());
			// sent.insert(pair<string, int>(j->second->getNextHop() ,j->second->getCost() ));
		}
		else
			continue;
		
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
	close(sockfd);
}

void updateRoutingTable(string str){
	string from , eachline;
	istringstream l(str);

	while(getline(l, eachline ))
	{
		//Each line
		istringstream iss(eachline);
		string s;
		vector<string> line;
		while ( getline( iss, s, '-' ) ) {
			line.push_back(s);
		}
		if(line.size() > 0){
			if(line[0] == "Update"){
				from = line[1];
				// cout<<"routingupdate: "<<line[2]<<endl; //seg fault
			}
			else{
				map<string, Entry*>::iterator ite = routingtable.find(line[0]);
				map<string, Entry*>::iterator ite2 = routingtable.find(from);

				if (ite != routingtable.end() && ite2 != routingtable.end()){
					int newCost = routingtable.find(from)->second->getCost() + stoi(line[2]);
					if(newCost < ite->second->getCost()){
						cout<<"Shorter path found.. cls:"+line[2]+" "<<newCost<<" < "<<ite->second->getCost()<<" updating routing table"<<endl;
						ite->second->setCost(newCost);
						ite->second->setNextHop(ite2->second->getNextHop()); //Next hop of router to go to next
						showRoutingTable();
					}
				}
			}
		}
		
	}
}

void forwardmsg(string dst, string nexthop , string len, string msg){
	
	struct sockaddr_in client_address;
	struct sockaddr_in server_address;
	int sockfd; 
	int bind_flag;

	client_address.sin_family = AF_INET;
	client_address.sin_port = htons(4747);
	client_address.sin_addr.s_addr = inet_addr(myIP.c_str());
	
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bind_flag = bind(sockfd, (struct sockaddr*) &client_address, sizeof(sockaddr_in));
	
	string tmp = "frwd-"+dst+"-"+len+"-"+msg;

	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(4747);
	server_address.sin_addr.s_addr = inet_addr(nexthop.c_str());
	int n = tmp.length();  
	
	char buffer[n+1];  
	strcpy(buffer, tmp.c_str());
	sendto(sockfd, buffer, n, 0, (struct sockaddr*) &server_address, sizeof(sockaddr_in));
	close(sockfd);
	cout<<msg<<" packet forwarded to "<<nexthop<<endl;

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

	server_address.sin_family = AF_INET;
	server_address.sin_port = htons(4747);
	server_address.sin_addr.s_addr = inet_addr(argv[1]);

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	bind_flag = bind(sockfd, (struct sockaddr*) &server_address, sizeof(sockaddr_in));

	myIP = argv[1];
	string file = argv[2]; 
	
	initRoutingTable(file);

	printf("Router running...\n");
	while(true){
		bytes_received = recvfrom(sockfd, buffer, 1024, 0, (struct sockaddr*) &client_address, &addrlen);
		// printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
		string str(buffer);

		if (str.find("clk") != string::npos)
			sendRoutingUpdates(str);
		else if(str.find("show") != string::npos) //show 192.168.10.2
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
				cout<<"update cost <"<<ip1<<"> <"<<ip2<<"> "<<to_string(val)<<endl;
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
		else if(str.find("Update") != string::npos){
			updateRoutingTable(str);
		}
		else if(str.find("send") != string::npos){ //send 192.168.10.1 192.168.10.4 5 hello
			// printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
			string ip1="";
			string ip2="";
			string msg="";
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
			
			int len = (int) buffer[12];
			for(int i = 14 ; i< bytes_received ; i++){
				msg += buffer[i];
			}

			cout<<"Sending from <"<<ip1<<"> to <"<<ip2<<"> len:"<<len<<" msg:"<<msg<<endl;
			it = routingtable.find(ip2);
			if(it != routingtable.end() && ip1 == myIP){
				if(it->second->getCost() != INF)
					forwardmsg(ip2 , it->second->getNextHop() , to_string(len) , msg);
				else
					cout<<msg<<" packet cannot be sent\n";

			}
			else
				cout<<"IP not found in routing table\n";		

		}
		else if(str.find("frwd") != string::npos){
			printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
			istringstream iss(str);
			string s;
			vector<string> line;
			while ( getline( iss, s, '-') ) {
				line.push_back(s);
			}
			string msg = "";
			for(int i = 0 ; i< stoi(line[2]) ; i++){
				msg += line[3].front();
				line[3].erase(line[3].begin() , line[3].begin()+1);
			}
			// line[3].substr(stoi(line[2]));

			cout<<"Got forwarding msg: ->"<<msg<<" len->"<<line[2]<<" to:"<<line[1]<<endl;
			if(line[1] == myIP){
				cout<<msg<<" packet reached destination\n";
			}
			else{
			
				it = routingtable.find(line[1]);
				if(it != routingtable.end()){
					if(it->second->getCost() != INF)
						forwardmsg(line[1] ,it->second->getNextHop() ,line[2] , msg);
					else
						cout<<msg<<" packet cannot be sent\n";
				}
				else
					cout<<"IP not found in routing table\n";		
			
			}
		}
		else{
			printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
		}
		// 	showRoutingTable();
		// else if(str.find("show") != string::npos)
		// 	showRoutingTable();
		
	}


	return 0;

}
