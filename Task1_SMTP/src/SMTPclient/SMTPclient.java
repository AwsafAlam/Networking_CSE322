package SMTPclient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;

public class SMTPclient {

    public static void main(String[] args) throws IOException {
        System.out.println("Starting client ... ");

//        String mailServer = "webmail.buet.ac.bd";
//        InetAddress mailHost = InetAddress.getByName(mailServer);
//        InetAddress localHost = InetAddress.getLocalHost();
//        Socket smtpSocket = new Socket(mailHost,25);
//        BufferedReader in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
//        PrintWriter pr = new PrintWriter(smtpSocket.getOutputStream(),true);
//        String initialID = in.readLine();
//        System.out.println(initialID);
//        pr.println("HELO "+localHost.getHostName());
//        pr.flush();
//        String welcome = in.readLine();
//        System.out.println(welcome);

        String temp;
        String mailServer = "mail.kolpobd.com";
        InetAddress mailHost = InetAddress.getByName(mailServer);
        InetAddress localHost = InetAddress.getLocalHost();
        Socket smtpSocket = new Socket(mailHost,25);
        BufferedReader in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        PrintWriter pr = new PrintWriter(smtpSocket.getOutputStream(),true);
        String initialID = in.readLine();
        System.out.println("Server: "+initialID);


        //authentication for sendgrid smtp server
        pr.println("auth login");
        System.out.println("Server: "+in.readLine());

        //giving id =apikey
        pr.println("info@kolpobd.com");
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
        pr.println("");
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
    }
}
