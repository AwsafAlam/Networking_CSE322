package FileManagement;

import java.io.*;

public class PostReq {

    PrintWriter pr;
    private OutputStream os;
    String url;

    public PostReq(PrintWriter pr, OutputStream os) {
        this.pr = pr;
        this.os = os;
        this.url = url;
    }



    public void write(){
        try {
            String start_tag = "HTTP/1.1 200 OK";

            pr.println(start_tag);
            pr.flush();
            System.out.println(start_tag);

//            File file = new File(url);
//            FileInputStream fis = null;
//
//            fis = new FileInputStream(file);
//
//            BufferedInputStream bis = new BufferedInputStream(fis);
//        OutputStream os = socket.getOutputStream();

//            byte[] contents;
//            long fileLength = file.length();

            String head = "HTTP/1.1 200 OK\n" +
                    "Date: Sun, 04 Nov 2018 11:50:15 GMT\n" +
                    "Accept-Ranges: bytes\n" +
                    "Keep-Alive: timeout=15, max=100\n" +
                    "Connection: Keep-Alive\n" +
                    "CRLF";

            System.out.println(head);
            pr.println(head);
            pr.flush();

            pr.println("");
            pr.flush();
            System.out.println("Response sent .. ");

//            long current = 0;
//
//            long start = System.nanoTime();
//            while(current!=fileLength){
//                int size = 10000;
//                if(fileLength - current >= size)
//                    current += size;
//                else{
//                    size = (int)(fileLength - current);
//                    current = fileLength;
//                }
//                contents = new byte[size];
//                bis.read(contents, 0, size);
//                os.write(contents);
//                System.out.println("Sending file ... "+(current*100)/fileLength+"% complete!");
//            }
//            os.flush();
//            System.out.println("File sent successfully!");

        } catch (Exception e) {
            e.printStackTrace();
        }
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
}
