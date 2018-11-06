import FileManagement.Router;

import java.io.*;
import java.net.Socket;

class WorkerThread implements Runnable
{
    private Socket socket;
    private InputStream is;
    private OutputStream os;

    private BufferedReader br;
    private PrintWriter pr;

    private int id;

    WorkerThread(Socket s, int id)
    {
        this.socket = s;

        try
        {
            this.is = this.socket.getInputStream();
            this.os = this.socket.getOutputStream();

            br = new BufferedReader(new InputStreamReader(this.is));
            pr = new PrintWriter(this.os);

        }
        catch(Exception e)
        {
            System.err.println("Sorry. Cannot manage client [" + id + "] properly.");
        }

        this.id = id;
    }

    public void run()
    {


        String str;

        while(true)
        {
            try {

                if( (str = br.readLine()) != null )
                {
                        // receiving server response
                        System.out.println("[" + id + "] says: " + str);

                        String arr[] = str.split(" ");

                        if(arr[0].equals("GET")){
                            System.out.println("GET request received by server --------------->");
                            Router r = new Router(arr[1] , os);
                            r.sendData();
                        }
                        else  if(arr[0].equals("POST")){
                            System.out.println("POST request received by server --------------->");
                            Router r = new Router(arr[1] , os);

                            r.processData();

                        }
                        else if(arr[0].substring(0,3).equals("user")){
                            System.out.println("------------------- FOUND POST DATA ------------------");
                            Router r = new Router("/http_post.html", os);

                            r.sendData();
                        }
                        else if(arr[0].endsWith("GET")){
                            System.out.println("post values -->"+str);

                            Router r = new Router(arr[0] , os);
                            r.sendResponse();
                        }

                }
                else
                {
                    System.out.println("[" + id + "] terminated connection. Worker thread will terminate now. Null received");
                    break;
                }

            }
            catch(Exception e)
            {
                System.err.println("Problem in communicating with the client [" + id + "]. Terminating worker thread.");
                e.printStackTrace();
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
            e.printStackTrace();
        }

        HTTPServer.workerThreadCount--;
        System.out.println("Client [" + id + "] is now terminating. No. of worker threads = "
                + HTTPServer.workerThreadCount);
    }


}