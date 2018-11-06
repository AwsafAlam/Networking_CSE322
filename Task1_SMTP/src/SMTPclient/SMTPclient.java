package SMTPclient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;

public class SMTPclient {

    public static void main(String[] args) throws IOException {
        System.out.println("Starting client ... ");

        String mailServer = "webmail.buet.ac.bd";
        InetAddress mailHost = InetAddress.getByName(mailServer);
        InetAddress localHost = InetAddress.getLocalHost();
        Socket smtpSocket = new Socket(mailHost,25);
        BufferedReader in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        PrintWriter pr = new PrintWriter(smtpSocket.getOutputStream(),true);
        String initialID = in.readLine();
        System.out.println("Server: " +initialID);

        pr.println("HELO "+localHost.getHostName());
        pr.flush();
        System.out.println("EHLO "+localHost.getHostName());
        String welcome = in.readLine();
        System.out.println("Server: " +welcome);

        pr.println("MAIL FROM:<1505114.maaa@ugrad.cse.buet.ac.bd>");
        System.out.println("MAIL FROM:<1505114.maaa@ugrad.cse.buet.ac.bd>");
        System.out.println("Server: " + in.readLine());

        //setting the receiver
        pr.println("RCPT TO:<awsafalam@gmail.com>");
        System.out.println("RCPT TO:<awsafalam@gmail.com>");
        System.out.println("Server: " + in.readLine());

        pr.println("RCPT TO:<1505113.anf@ugrad.cse.buet.ac.bd>");
        System.out.println("RCPT TO:<1505113.anf@ugrad.cse.buet.ac.bd>");
        System.out.println("Server: " + in.readLine());

        //data
        pr.println("DATA");
        System.out.println("Server: " + in.readLine());

        //email body
        pr.println("Subject: sample message");
        pr.println("From: 1505114.maaa@ugrad.cse.buet.ac.bd");
        pr.println("To: awsafalam@gmail.com");
        pr.println("");
        pr.println("Greetings,");
        pr.println("Hello This is Awsaf.");
        pr.println("Goodbye");
        pr.println(".");
        System.out.println("data sent");
        System.out.println("Server: " + in.readLine());

        //closing
        pr.println("QUIT");
        System.out.println("Server: "+in.readLine());

    }
}
