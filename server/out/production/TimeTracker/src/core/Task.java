package core;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import visitor.NodeVisitor;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/*
 * La clase Task es la encargada de almacenar, iniciar y parar los intervalos asociados a la tarea (Task).
 */
public class Task extends TrackerNode {
  private List<Interval> taskIntervals;
  private Boolean taskIsRunning;
  private final static Logger LOGGER = LoggerFactory.getLogger("core.Task");

  private boolean invariant(){
    boolean hasParent = (this.parentNode != null);
    boolean hasName = !this.nodeName.equals("");

    return (hasName && hasParent);
  }


  public Task(String nodeName, Project parentNode) {
    this.nodeName = nodeName;
    this.parentNode = parentNode;
    this.taskIntervals = new ArrayList<>();
    this.taskIsRunning = false;

    LOGGER.debug("Task " + this.nodeName + " creada.");

    assert invariant();
  }

  public void accept(NodeVisitor visitor){
    assert invariant();
    //pre
    assert (visitor != null):"No se puede acceptar sin visitor(null)";

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<Interval> taskIntervalsPre = new ArrayList<>(this.taskIntervals);
    Boolean taskIsRunningPre = this.taskIsRunning;
    List<String> tagListPre = new ArrayList<>(this.tagList);

    visitor.visitTask(this);

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert taskIntervalsPre.equals(this.taskIntervals);
    assert taskIsRunningPre == this.taskIsRunning;
    assert tagListPre.equals(this.tagList);

    assert invariant();
  }

  public List<Interval> getTaskIntervals() {
    assert invariant();

    return taskIntervals;
  }

  public boolean getStatus() {
    assert invariant();

    return this.taskIsRunning;
  }

  public void setTimeStatus(Boolean timeStatus) {
    assert invariant();

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<Interval> taskIntervalsPre = new ArrayList<>(this.taskIntervals);
    List<String> tagListPre = new ArrayList<>(this.tagList);

    this.taskIsRunning = timeStatus;

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert taskIntervalsPre.equals(this.taskIntervals);
    assert (this.taskIsRunning == timeStatus): "No se ha cambiado el estado de la Task";
    assert tagListPre.equals(this.tagList);

    assert invariant();
  }

  /*
   * Crea un nuevo Interval y lo añade a la lista de intervalos de la tarea (Task)
   */
  public Interval startInterval(int period) {
    assert invariant();
    //pre
    assert (period >=0);

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<Interval> taskIntervalsPre = new ArrayList<>(this.taskIntervals);
    Boolean taskIsRunningPre = this.taskIsRunning;
    List<String> tagListPre = new ArrayList<>(this.tagList);

    setTimeStatus(true);
    Interval interval = new Interval(this,period);
    this.taskIntervals.add(interval);

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert (!taskIntervalsPre.equals(this.taskIntervals)):"No se ha modificado la lista de intervalos";
    assert (taskIsRunningPre != this.taskIsRunning): "No se ha modificado el estatus de la Task a runnning";
    assert tagListPre.equals(this.tagList);

    assert invariant();

    return interval;
  }

  public Interval stopInterval() {
    assert invariant();

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<Interval> taskIntervalsPre = new ArrayList<>(this.taskIntervals);
    Boolean taskIsRunningPre = this.taskIsRunning;
    List<String> tagListPre = new ArrayList<>(this.tagList);

    setTimeStatus(false);
    int lastIndex = taskIntervals.size() - 1;

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert (taskIntervalsPre.equals(this.taskIntervals)):"Se ha modificado la lista de intervalos";
    assert (taskIsRunningPre != this.taskIsRunning): "No se ha modificado el estatus de la Task a parada";
    assert tagListPre.equals(this.tagList);

    assert invariant();

    return this.taskIntervals.get(lastIndex);
  }

