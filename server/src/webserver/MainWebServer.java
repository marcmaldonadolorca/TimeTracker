package webserver;

import core.TimeTracker;
import core.TrackerNode;
import core.TimeCounter;

public class MainWebServer {
  public static void main(String[] args) {
    webServer();
  }

  public static void webServer() {
    //final TrackerNode root = makeTreeCourses();
    final TimeTracker root = new TimeTracker(2);
    root.testA();
    // implement this method that returns the tree of
    // appendix A in the practicum handout

    // start your clock (no cal, s'inicialitza al constructor del TimeTracker

    new WebServer(root.getTrackerNodes().get(0));
  }
}