package SMTPclient;

import java.io.IOException;
import java.util.Scanner;

public class SMTPclient {


//    static final String mailServer = "webmail.buet.ac.bd";
//    static final int PORT = 25;


    public static void main(String[] args) throws IOException {

        System.out.println("Starting client ... ");

        EmailSender sender = new EmailSender();

        sender.setMailServer("webmail.buet.ac.bd");
        sender.setPORT(25);

//        Scanner sc = new Scanner(System.in);
//
//        System.out.print("Enter your Email details :\nSubject: ");
//
//        String subject = sc.next();
//        System.out.print("From: ");
//        String from = sc.next();
//
//        System.out.print("To: ");
//        String to = sc.next();
//
//        System.out.print("Mail Body: ");
//        String body = sc.next();

        String subject = "Hello";
        String from = "1505114.maaa@ugrad.cse.buet.ac.bd";
        String to = "awsafalam@gmail.com";
        String body = "Mail Body";

        sender.setMailContent(subject , from,to ,body);
        sender.initMail();

        sender.setMailHeaders();
        sender.sendMail();



    }
}
