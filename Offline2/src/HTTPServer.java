import java.net.ServerSocket;
import java.net.Socket;


public class HTTPServer {

    private static final int PORT = 4000;
    static int workerThreadCount = 0;

    public static void main(String[] args) {

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



