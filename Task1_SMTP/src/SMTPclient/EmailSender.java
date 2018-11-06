package SMTPclient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;

public class EmailSender {

    private static String mailServer = "webmail.buet.ac.bd";
    private static int PORT = 25;

    private String mailSubject;
    private String mailFrom;
    private String mailTo;
    private String mailBody;

    private InetAddress mailHost;
    private InetAddress localHost;

    private BufferedReader in;
    private PrintWriter pr;

    public void initMail() throws IOException {
        mailHost = InetAddress.getByName(mailServer);
        localHost = InetAddress.getLocalHost();
        Socket smtpSocket = new Socket(mailHost,PORT);
        in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        pr = new PrintWriter(smtpSocket.getOutputStream(),true);

        String initialID = in.readLine();
        System.out.println("Server: " +initialID);

    }

    void setMailContent(String subject ,String from,String to, String body){
        mailSubject = subject;
        mailFrom = from;
        mailTo = to;
        mailBody = body;
    }



    void setMailServer(String mailServer) {
        EmailSender.mailServer = mailServer;
    }

    void  setPORT(int PORT){
        EmailSender.PORT = PORT;
    }

    void setMailHeaders() throws IOException {

        pr.println("HELO "+localHost.getHostName());
        pr.flush();
        System.out.println("HELO "+localHost.getHostName());
        String welcome = in.readLine();
        System.out.println("Server: " +welcome);

    }

    void sendMail() throws IOException {

        //setting the sender
        pr.println("MAIL FROM:"+mailFrom);
        System.out.println("Server: " + in.readLine());

        //setting the receiver
        pr.println("RCPT TO:"+mailTo);
        System.out.println("Server: " + in.readLine());

//        pr.println("RCPT TO:<1505113.anf@ugrad.cse.buet.ac.bd>");
//        System.out.println("Server: " + in.readLine());

        //data
        pr.println("DATA");
        System.out.println("Server: " + in.readLine());

        //email body
        pr.println("Subject: "+mailSubject);
        pr.println("From: "+mailFrom);
        pr.println("To: "+mailTo);
        pr.println();
        pr.println(mailBody);
        pr.println(".");
        System.out.println("Server: " + in.readLine());

        //closing
        pr.println("QUIT");
        System.out.println("Server: "+in.readLine());

    }

}
