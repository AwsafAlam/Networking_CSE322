import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;


public class HTTPServer {

    private static final int PORT = 4000;
    static int workerThreadCount = 0;

    public static void main(String[] args) throws IOException {


//        ServerSocket serverConnect = new ServerSocket(PORT);
//        System.out.println("Server started.\nListening for connections on port : " + PORT + " ...\n");
//        while(true)
//        {
//            Socket s=serverConnect.accept();
//            BufferedReader in = new BufferedReader(new InputStreamReader(s.getInputStream()));
//            PrintWriter pr = new PrintWriter(s.getOutputStream());
//            String input = in.readLine();
//            System.out.println("Here Input : "+input);
//
//            String msg = "HTTP/1.1 200 OK\n" +
//                    "Connection: Keep-Alive\n" +
//                    "Content-Type: text/html\n" +
//                    "CRLF\n" +
//                    "<html>\n" +
//                    "<head><title>Test page</title></head>\n" +
//                    "<body>\n" +
//                    "<h1>Test page</h1>\n" +
//                    "</html>";
//
//            pr.println(msg);
//            pr.flush();
//            System.out.println("Sent");
//        }

        int id = 1;

        try
        {
            ServerSocket ss = new ServerSocket(PORT);
            System.out.println("Server started.\nListening for connections on port : " + PORT + " ...\n");

            while(true)
            {
                Socket s = ss.accept();	//TCP Connection
                WorkerThread wt = new WorkerThread(s, id);
                Thread t = new Thread(wt);
                t.start();
                workerThreadCount++;
                System.out.println("Client [" + id + "] is now connected. No. of worker threads = " + workerThreadCount);
                id++;
            }
        }
        catch(Exception e)
        {
            System.err.println("Problem in ServerSocket operation. Exiting main.");
        }

    }

}



