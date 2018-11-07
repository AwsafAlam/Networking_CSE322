package FileManagement;

import java.io.*;

public class Router {

    private String url;

    private OutputStream os;

    private PrintWriter pr;
    private BufferedReader br;


    public Router(String url, OutputStream os, BufferedReader br) {
        this.url = url;
        this.os = os;
        this.br = br;

        pr = new PrintWriter(os);
    }



    public boolean FileExists(String url){
        File f = new File(url);
        return f.exists();
    }

//    public void processData() {
//        System.out.println("Process ding POST req..");
//
//        PostReq pst = new PostReq(pr , os, url, map);
//        pst.write();
////        NotFound nf = new NotFound(pr, os);
////        nf.write();
//
//    }


    public void route(String request) {
        if(url.endsWith("/")){
            url += "index.html";
        }
        url = url.substring(1);

        if(request.equals("POST")){
//            PostReq p = new PostReq(pr , os, url, map);
//            p.write();

            return;
        }
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
}
