package FileManagement;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class NotFound {
    PrintWriter pr;
    private OutputStream os;

    public NotFound(PrintWriter pr, OutputStream os) {
        this.pr = pr;
        this.os = os;
    }

    public void write(){
        try {
            String start_tag = "HTTP/1.1 404 Not Found";

            pr.println(start_tag);
            pr.flush();
            System.out.println(start_tag);

            File file = new File("404.html");
            FileInputStream fis = null;

            fis = new FileInputStream(file);

            BufferedInputStream bis = new BufferedInputStream(fis);

            byte[] contents;
            long fileLength = file.length();

            String timeStamp = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss zzz").format(Calendar.getInstance().getTime());

            System.out.println(timeStamp);

            String head = "Date: "+timeStamp+"\n" +
                    "Accept-Ranges: bytes\n" +
                    "Content-Length: "+String.valueOf(fileLength)+"\n" +
                    "Keep-Alive: timeout=15, max=100\n" +
                    "Connection: Keep-Alive\n" +
                    "Content-Type: text/html\n" +
                    "CRLF";

            System.out.println(head);
            pr.println(head);
            pr.flush();

            pr.println("");
            pr.flush();


            long current = 0;

//            long start = System.nanoTime();
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
