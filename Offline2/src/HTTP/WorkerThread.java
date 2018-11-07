package HTTP;

import FileManagement.PostReq;
import FileManagement.Router;

import java.io.*;
import java.net.Socket;
import java.util.HashMap;
import java.util.Scanner;

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
        String str ="", prev = "";
        char charIn;


        while(true)
        {
            try {

                StringBuilder buff = new StringBuilder();

                while (br.ready()){
                    charIn = (char) br.read();
                    buff.append(charIn);

                }

                str = buff.toString();

                Scanner sc = new Scanner(str);
                String url = null;

                while (sc.hasNextLine()){
                    String line = sc.nextLine();
                    System.out.println("[" + id + "] says: " + line);

                    String arr[] = line.split(" ");

                    if(arr[0].equals("GET")){
                        prev = "GET";
                        System.out.println("GET request received by server --------------->");
                        Router r = new Router(arr[1] , os , br);
                        r.route("GET");

                    }
                    else  if(arr[0].equals("POST")){
                        prev = "POST";
                        System.out.println("POST request received by server --------------->\n"+str);
                        url = arr[1];
//                        Router r = new Router(arr[1] , os, br);
//                        r.route("POST");


                    }
                    else if(arr[0].startsWith("user") && url != null){
                        String items[] = arr[0].split("&");
                        HashMap<String , String> map = new HashMap<>();
                        for(int k = 0 ; k< items.length ; k++){
                            String keyval[] = items[k].split("=");
                            if(keyval.length > 1){
                                map.put(keyval[0] , keyval[1]);
                            }
                        }

                        url = url.substring(1);
                        url = "http_post.html";
                        PostReq pst = new PostReq(pr , os , url , map);
                        pst.write();
                    }
                }

                str = "";
                /*if( (str = br.readLine()) != null )
                {
                        // receiving server response
                        System.out.println("[" + id + "] says: " + str);

                        String arr[] = str.split(" ");

                        if(arr[0].equals("GET")){
                            prev = "GET";
                            System.out.println("GET request received by server --------------->");
                            Router r = new Router(arr[1] , os , br);
                            r.route("GET");

                        }
                        else  if(arr[0].equals("POST")){
                            prev = "POST";
                            System.out.println("POST request received by server --------------->");
                            Router r = new Router(arr[1] , os, br);
                            r.route("POST");

                        }
                        else if(arr[0].equals("")){

                            System.out.println("REQUEST COMPLETE -- >");
                            if(prev.equals("POST")){

                                DataInputStream dis;

                                try {

                                    // create new data input stream
                                    dis = new DataInputStream(is);
                                    while (true){
                                        if(dis.available()>0) {

                                            // read character
                                            char c = dis.readChar();

                                            // print
                                            System.out.print(c);
                                        }
                                    }
                                    // read till end of the stream


                                } catch(Exception e) {

                                    e.printStackTrace();
                                }
//                                finally {
//                                    // releases all system resources from the streams
//                                    if(is!=null)
//                                        is.close();
//                                    if(dos!=null)
//                                        is.close();
//                                    if(dis!=null)
//                                        dis.close();
//                                    if(fos!=null)
//                                        fos.close();
//                                }
                            }

                        }
                        else if(arr[0].substring(0,3).equals("user")){

                            System.out.println("------------------- FOUND POST DATA ------------------");

                        }


                }
                else
                {
                    System.out.println("[" + id + "] terminated connection. Worker thread will terminate now. Null received");
                    break;
                }*/

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