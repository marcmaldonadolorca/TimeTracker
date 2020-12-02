package core;

import org.json.JSONArray;
import org.json.JSONObject;
import visitor.SearchByTagVisitor;
import visitor.TotalTimeVisitor;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;



/**
 * La clase TimeTracker es la encargada de crear el árbol de tareas, además de controlar cuando se deben activar
 * y desactivar las tareas.
 * Almacena la lista de nodos del árbol (Projects & Tasks) y el reloj que controla las actualizaciones de
 * los tiempos de los intervalos.
 * También define y ejecuta los tests de comprobación.
 */
public class TimeTracker extends Thread {
  private List<TrackerNode> trackerNodes;
  private TimeCounter clockCounter;
  private TrackerNode root;
  private int activityId; //TODO
  private final int period;
  private final static Logger LOGGER = LoggerFactory.getLogger("core.TimeTracker");

  /*
   * El constructor recibe el período de actualización de los tiempos de los intervalos.
   */
  public TimeTracker(int period) {
    this.trackerNodes = new ArrayList<>();
    this.root = createNewNode("root", null, true);
    this.period = period;
    initClock();
    this.activityId = 0;
    LOGGER.info("TimeTracker creat.");
  }

  public List<TrackerNode> getTrackerNodes() {
    return trackerNodes;
  }

  private TrackerNode getTrackerNodeByName(String nodeName) {
    TrackerNode foundNode = null;
    for (TrackerNode trackerNodes : trackerNodes) {
      if (trackerNodes.getNodeName().equals(nodeName)) {
        foundNode = trackerNodes;
        break;
      }
    }
    return foundNode;
  }

  /*private TrackerNode findActivityById(int n) {
    TrackerNode foundNode = null;
    for (TrackerNode trackerNodes : trackerNodes) {
      if (trackerNodes.getNodeId().equals(n)) {
        foundNode = trackerNodes;
        break;
      }
    }
    return foundNode;
  }*/


  //TODO
  //public void createNewTreeFromJson(JSONArray objectsArray, int biggestIdPlusOne) {
  public void createNewTreeFromJson(JSONArray objectsArray) {
    this.trackerNodes.clear();
    //TODO
    //this.activityId = biggestIdPlusOne;
    this.root = createNewNode("root", null, true);//root reconstruction(no saved in the tree saving process)

    for (int i = 0; i < objectsArray.length(); i++) {
      JSONObject arrayObject = objectsArray.getJSONObject(i);
      String nodeName = arrayObject.getString("name");
      String parentName = arrayObject.getString("parentName");
      boolean isProject = arrayObject.getString("type").equals("project");
      TrackerNode parentNode = getTrackerNodeByName(parentName);
      //TODO
      //this.activityId = arrayObject.getString("nodeId");
      TrackerNode newNode = createNewNode(nodeName, (Project) parentNode, isProject);

      //Se ejecuta si el nodo es una Task y además tiene intervalos.
      if (!isProject && arrayObject.getString("childs").equals("exist")) {
        JSONArray arrayIntervals = arrayObject.getJSONArray("childsList");
        ((Task)newNode).setChildsFromJSON(arrayIntervals, this.period);
      }
    }
    //TODO
    //this.activityId = biggestIdPlusOne;

    LOGGER.info("Load end successfully");
  }

  private TrackerNode createNewNode(String nodeName, Project parentNode, boolean isProjectType) {
    TrackerNode newNode;

    if (isProjectType) {
      //TODO
      //newNode = new Project(nodeName, parentNode, this.activityId);
      newNode = new Project(nodeName, parentNode);
    } else {
      //TODO
      //newNode = new Task(nodeName, parentNode, this.activityId);
      newNode = new Task(nodeName, parentNode);
    }
    //TODO
    //this.activityId += 1;
    this.trackerNodes.add(newNode);

    //Si el nodo tratado no es el nodo root, se llama a la función addChild() para añadir el nodo que se está creando
    //como hijo del nodo padre
    if (parentNode != null) {
      addChild(parentNode, newNode);
    }

    return newNode;
  }

