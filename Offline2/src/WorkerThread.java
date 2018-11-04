import java.io.*;
import java.net.Socket;

class WorkerThread implements Runnable
{
    private Socket socket;
    private InputStream is;
    private OutputStream os;

    private int id;

    WorkerThread(Socket s, int id)
    {
        this.socket = s;

        try
        {
            this.is = this.socket.getInputStream();
            this.os = this.socket.getOutputStream();
        }
        catch(Exception e)
        {
            System.err.println("Sorry. Cannot manage client [" + id + "] properly.");
        }

        this.id = id;
    }

    public void run()
    {
        BufferedReader br = new BufferedReader(new InputStreamReader(this.is));
        PrintWriter pr = new PrintWriter(this.os);

        //pr.println("Your id is: " + this.id);
        //pr.flush();

        String str;

        while(true)
        {
            try
            {
                if( (str = br.readLine()) != null )
                {
                    if(str.equals("BYE"))
                    {
                        System.out.println("[" + id + "] says: BYE. Worker thread will terminate now.");
                        break; // terminate the loop; it will terminate the thread also
                    }
                    else if(str.equals(""))
                    {
                        try
                        {
                            System.out.println("http response .. ");
                            String start_tag = "HTTP/1.1 200 OK";

                            pr.println(start_tag);
                            pr.flush();



                            System.out.println("Response sent..");
                            File file = new File("http_post.html");
                            FileInputStream fis = new FileInputStream(file);
                            BufferedInputStream bis = new BufferedInputStream(fis);
                            OutputStream os = socket.getOutputStream();
                            byte[] contents;
                            long fileLength = file.length();

//                            String header = "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8\n"+
//                                    "Accept-Encoding: gzip, deflate, br\n"+
//                                    "Accept-Ranges: bytes\n"+
//                                    "Content-Length: "+String.valueOf(fileLength)+"\n" +
//                                    "Keep-Alive: timeout=15, max=100\n" +
//                                    "Connection: Keep-Alive\n" +
//                                    "Content-Type: text/html\n" +
//                                    "CRLF\n";

                            String head = "HTTP/1.1 200 OK\n" +
                                    "Date: Sun, 04 Nov 2018 11:50:15 GMT\n" +
                                    "Accept-Ranges: bytes\n" +
                                    "Content-Length: "+String.valueOf(fileLength)+"\n" +
                                    "Keep-Alive: timeout=15, max=100\n" +
                                    "Connection: Keep-Alive\n" +
                                    "Content-Type: text/html\n" +
                                    "CRLF";

//                            pr.println(String.valueOf(fileLength));		//These two lines are used
//                            pr.flush();									//to send the file size in bytes.

                            pr.println(head);
                            pr.flush();

                            pr.println("");
                            pr.flush();

//                            String body = "<html>\n" +
//                                    "<head><title>Test page</title></head>\n" +
//                                    "<body>\n" +
//                                    "<h1>Test page</h1>\n" +
//                                    "</html>";
//
//                            pr.println(body);
//                            pr.flush();

                            long current = 0;

                            long start = System.nanoTime();
                            while(current!=fileLength){
                                int size = 10000;
                                if(fileLength - current >= size)
                                    current += size;
                                else{
                                    size = (int)(fileLength - current);
                                    current = fileLength;
                                }
                                contents = new byte[size];
                                bis.read(contents, 0, size);
                                os.write(contents);
                                System.out.println("Sending file ... "+(current*100)/fileLength+"% complete!");
                            }
                            os.flush();
                            System.out.println("File sent successfully!");
                        }
                        catch(Exception e)
                        {
                            System.err.println("Could not transfer file. "+e.toString());
                            e.printStackTrace();
                        }
                        //pr.println("Downloaded.");
                        //pr.flush();

                    }
                    else
                    {
                        System.out.println("[" + id + "] says: " + str);
//                        pr.println("Got it. You sent \"" + str + "\"");
//                        pr.flush();
                    }
                }
                else
                {
                    System.out.println("[" + id + "] terminated connection. Worker thread will terminate now.");
                    break;
                }
            }
            catch(Exception e)
            {
                System.err.println("Problem in communicating with the client [" + id + "]. Terminating worker thread.");
                break;
            }
        }

        try
        {
            this.is.close();
            this.os.close();
            this.socket.close();
        }
        catch(Exception e)
        {

        }

        HTTPServer.workerThreadCount--;
        System.out.println("Client [" + id + "] is now terminating. No. of worker threads = "
                + HTTPServer.workerThreadCount);
    }
}