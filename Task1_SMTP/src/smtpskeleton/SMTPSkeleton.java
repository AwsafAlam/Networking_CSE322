
package smtpskeleton;

import com.sun.org.apache.xerces.internal.impl.dv.util.Base64;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.WritableRaster;
import java.io.*;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.Buffer;
import java.nio.file.Files;
import java.util.Scanner;

public class SMTPSkeleton {

    public static void main(String[] args) throws UnknownHostException, IOException {
        String temp;

        String mailServer="webmail.buet.ac.bd";
        InetAddress mailHost = InetAddress.getByName(mailServer);
        InetAddress localHost = InetAddress.getLocalHost();
        Socket smtpSocket = new Socket(mailHost,25);
        BufferedReader in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        OutputStream os = smtpSocket.getOutputStream();

        PrintWriter pr = new PrintWriter(smtpSocket.getOutputStream(),true);
        String initialID = in.readLine();
        System.out.println("Server: "+initialID);


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
                    Nestedloop:
                    while(msg!=null)
                    {
                        System.out.println("Client: "+msg);
                        if(msg.equalsIgnoreCase("."))
                        {
                            pr.println(msg);
                            System.out.println("Server: "+in.readLine());
                            br2.close();
                            break Nestedloop;
                        }
                        else if(msg.equalsIgnoreCase("send attachment"))
                        {
                            System.out.println("Sending File");
                            File file=new File("buet.png");
                            FileInputStream fstream =new FileInputStream(file);

                            long length=file.length();

                            byte[] bytearray = Files.readAllBytes(file.toPath());

//                            byte[] bytearray=new byte[(int)length];
                            fstream.read(bytearray,0,(int)length);


                            String encoded= Base64.encode(bytearray);
                            pr.println(encoded);
                            pr.flush();

                            pr.println("Subject:Small Koala\n" +
                                    "MIME-Version: 1.0\n" +
                                    "Content-Type:multipart/mixed;  boundary=\"sam\"\n" +
                                    "--sam\n" +
                                    "Content-Type:application/octet-stream;name=\"koala.jpg\"\n" +
                                    "Content-Transfer-Encoding:base64\n" +
                                    "Content-Disposition:attachment;filename=\"koala.jpg\"\n" +
                                    "\n" +
                                    "--sam--\n");

                            pr.flush();

//                            File file = new File("buet.png");
//                            FileInputStream fis = null;
//
//                            fis = new FileInputStream(file);
//
//                            BufferedInputStream bis = new BufferedInputStream(fis);
//
//                            byte[] contents;
//                            long fileLength = file.length();
//
//
//                            long current = 0;
//
//                            long start = System.nanoTime();
//                            while(current!=fileLength){
//                                int size = 10000;
//                                if(fileLength - current >= size)
//                                    current += size;
//                                else{
//                                    size = (int)(fileLength - current);
//                                    current = fileLength;
//                                }
//                                contents = new byte[size];
//                                bis.read(contents, 0, size);
//
//                                String encoded= Base64.encode(contents);
//                                pr.println(encoded);
////                                pr.flush();
////                                os.write(Integer.parseInt(encoded));
////
////                                os.write(contents);
//                                System.out.println("Sending file ... "+(current*100)/fileLength+"% complete!");
//                            }
//                            pr.flush();
//                            System.out.println("File sent successfully!");

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

    public static byte[] extractBytes (String ImageName) throws IOException {
        // open image
        File imgPath = new File(ImageName);
        BufferedImage bufferedImage = ImageIO.read(imgPath);

        // get DataBufferBytes from Raster
        WritableRaster raster = bufferedImage .getRaster();
        DataBufferByte data   = (DataBufferByte) raster.getDataBuffer();

        return ( data.getData() );
    }
}


