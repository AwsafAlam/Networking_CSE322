package FileManagement;

import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Router {

    String url;
    PrintWriter pr;
    List<String> dirs;
    private OutputStream os;



    public Router(String url ,OutputStream os) {
        this.url = url;
        this.os = os;
        pr = new PrintWriter(os);
        dirs = new ArrayList<>();

    }

    public void sendData() {

        if(url.equals("/")){
            url += "index.html";
        }
        url = url.substring(1);

        String MIMEType = getMIMEType(url);

        String status = "200 OK";

        String dirs[] = url.split("/");

        if(! FileExists(dirs[dirs.length - 1])){
            status = "404";
            System.out.println(" Not found ->" +url);
        }
        else{

        try {
        String start_tag = "HTTP/1.1 "+status;

        pr.println(start_tag);
        pr.flush();
        System.out.println(start_tag);

        File file = new File(url);
        FileInputStream fis = null;

            fis = new FileInputStream(file);

        BufferedInputStream bis = new BufferedInputStream(fis);
//        OutputStream os = socket.getOutputStream();

        byte[] contents;
        long fileLength = file.length();

        String head = "HTTP/1.1 200 OK\n" +
                "Date: Sun, 04 Nov 2018 11:50:15 GMT\n" +
                "Accept-Ranges: bytes\n" +
                "Content-Length: "+String.valueOf(fileLength)+"\n" +
                "Keep-Alive: timeout=15, max=100\n" +
                "Connection: Keep-Alive\n" +
                "Content-Type: "+MIMEType+"\n" +
                "CRLF";

        System.out.println(head);
        pr.println(head);
        pr.flush();

        pr.println("");
        pr.flush();


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

        } catch (Exception e) {
            e.printStackTrace();
        }
        }
    }


    String getFileName(){
        String links[] = url.split("/");
        System.out.println("File dir...---------------->   "+ Arrays.toString(links));
        if(links.length == 0){
            return "index.html";
        }

        for (int i =0 ; i < links.length ; i++) {
            dirs.add(links[i]);
        }


        return links[links.length - 1];
    }

    String getMIMEType(String targetfile) {
        if (targetfile.endsWith("html"))
            return "text/html";

        else if (targetfile.endsWith("bmp"))
            return "image/bmp";

        else if (targetfile.endsWith("jpg"))
            return "image/jpeg";

        else if (targetfile.endsWith("pdf"))
            return "application/pdf";

        else if (targetfile.endsWith("png"))
            return "image/png";

        else
            return "text/plain";
    }

    public boolean FileExists(String url){
        File f = new File(url);
        return f.exists();
    }
}
