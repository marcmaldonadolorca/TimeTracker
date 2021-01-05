package webserver;

import core.TimeTracker;
import core.TrackerNode;
import core.Project;
import core.Task;
import org.json.JSONArray;
import org.json.JSONObject;

import java.text.DecimalFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.text.SimpleDateFormat;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.time.format.DateTimeFormatter;
import java.util.LinkedList;
import java.util.List;
import java.util.StringTokenizer;

// Based on
// https://www.ssaurel.com/blog/create-a-simple-http-web-server-in-java
// http://www.jcgonzalez.com/java-socket-mini-server-http-example

public class WebServer {
  private static final int PORT = 8080; // port to listen to
  private TimeTracker currentTimeTracker;
  private TrackerNode currentActivity;
  private final TrackerNode root;

  public WebServer(TimeTracker timeTracker, TrackerNode root) {
    this.root = root;
    this.currentTimeTracker = timeTracker;
    System.out.println(root);
    currentActivity = root;
    try {
      ServerSocket serverConnect = new ServerSocket(PORT);
      System.out.println("Server started.\nListening for connections on port : " + PORT + " ...\n");
      // we listen until user halts server execution
      while (true) {
        // each client connection will be managed in a dedicated Thread
        new SocketThread(serverConnect.accept());
        // create dedicated thread to manage the client connection
      }
    } catch (IOException e) {
      System.err.println("Server Connection error : " + e.getMessage());
    }
  }

  private TrackerNode findActivityById(int id) {
    return root.findActivityById(id);
  }

  private int adquirePresentActivityId() {
    return this.currentTimeTracker.adquirePresentActivityId();
  }

  private class SocketThread extends Thread {
    // SocketThread sees WebServer attributes
    private final Socket insocked;
    // Client Connection via Socket Class

    SocketThread(Socket insocket) {
      this.insocked = insocket;
      this.start();
    }

    @Override
    public void run() {
      // we manage our particular client connection
      BufferedReader in;
      PrintWriter out;
      String resource;

      try {
        // we read characters from the client via input stream on the socket
        in = new BufferedReader(new InputStreamReader(insocked.getInputStream()));
        // we get character output stream to client
        out = new PrintWriter(insocked.getOutputStream());
        // get first line of the request from the client
        String input = in.readLine();
        // we parse the request with a string tokenizer

        System.out.println("sockedthread : " + input);

        StringTokenizer parse = new StringTokenizer(input);
        String method = parse.nextToken().toUpperCase();
        // we get the HTTP method of the client
        if (!method.equals("GET")) {
          System.out.println("501 Not Implemented : " + method + " method.");
        } else {
          // what comes after "localhost:8080"
          resource = parse.nextToken();
          System.out.println("input " + input);
          System.out.println("method " + method);
          System.out.println("resource " + resource);

          parse = new StringTokenizer(resource, "/[?]=&");
          int i = 0;
          String[] tokens = new String[20];
          // more than the actual number of parameters
          while (parse.hasMoreTokens()) {
            tokens[i] = parse.nextToken();
            System.out.println("token " + i + "=" + tokens[i]);
            i++;
          }

          // Make the answer as a JSON string, to be sent to the Javascript client
          String answer = makeHeaderAnswer() + makeBodyAnswer(tokens);
          System.out.println("answer\n" + answer);
          // Here we send the response to the client
          out.println(answer);
          out.flush(); // flush character output stream buffer
        }

        in.close();
        out.close();
        insocked.close(); // we close socket connection
      } catch (Exception e) {
        System.err.println("Exception : " + e);
      }
    }


