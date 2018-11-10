package SMTPclient;

import com.sun.org.apache.xerces.internal.impl.dv.util.Base64;

import java.io.*;
import java.net.*;
import java.nio.file.Files;

public class SMTPclient {

    public static void main(String[] args) throws UnknownHostException, IOException {
        String temp;
        //String mailServer = "smtp.sendgrid.net";
        String mailServer="webmail.buet.ac.bd";
        InetAddress mailHost = InetAddress.getByName(mailServer);
        InetAddress localHost = InetAddress.getLocalHost();
        Socket smtpSocket = new Socket();
        smtpSocket.connect(new InetSocketAddress(mailHost,25),5000);
        BufferedReader in =  new BufferedReader(new InputStreamReader(smtpSocket.getInputStream()));
        PrintWriter pr = new PrintWriter(smtpSocket.getOutputStream(),true);
        String initialID = in.readLine();
        System.out.println("Server: "+initialID);


        try {
            BufferedReader br=new BufferedReader(new FileReader("input.txt"));
            BufferedReader br2=new BufferedReader(new FileReader("mail.txt"));
            String cmd = br.readLine();
            while (cmd != null) {
                System.out.println("Client: "+cmd);

                if(cmd.equalsIgnoreCase("HELO"))
                {
                    pr.println(cmd +" "+ localHost.getHostName());
                    System.out.println("Server: "+in.readLine());

                }
                else if(cmd.equalsIgnoreCase("QUIT")) {
                    pr.println(cmd);
                    System.out.println("Server: "+in.readLine());
                    return;
                }
                else if(cmd.equalsIgnoreCase("RSET"))
                {
                    pr.println(cmd);
                    System.out.println("Server: "+in.readLine());
                    System.out.println("Server: You are now in HALO state..Please enter sender & receiver...");
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
                        else if(msg.startsWith("send attachment"))
                        {


                            String attaches[] = msg.split(" ");

                            for(int i=2 ; i < attaches.length; i++){

                                File fi = new File(attaches[i]);
                                if(!fi.exists()){
                                    System.err.println("Attachment file does not exist");
                                    continue;
                                }
                                pr.println("--sep");
                                pr.println("Content--Type: application/octet-stream; name=\""+attaches[i]+"\"\n" +
                                        "Content-Disposition: attachment; filename=\""+attaches[i]+"\"\n" +
                                        "Content-Transfer-Encoding: base64\n" +
                                        "\n" +
                                        "\n");
                                byte[] fileContent = Files.readAllBytes(fi.toPath());
                                String encoded= Base64.encode(fileContent);
                                pr.println(encoded);
                                pr.println("...");

                            }


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
        } catch (SocketTimeoutException es){
            System.out.println("Server Timeout ou noooo...");
        } catch (IOException e) {
            System.out.println(e.toString());
        }

    }
}