  /*
   * Esta función activa la tarea creando un intervalo asociado a ella. Además, añade el nuevo intervalo a la lista
   * de observers que serán notificados por cada período del reloj.
   */
  private void startCounting(TrackerNode node) {
    if (checkIfNodeIsTask(node) && !checkIfTaskIsRunning(node)) {
      //TODO
      //Interval interval = ((Task) node).startInterval(this.period, this.activityId);
      Interval interval = ((Task) node).startInterval(this.period);
      //TODO
      //this.activityId += 1;
      clockCounter.addObserver(interval);
      LOGGER.info("Observer afegit");
    }
    else {
      LOGGER.error("Error: This is not a core.Task / This core.Task is already running ");
    }
  }

  private boolean checkIfNodeIsTask(TrackerNode node) {
    return node instanceof Task;
  }

  private boolean checkIfTaskIsRunning(TrackerNode node) {
    return ((Task) node).getStatus();
  }

  /*
   * Esta función desactiva la tarea y elimina el intervalo correspondiente de la lista de observers.
   */
  private void stopCounting(TrackerNode node) {
    if (checkIfNodeIsTask(node) && checkIfTaskIsRunning(node)) {
      Interval activeInterval = ((Task) node).stopInterval();
      clockCounter.deleteObserver(activeInterval);
      LOGGER.debug("Stop observer\n");
    }
  }

  private void addChild(Project parentNode, TrackerNode childNode) {
    parentNode.setChild(childNode);
  }

  private void initClock() {
    clockCounter = TimeCounter.getInstance();
    LOGGER.debug("Clock Iniciat\n");
  }

  /*
   * Este test (A) ejecuta la creación del árbol de nodos.
   */
  public void testA() {
    LOGGER.info("Initializing TEST A");
    //LOGGER.info("%46s %22s %12s%n", "initial date", "final date", "duration");
    LOGGER.info("Start test");

    //Projects and tasks for testing
    TrackerNode proj1 = createNewNode("software design", (Project) root, true);
    TrackerNode proj2 = createNewNode("software testing", (Project) root, true);
    TrackerNode proj3 = createNewNode("databases", (Project) root, true);
    TrackerNode task1 = createNewNode("transportation", (Project) root, false);

    TrackerNode proj4 = createNewNode("problems", (Project) proj1, true);
    TrackerNode proj5 = createNewNode("project time tracker", (Project) proj1, true);

    TrackerNode task2 = createNewNode("first list", (Project) proj4, false);
    TrackerNode task3 = createNewNode("second list", (Project) proj4, false);
    TrackerNode task4 = createNewNode("read handout", (Project) proj5, false);
    TrackerNode task5 = createNewNode("first milestone", (Project) proj5, false);

    LOGGER.info("Test A end");
  }

