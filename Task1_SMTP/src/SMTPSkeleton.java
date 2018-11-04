
package smtpskeleton;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Scanner;

public class SMTPSkeleton {

    public static void main(String[] args) throws UnknownHostException, IOException {
        String temp;
        String mailServer = "smtp.sendgrid.net";
        InetAddress mailHost = InetAddress.getByName(mailServer);
        InetAddress localHost = InetAddress.getLocalHost();
        Socket smtpSocket = new Socket(mailHost,587);
        BufferedReader in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        PrintWriter pr = new PrintWriter(smtpSocket.getOutputStream(),true);
        String initialID = in.readLine();
        System.out.println("Server: "+initialID);


        //authentication for sendgrid smtp server
        pr.println("auth login");
        System.out.println("Server: "+in.readLine());

        //giving id =apikey
        pr.println("YXBpa2V5");
        temp=in.readLine();
        System.out.println("Server: "+temp);
        //quitting if error in connecting the server
        if(temp.equalsIgnoreCase("501 Syntax error in parameters"))
        {
            System.out.println("Incorrect key");
            //closing
            pr.println("QUIT");
            System.out.println("Server: "+in.readLine());
            return ;
        }

        //giving password
        pr.println("U0cuWXFCSmZXNTZRc1dPQ19YbWxmTzdjUS5JNFBNTkdvbV9ISllTSWUxU0xnMlFhY1hKZ1VzV3FQVFpoaGZPTTFEYTk0");
        temp=in.readLine();
        System.out.println("Server: "+temp);
        //quitting if error in connecting the server
        if(temp.equalsIgnoreCase("501 Syntax error in parameters"))
        {
            System.out.println("Incorrect Password");
            //closing
            pr.println("QUIT");
            System.out.println("Server: "+in.readLine());
            return ;
        }



        //hello from client
        pr.println("HELO " + localHost.getHostName());
        String welcome = in.readLine();
        System.out.println("Server: " + welcome);

        //setting the sender
        pr.println("MAIL FROM:<anfuad23@gmail.com>");
        System.out.println("Server: " + in.readLine());

        //setting the receiver
        pr.println("RCPT TO:<anfuad23@gmail.com>");
        System.out.println("Server: " + in.readLine());
        pr.println("RCPT TO:<1505113.anf@ugrad.cse.buet.ac.bd>");
        System.out.println("Server: " + in.readLine());

        //data
        pr.println("DATA");
        System.out.println("Server: " + in.readLine());


        //email body
        pr.println("Subject: sample message");
        pr.println("From: anfuad23@gmail.com");
        pr.println("To: anfuad23@gmail.com");
        pr.println();
        pr.println("Greetings,");
        pr.println("Hello This is fuad.");
        pr.println("Goodbye");
        pr.println(".");
        System.out.println("Server: " + in.readLine());

        //closing
        pr.println("QUIT");
        System.out.println("Server: "+in.readLine());



/*
        Scanner sc= new Scanner(System.in);
        String cmd;
        while(true)
        {
            System.out.print("Client: ");
            cmd=sc.nextLine();

            if(cmd.equalsIgnoreCase("QUIT")) {
                pr.println(cmd);
                System.out.println("Server: "+in.readLine());
                return;
            }

            else if(cmd.equalsIgnoreCase("DATA"))
            {
                pr.println(cmd);
                System.out.println("Server: "+in.readLine());
                String msg;
                Scanner sc2=new Scanner(System.in);
                Nestedloop:
                while(true)
                {
                    System.out.print("Client: ");
                    msg=sc2.nextLine();
                    if(msg.equalsIgnoreCase("."))
                    {
                        pr.println(msg);
                        System.out.println("Server: "+in.readLine());
                        break Nestedloop;
                    }
                    else
                        pr.println(msg);

                }
            }

            else
            {
                pr.println(cmd);
                System.out.println("Server: "+in.readLine());
            }


        }

        */

            }
        }



