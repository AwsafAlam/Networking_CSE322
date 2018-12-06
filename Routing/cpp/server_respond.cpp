#include <bits/stdc++.h>
#include <stdio.h>
#include <cstring>
#include <stdlib.h>

#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <iostream>

using namespace std;

int main(int argc, char *argv[]){

	int sockfd; 
	int bind_flag;
	int bind_flag2;

	int bytes_received;
	socklen_t addrlen;
	char buffer[1024];
	struct sockaddr_in server_address;
	struct sockaddr_in client_address;

	if(argc != 2){//Takes ip address as command line arguments
		printf("%s <ip address>\n", argv[0]);
		exit(1);
	}

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

	return 0;

}
