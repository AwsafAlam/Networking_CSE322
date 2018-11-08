
package smtpskeleton;

import com.sun.org.apache.xerces.internal.impl.dv.util.Base64;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.awt.image.WritableRaster;
import java.io.*;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.Buffer;
import java.nio.file.Files;
import java.util.Scanner;

public class SMTPSkeleton {


    public static byte[] extractBytes (String ImageName) throws IOException {
        // open image
        File imgPath = new File(ImageName);
        BufferedImage bufferedImage = ImageIO.read(imgPath);

        // get DataBufferBytes from Raster
        WritableRaster raster = bufferedImage .getRaster();
        DataBufferByte data   = (DataBufferByte) raster.getDataBuffer();

        return ( data.getData() );
    }



    public static void main(String[] args) throws UnknownHostException, IOException {
        String temp;
        //String mailServer = "smtp.sendgrid.net";
        String mailServer="webmail.buet.ac.bd";
        InetAddress mailHost = InetAddress.getByName(mailServer);
        InetAddress localHost = InetAddress.getLocalHost();
        Socket smtpSocket = new Socket();
        smtpSocket.connect(new InetSocketAddress(mailHost,25),2000);
        BufferedReader in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        PrintWriter pr = new PrintWriter(smtpSocket.getOutputStream(),true);
        String initialID = in.readLine();
        System.out.println("Server: "+initialID);


/*
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
        pr.println("U0cuYVhERnVJTlNSMi1qdTA5T2JCamlQdy4yMnpJeXQzMkxsWjZzNlBTYnRPUE55dGNiYzV5MEpjbVg3Tmdjbjlpd0ow");
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
*/



        try {
            BufferedReader br=new BufferedReader(new FileReader("input.txt"));
            BufferedReader br2=new BufferedReader(new FileReader("mail.txt"));
            String cmd = br.readLine();
            while (cmd != null) {
                System.out.println("Client: "+cmd);

                if(cmd.equalsIgnoreCase("HELO "+localHost.getHostName()))
                {
                    pr.println(cmd);
                    System.out.println("Server: "+in.readLine());

                }


                else if(cmd.equalsIgnoreCase("QUIT")) {
                    pr.println(cmd);
                    System.out.println("Server: "+in.readLine());
                    return;
                }

                else if(cmd.equalsIgnoreCase("DATA"))
                {
                    pr.println(cmd);
                    System.out.println("Server: "+in.readLine());
                    String msg=br2.readLine();

                    while(msg!=null)
                    {
                        System.out.println("Client: "+msg);
                        if(msg.equalsIgnoreCase("."))
                        {
                            pr.println(msg);
                            System.out.println("Server: "+in.readLine());
                            br2.close();
                            break ;
                        }
                        else if(msg.equalsIgnoreCase("send attachment"))
                        {


                            File fi = new File("buet.png");
                            byte[] fileContent = Files.readAllBytes(fi.toPath());
                            String encoded= Base64.encode(fileContent);
                            pr.println(encoded);

                        }
                        else
                        {
                            pr.println(msg);
                        }

                        //read next line
                        msg=br2.readLine();

                    }
                }

                else
                {
                    pr.println(cmd);
                    System.out.println("Server: "+in.readLine());
                }


                // read next line
                cmd = br.readLine();
            }

            br.close();
        }

        catch (IOException e) {
            System.out.println(e.toString());
        }

    }
}