  /*
   * Este test (B) activa y desactiva tareas y muestra el resultado de tiempos de los elementos del árbol
   */
  private void testB() {
    LOGGER.info("Initializing TEST B");
    TrackerNode task1 = getTrackerNodeByName("transportation");
    //task1 = transportation
    startCounting(task1);
    LOGGER.info("transportation starts\n");
    try {
      Thread.sleep(4000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task1);
    LOGGER.info("transportation stops\n");
    try {
      Thread.sleep(2000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }

    TrackerNode task2 = getTrackerNodeByName("first list");
    //task2 = first list
    startCounting(task2);
    LOGGER.info("first list starts\n");
    try {
      Thread.sleep(6000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }

    TrackerNode task3 = getTrackerNodeByName("second list");
    //task3 = second list
    startCounting(task3);
    LOGGER.info("second list starts\n");
    try {
      Thread.sleep(4000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task2);
    LOGGER.info("first list stops\n");
    try {
      Thread.sleep(2000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task3);
    LOGGER.info("second list stops\n");
    //task1 = transportation
    startCounting(task1);
    LOGGER.info("transportation starts\n");
    try {
      Thread.sleep(4000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task1);
    LOGGER.info("transportation stops\n");

    LOGGER.info("Saving data to testB.json file");
    DataManager dataManager = new DataManager("testB.json");
    //TODO
    //dataManager.fromJsonToFile(this.trackerNodes, this.activityId);
    dataManager.fromJsonToFile(this.trackerNodes);
  }

  /*
   * Este test (C) activa y desactiva tareas y muestra el resultado de tiempos de los elementos del árbol
   */
  private void testC() {
    LOGGER.info("Initializing TEST C");

    //Creación de nodos para el test
    TrackerNode proj0 = createNewNode("P0", (Project) root, true);
    TrackerNode proj1 = createNewNode("P1", (Project) root, true);
    TrackerNode proj3 = createNewNode("P3", (Project) root, true);
    TrackerNode task0 = createNewNode("T0", (Project) proj0, false);
    TrackerNode task1 = createNewNode("T1", (Project) proj0, false);
    TrackerNode task2 = createNewNode("T2", (Project) proj0, false);
    TrackerNode task3 = createNewNode("T3", (Project) proj1, false);
    TrackerNode task4 = createNewNode("T4", (Project) root, false);
    TrackerNode task5 = createNewNode("T5", (Project) root, false);

    LOGGER.info("Starting test time 0\n");
    try { // tiempo transcurrido: 0 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    startCounting(task0);
    LOGGER.info("T0 starts time 10s\n");
    try { // tiempo transcurrido: 10 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    startCounting(task4);
    LOGGER.info("T4 starts time 20s\n");
    try { // tiempo transcurrido: 20 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task0);
    LOGGER.info("T0 stops time 30s\n");
    stopCounting(task4);
    LOGGER.info("T4 stops time 30s\n");
    startCounting(task1);
    LOGGER.info("T1 starts time 30s\n");
    startCounting(task2);
    LOGGER.info("T2 starts time 30s\n");

    try { // tiempo transcurrido: 30 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }

    startCounting(task0);
    LOGGER.info("T0 starts time 40s\n");
    startCounting(task5);
    LOGGER.info("T5 starts time 40s\n");

    try { // tiempo transcurrido: 40 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task0);
    LOGGER.info("T0 stops time 50s\n");
    stopCounting(task1);
    LOGGER.info("T1 stops time 50s\n");
    startCounting(task4);
    LOGGER.info("T4 starts time 50s\n");

    try { // tiempo transcurrido: 50 seg
      Thread.sleep(20000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    startCounting(task1);
    LOGGER.info("T1 starts time 70s\n");
    stopCounting(task5);
    LOGGER.info("T5 stops time 70s\n");

    try { // tiempo transcurrido: 70 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    startCounting(task5);
    LOGGER.info("T5 starts time 80s\n");

    try { // tiempo transcurrido: 90 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task2);
    LOGGER.info("T2 stops time 90s\n");
    stopCounting(task5);
    LOGGER.info("T5 stops time 90s\n");

    try { // tiempo transcurrido: 90 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    startCounting(task5);
    LOGGER.info("T5 starts time 100s\n");

    try { // tiempo transcurrido: 100 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    startCounting(task2);
    LOGGER.info("T2 starts time 110s\n");
    stopCounting(task5);
    LOGGER.info("T5 stops time 110s\n");

    try { // tiempo transcurrido: 110 seg
      Thread.sleep(20000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task1);
    LOGGER.info("T1 stops time 130s\n");
    stopCounting(task2);
    LOGGER.info("T2 stops time 130s\n");
    stopCounting(task4);
    LOGGER.info("T4 stops time 130s\n");
    startCounting(task3);
    LOGGER.info("T3 starts time 130s\n");

    try { // tiempo transcurrido: 130 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    startCounting(task0);
    LOGGER.info("T0 starts time 140s\n");
    stopCounting(task3);
    LOGGER.info("T3 stops time 140s\n");
    startCounting(task4);
    LOGGER.info("T4 starts time 140s\n");

    try { // tiempo transcurrido: 140 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task0);
    LOGGER.info("T0 stops time 150s\n");

    try { // tiempo transcurrido: 150 seg
      Thread.sleep(10000);
    } catch (Exception e) {
      LOGGER.error("Error: " + e);
    }
    stopCounting(task4);
    LOGGER.info("T4 stops time 160s\n");
    LOGGER.info("End tree construction test C");

    //Test de cargado desde fichero.
    // Se comprueba que el fichero se carga correctamente comparándolo con el árbol generado anterior
    LOGGER.info("Saving data to testC.json file");
    DataManager dataManager = new DataManager("testC.json");
    //TODO
    //dataManager.fromJsonToFile(this.trackerNodes, this.activityId);
    dataManager.fromJsonToFile(this.trackerNodes);
  }

  private void testLoading(String jsonTestFile, boolean compare){
    LOGGER.info("Loading data from "+jsonTestFile+" file");
    if(compare) { //Compara el árbol original con el leído del fichero JSON
      List<TrackerNode> originalTree = new ArrayList<>(this.trackerNodes);
      DataManager dataManager = new DataManager(jsonTestFile);
      dataManager.fromFileToJson(this);

      boolean sameTrees = true;
      int i = 0;
      while (sameTrees && i < originalTree.size()) {
        //Comprueba si los tiempos del árbol clonado y los tiempos del árbol creado con los datos del fichero son iguales.
        if (Math.abs(originalTree.get(i).getTimeSpent().getSeconds() - trackerNodes.get(i).getTimeSpent().getSeconds())>2) {
          sameTrees = false;
        }
        i++;
      }
      if (sameTrees) {
        LOGGER.debug("The original and the loaded tree of TestB are EQUAL.\n");
      } else {
        LOGGER.debug("The original and the loaded tree of TestB are DIFFERENT.\n");
      }
    }
    else { //No hace la comparación de los árboles original y leído desde el JSON.
      DataManager dataManager = new DataManager(jsonTestFile);
      dataManager.fromFileToJson(this);
    }

    //Muestra por consola la estructura del árbol
    System.out.println("\n\n\nPrinting the entire Tree "+jsonTestFile+"\n");
    for(TrackerNode node : this.trackerNodes){
      String startDateTime, finalDateTime;

      if(node.getStartDateTime()!= null){
        startDateTime= node.getStartDateTime().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss"));
      }
      else {startDateTime ="null";}
      if(node.getStartDateTime()!= null){
        finalDateTime= node.getFinalDateTime().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss"));
      }
      else{finalDateTime ="null";}
      if (node instanceof Project)
      {
        System.out.printf("%-30s %-20s %-20s  %5d%n", "Project: "+ node.getNodeName(), startDateTime, finalDateTime,node.getTimeSpent().getSeconds());
      }
      else{
        System.out.printf("%-30s %-20s %-20s  %5d%n", "Task: "+ node.getNodeName(), startDateTime, finalDateTime,node.getTimeSpent().getSeconds());
        for(Interval interval : ((Task) node).getTaskIntervals()){
          System.out.printf("%-30s %-20s %-20s  %5d%n","Interval: ", interval.getStartDateTime().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")),interval.getFinalDateTime().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")), interval.getTimeSpent().getSeconds());
        }
      }
    }
    System.out.println("\n\n\n");

  }

  private void testSearchByTag(String tag){
    this.testLoading("testB.json", false);
    LOGGER.info("Iniciant test search by tag\n");

    TrackerNode proj1 = getTrackerNodeByName("software design");
    proj1.setTag("java");proj1.setTag("flutter");
    TrackerNode proj2 = getTrackerNodeByName("software testing");
    proj2.setTag("c++");proj2.setTag("Java");proj2.setTag("python");
    TrackerNode proj3 = getTrackerNodeByName("databases");
    proj3.setTag("SQL");proj3.setTag("python");proj3.setTag("C++");
    TrackerNode task2 = getTrackerNodeByName("first list");
    task2.setTag("java");
    TrackerNode task3 = getTrackerNodeByName("second list");
    task3.setTag("Dart");
    TrackerNode task5 = getTrackerNodeByName("first milestone");
    task5.setTag("Java");task5.setTag("IntelliJ");

    SearchByTagVisitor tagSearcher = new SearchByTagVisitor(tag);
    this.getTrackerNodes().get(0).accept(tagSearcher);

    if (!tagSearcher.getNodesWithTag().isEmpty()) {
      LOGGER.info("Se han encontrado " + tagSearcher.getNodesWithTag().size() + " con el tag '"+ tag +"'");
      for (TrackerNode nodeFound : tagSearcher.getNodesWithTag()) {
        LOGGER.info(nodeFound.getNodeName());
      }
    } else {
      LOGGER.info("No se han encontrado nodos con el tag '" + tag + "'\n");
    }

    LOGGER.info("\nFinal test searchByTag\n");
  }

  private void testTotalTime(String nodeName, LocalDateTime startDateTime, LocalDateTime finalDateTime){
    LOGGER.info("Iniciant test totalTime sobre "+nodeName);
    TrackerNode nodeTarget = this.getTrackerNodeByName(nodeName);
    TotalTimeVisitor totalTimeVisitor = new TotalTimeVisitor(startDateTime,finalDateTime);
    nodeTarget.accept(totalTimeVisitor);
    LOGGER.info("El temps total treballat per el node "+nodeName+" entre les dates donades es de: "
        +totalTimeVisitor.getDuration());
  }

  private void testTotalTimeTreeC(){
    //Pel test del total time
    //Arbre TestC
    //Data inici (t=0s): any 2020, mes 10, dia 27, hora 17, minut 23, segons 36
    //Data final (t=160s): any 2020, mes 10, dia 27, hora 17, minut 26, segons 16

    //Data inici per test 4 als 60s: any 2020, mes 10, dia 27, hora 17, minut 24, segons 36
    //Data final per test 4 als 120s: any 2020, mes 10, dia 27, hora 17, minut 25, segons 36
    LocalDateTime startDateTime= LocalDateTime.of(2020,10,27,17,23,36);
    LocalDateTime finalDateTime= LocalDateTime.of(2020,10,27,17,26,26);
    this.testTotalTime("root",startDateTime, finalDateTime);//haurà de mostrar 370seg 6:10
    LOGGER.debug("Esperat 370seg 6:10");

    startDateTime= LocalDateTime.of(2020,10,27,17,24,36);
    finalDateTime= LocalDateTime.of(2020,10,27,17,25,36);
    this.testTotalTime("T1",startDateTime, finalDateTime);//haurà de mostrar 80seg 1:20
    LOGGER.debug("Esperat 50seg 0:50");

    startDateTime= LocalDateTime.of(2020,10,27,17,24,36);
    finalDateTime= LocalDateTime.of(2020,10,27,17,25,36);
    this.testTotalTime("T2",startDateTime, finalDateTime);//haurà de mostrar 170seg 2:50
    LOGGER.debug("Esperat 40seg 0:40");

    startDateTime= LocalDateTime.of(2020,10,27,17,24,36);
    finalDateTime= LocalDateTime.of(2020,10,27,17,25,36);
    this.testTotalTime("T4",startDateTime, finalDateTime);//haurà de mostrar 190seg 3:10
    LOGGER.debug("Esperat 60seg 1:00");

    startDateTime= LocalDateTime.of(2020,10,27,17,24,36);
    finalDateTime= LocalDateTime.of(2020,10,27,17,25,36);
    this.testTotalTime("T5",startDateTime, finalDateTime);//haurà de mostrar 90seg 1:30
    LOGGER.debug("Esperat 30seg 0:30");
  }

  /*
   * Función encargada de instanciar los objetos que almacenarán los árboles y de iniciar el lanzamiento de
   * la ejecución de los tests.
   */
  public static void main(String[] arg) {
    TimeTracker timeTrackerAB = new TimeTracker(2);
    //timeTrackerAB.testA();
    //timeTrackerAB.testB();
    timeTrackerAB.testLoading("testB.json", false);//true si queremos comparar el árbol original y el cargado con JSON

    timeTrackerAB.testSearchByTag("python");

    //TimeTracker timeTrackerC = new TimeTracker(2);
    //timeTrackerC.testC();
    //timeTrackerC.testLoading("testC_copia_seguretat_per_testTotalsTimes.json",false);//true si queremos comparar el árbol original y el cargado con JSON

    //timeTrackerC.testTotalTimeTreeC();

    System.exit(0);
  }
}