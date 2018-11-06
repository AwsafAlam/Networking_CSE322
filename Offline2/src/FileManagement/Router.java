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

        if(! FileExists(url)){
            System.out.println(" Not found ->" +url);
            NotFound nf = new NotFound(pr, os);
            nf.write();
        }
        else{
            System.out.println("File path ->" +url);

            FileWriter f = new FileWriter(pr,os ,url);
            f.write();
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

    public void processData() {
        System.out.println("Process ding POST req..");

//        NotFound nf = new NotFound(pr, os);
//        nf.write();

    }

    public void sendResponse() {
        url = url.substring(0 , url.length()-3);

        String val[] = url.split("&");

        for (int i=0 ; i< val.length ; i++){
//            System.out.println("val "+ Arrays.);
            String arr[] = val[i].split("=");
            FileWriter f = new FileWriter(pr,os ,"http_post.html");
            f.write();
        }


    }
}
