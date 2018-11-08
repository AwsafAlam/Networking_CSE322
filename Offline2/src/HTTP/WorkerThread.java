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
    private File log;
    private FileWriter fileWriter;
    private int id;

    WorkerThread(Socket s, int id) throws IOException {
        this.socket = s;
        this.id = id;

        log = new File(HTTPServer.logdir+"/log."+id+".txt");
        if(!log.exists()){
            log.createNewFile();
            System.out.println("log file created");
        }

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

    }

    public void run()
    {

//        try {
//            fileWriter = new FileWriter(log);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }


        String str ="", httpRequest = "";
        char charIn;


        while(true)
        {
            try {

                StringBuilder buff = new StringBuilder();
//                if(br.readLine() == null)
//                    break;

                while (br.ready()){
                    charIn = (char) br.read();

                    buff.append(charIn);
                }

                str = buff.toString();

                fileWriter = new FileWriter(log);
                fileWriter.write(str);
                fileWriter.flush();
                fileWriter.close();

                Scanner sc = new Scanner(str);
                String url = null;

                while (sc.hasNextLine()){
                    String line = sc.nextLine();
                    System.out.println("[" + id + "] says: " + line);

                    String arr[] = line.split(" ");

                    if(arr[0].equals("GET")){
                        httpRequest = "GET";
                        Router r = new Router(arr[1] , os , br);
                        r.route("GET");

                    }
                    else  if(arr[0].equals("POST")){
                        httpRequest = "POST";
                        url = arr[1];

                    }
                    else if(httpRequest.equals("POST") && arr[0].startsWith("user") && url != null){
                        String items[] = arr[0].split("&");
                        HashMap<String , String> map = new HashMap<>();
                        for (String item : items) {
                            String keyval[] = item.split("=");
                            if (keyval.length > 1) {
                                map.put(keyval[0], keyval[1]);
                            } else {
                                System.out.println("No value specified in input form.");
                                map.put(keyval[0], "");
                            }
                        }
                        Router r = new Router(url , os , br , map);
                        r.route("POST");

//                        PostReq pst = new PostReq(pr , os , url , map);
//                        pst.write();
                    }
                    else if(httpRequest.equals("POST") && arr[0].startsWith("Referer")){
                        String referer[] = arr[1].split("/");
                        url += "/"+referer[referer.length -1];
                    }
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