    private String makeBodyAnswer(String[] tokens) {
      String body = "";
      switch (tokens[0]) {
        case "get_tree" : {
          int id = Integer.parseInt(tokens[1]);
          TrackerNode activity = findActivityById(id);
          assert (activity!=null);
          body = activity.toJson(1).toString();
          break;
        }
        case "start": {
          int id = Integer.parseInt(tokens[1]);
          TrackerNode activity = findActivityById(id);
          System.out.println(activity.getNodeName()+"starts");
          assert (activity!=null);
          Task task = (Task) activity;
          int activityId =  adquirePresentActivityId();
          System.out.println("with new ID from: "+activityId);
          currentTimeTracker.startCounting(task);
          body = "{}";
          break;
        }
        case "stop": {
          int id = Integer.parseInt(tokens[1]);
          TrackerNode activity = findActivityById(id);
          System.out.println(activity.getNodeName()+"stops");
          assert (activity!=null);
          Task task = (Task) activity;
          currentTimeTracker.stopCounting(task);
          body = "{}";
          break;
        }
        // TODO: add new task, project
        case "add": {
          //0=ordre, 1=parentId, 2=nom, 3=tags(separats per comes), 4=type,
          int id = Integer.parseInt(tokens[1]);
          String name = tokens[2];
          name = name.replace("%20"," ");//a la url espai és %20(es pot canviar abans o després)
          Boolean isProject = Boolean.parseBoolean(tokens[4]);
          TrackerNode parentNode = currentTimeTracker.getTrackerNodeById(id);
          String parentName = parentNode.getNodeName();
          TrackerNode newNode = currentTimeTracker.createNewNode(name, (Project) parentNode, isProject);

          //Processar tags del node si nhi ha: indicat per empty_of_tags des de la app quan usr no intro tag
          if(!tokens[3].equalsIgnoreCase("empty_of_tags")) {
            String tags = tokens[3];
            String[] listTags = tags.split(",");
            for (String newTag : listTags) {
              if (newTag.charAt(0) == '%') {
                newTag = newTag.replaceFirst("%20", "");//per eliminar possibles espai despres de coma
              }
              newNode.setTag(newTag);
            }
          }
          body = "{}";
          break;
        }
        // TODO:tags
        case "searchTag": {//0=ordre, 1=tags(únic)
          String tag = tokens[1];
          List<TrackerNode> nodesWithTag = currentTimeTracker.searchByTag(tag);
          assert (nodesWithTag!=null);
          JSONArray listNodes = new JSONArray();
          for (TrackerNode node: nodesWithTag){
            JSONObject aux = node.toJson(0);
            System.out.println(node.getNodeName());
            listNodes.put(aux);

          }
          //per aprofitar el getTree per rebre el llistat d'activitats resultat les posem com a filles d'un pare auxiliar
          JSONObject portador = new JSONObject();
          portador.put("id",1000);portador.put("name", "portador");portador.put("duration",0);
          portador.put("active",false);portador.put("parentName","Déu_Nostre_Senyor");
          JSONArray tagsPortador= new JSONArray();
          portador.put("tags",tagsPortador);portador.put("class","project");
          portador.put("activities", listNodes);
          body = portador.toString();//Repassar la app que desmonti el JSON correctament!!!!!!
          break;
        }
        // TODO:totalTime
        case "searchTime": { //0=ordre, 1=nom node, 2=start, 3=final times, 4=cost
          String name = tokens[1];
          //Per revisar pantalles 18 i 19 quin format passa les dates
          DateTimeFormatter formater1 = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
          String startAux0 = tokens[2].replaceFirst("%20"," ");
          String[] startAux = startAux0.split("\\.");
          LocalDateTime start = LocalDateTime.parse(startAux[0],formater1);
          String finalAux0 = tokens[3].replaceFirst("%20"," ");
          String[] finalAux = finalAux0.split("\\.");
          LocalDateTime end = LocalDateTime.parse(finalAux[0],formater1);
          Duration time = currentTimeTracker.searchTotalTime(name, start, end);
          double cost = Double.parseDouble(tokens[4]);
          //long durationInHours =  time.toHours()+(time.toMinutes()/60);
          //int aux = (int) (durationInHours*100);
          //float result = aux/100f;
          //String responseTimePlusCost = Float.toString(result)+"/"+Double.toString(result*cost);

          double durationInSeconds = time.toHours()*3600 +time.toMinutes()*60 + time.getSeconds();
          String responseTimePlusCost = Double.toString(durationInSeconds)+"/"+Double.toString(durationInSeconds*cost)+"/";
          body = responseTimePlusCost;
          break;
        }
        // TODO:recent
        case "searchRecent": {
          LinkedList<Task> recentTasks = currentTimeTracker.getRecentTasks();
          assert (recentTasks!=null);
          JSONArray listNodes = new JSONArray();
          for (TrackerNode node: recentTasks){
            JSONObject aux = node.toJson(0);
            System.out.println(node.getNodeName());
            listNodes.put(aux);
          }
          //per aprofitar el getTree per rebre el llistat d'activitats resultat les posem com a filles d'un pare auxiliar
          JSONObject portador = new JSONObject();
          portador.put("id",1000);portador.put("name", "portador");portador.put("duration",0);
          portador.put("active",false);portador.put("parentName","Déu_Nostre_Senyor");
          JSONArray tagsPortador= new JSONArray();
          portador.put("tags",tagsPortador);portador.put("class","project");
          portador.put("activities", listNodes);
          body = portador.toString();//Repassar la app que desmonti el JSON correctament!!!!!!
          break;
        }
        default:
          assert false;
      }
      System.out.println(body);
      return body;
    }

    private String makeHeaderAnswer() {
      String answer = "";
      answer += "HTTP/1.0 200 OK\r\n";
      answer += "Content-type: application/json\r\n";
      answer += "\r\n";
      // blank line between headers and content, very important !
      return answer;
    }
  } // SocketThread

} // WebServer