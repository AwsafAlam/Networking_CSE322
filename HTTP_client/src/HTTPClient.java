import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.util.Random;

public class HTTPClient {

    public static void main(String[] args) throws Exception {

        InetAddress addr = InetAddress.getLocalHost();
        Socket socket = new Socket(addr , 8080);
        PrintWriter out = new PrintWriter(socket.getOutputStream() ,true);
        BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        String cookie = "";
        out.println("GET / HTTP/1.1");
        out.println();

        while (true){
            String s = in.readLine();
            if( s== null) break;
            if(s.startsWith("setCookie")){
                System.out.println("Cookie received");
                String val[] = s.split(" ");
                cookie = val[1];
            }

            System.out.println(s);
        }

        out.println("GET / HTTP/1.1\n" +
                "Cookie: "+cookie);
        out.println();
        System.out.println("Second get req");
        while (true){
            String s = in.readLine();
            if( s== null) break;
            System.out.println(s);
        }

        out.println("GET / HTTP/1.1\n" +
                "Cookie: "+cookie);
        out.println();

        while (true){
            String s = in.readLine();
            if( s== null) break;
            System.out.println(s);
        }

        socket.close();
    }
}