  /*
   * Gestiona las fechas recibidas y calcula los periodos y la duración para actualizar los tiempos del
   * proyecto (Project) padre
   */
  public void updateTimes(LocalDateTime startDateTime, LocalDateTime finalDateTime) {
    assert invariant();
    //pre
    assert (startDateTime != null): "Tiempo de inicio sin determinar";
    assert (finalDateTime != null): "Timepo de finalización sin determinar";
    assert (finalDateTime.isAfter(startDateTime)):"El timepo de finalización dado és anterior al de inicio dado";

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    Duration timeSpentPre = this.timeSpent;
    List<Interval> taskIntervalsPre = new ArrayList<>(this.taskIntervals);
    Boolean taskIsRunningPre = this.taskIsRunning;
    List<String> tagListPre = new ArrayList<>(this.tagList);

    //Actualiza el tiempo inicial y final
    this.startDateTime = (this.startDateTime==null || startDateTime.isBefore(this.startDateTime)) ?
                          startDateTime: this.startDateTime;
    this.finalDateTime = (this.finalDateTime==null || finalDateTime.isAfter(this.finalDateTime)) ?
                          finalDateTime: this.finalDateTime;

    Duration totalTime = Duration.ZERO;
    for (Interval intervalOfTheList : this.taskIntervals) {
      totalTime = totalTime.plus(intervalOfTheList.getTimeSpent());
    }

    this.timeSpent = totalTime;

    LOGGER.debug("Activity: " + this.nodeName + " " +
                this.startDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")) + " " +
                this.finalDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")) + " " +
                this.timeSpent.getSeconds());

    if (parentNode != null) {
      parentNode.updateTimes(this.startDateTime,this.finalDateTime);
    }

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert (!timeSpentPre.equals(this.timeSpent)): "Tiempo total(timeSpent) no actualizado";
    assert taskIntervalsPre.equals(this.taskIntervals);
    assert taskIsRunningPre == this.taskIsRunning;
    assert tagListPre.equals(this.tagList);

    assert invariant();
  }

  /*
   * Devuelve el objeto de tipo Task en formato JSONObject para que la clase DataManager lo alamacene en un
   * fichero .txt
   */
  public JSONObject getJsonObject(){
    assert invariant();

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<Interval> taskIntervalsPre = new ArrayList<>(this.taskIntervals);
    Boolean taskIsRunningPre = this.taskIsRunning;
    List<String> tagListPre = new ArrayList<>(this.tagList);

    //Obtiene los datos del nodo, incluyendo el array de intervalos y los almacena en un objeto de tipo JSONObject.
    //No es necesario almacenar los tiempos de los nodos porque ya se obtendrán de los intervalos al ejecutar la
    //función updateTimes()
    JSONObject jsonObject=new JSONObject();
    jsonObject.put("type","task");
    jsonObject.put("name",this.nodeName);
    jsonObject.put("parentName", this.parentNode.getNodeName());

    //En caso de que la tarea (Task) contenga intervalos, se almacenarán en una lista de tipo JSONArray dentro del
    //objeto JSONObject asociado a la tarea.
    if(!taskIntervals.isEmpty()){
      jsonObject.put("childs","exist");
      JSONArray intervalChilds = new JSONArray();
      for(Interval interval: taskIntervals) {
        intervalChilds.put(interval.getJsonobject());
      }
      jsonObject.put("childsList",intervalChilds);
    }
    else{
      jsonObject.put("childs","empty");
    }

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert taskIntervalsPre.equals(this.taskIntervals);
    assert taskIsRunningPre == this.taskIsRunning;
    assert tagListPre.equals(this.tagList);

    LOGGER.debug("JSONObject: " + jsonObject);

    assert invariant();

    return jsonObject;
  }

  /*
   * Obtiene los datos de cada intervalo de la lista almacenada en el JSONArray y crea los objetos Interval
   * asociados a estos datos, asignánolos a las tarea correspondiente.
   */
  public void setChildsFromJSON(JSONArray arrayIntervals, int period){
    assert invariant();
    //pre
    assert (arrayIntervals != null): "JSONArray vació.";
    assert (period >= 0): "Periodo invàlido.";

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    List<Interval> taskIntervalsPre = new ArrayList<>(this.taskIntervals);
    Boolean taskIsRunningPre = this.taskIsRunning;
    List<String> tagListPre = new ArrayList<>(this.tagList);

    for(int j = 0; j < arrayIntervals.length(); j++) {
      JSONObject arrayObject = arrayIntervals.getJSONObject(j);
      //String parentNode = arrayObject.getString("parentName");
      String startTime = arrayObject.getString("startTime");
      String finalTime = arrayObject.getString("finalTime");
      long duration = arrayObject.getLong("duration");

      //Convierte los datos obtenidos de String al tipo esecífico de cada atributo
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");
      LocalDateTime startDateTime = LocalDateTime.parse(startTime, formatter);
      LocalDateTime finalDateTime = LocalDateTime.parse(finalTime, formatter);
      Duration timeSpent = Duration.ofSeconds(duration,0);

      //Crea un nuevo intervalo añadiéndolo a la tarea padre (this)
      Interval interval = new Interval(this, period);
      this.taskIntervals.add(interval);

      //Asigna los tiempos obtenidos del JSONObject al nuevo intervalo asignado a la tarea (Task)
      interval.setIntervalTimes(startDateTime, finalDateTime, timeSpent);
    }

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert (!taskIntervalsPre.equals(this.taskIntervals)):"No se ha modificado la lista de intervalos";
    assert taskIsRunningPre == this.taskIsRunning;
    assert tagListPre.equals(this.tagList);

    assert invariant();
  }
}