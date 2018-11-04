import FileManagement.Router;

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


        String str;

        while(true)
        {
            try {

                if( (str = br.readLine()) != null )
                {
                        System.out.println("[" + id + "] says: " + str);
                        // receiving server response
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
                        else if(arr[0].endsWith("GET")){
                            System.out.println("post values -->"+str);

                            Router r = new Router(arr[0] , os);
                            r.sendResponse();
                        }

                }
                else
                {
                    System.out.println("[" + id + "] terminated connection. Worker thread will terminate now.");
                    break;
                }

            } catch (IOException e1) {
                e1.printStackTrace();
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
            e.printStackTrace();
        }

        HTTPServer.workerThreadCount--;
        System.out.println("Client [" + id + "] is now terminating. No. of worker threads = "
                + HTTPServer.workerThreadCount);
    }


}