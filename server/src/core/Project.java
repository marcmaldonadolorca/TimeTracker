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
import java.util.Comparator;

/*
 * La clase Project es la encargada de almacenar y gestionar los distintos proyectos (Project) y tareas (Task)
 * del árbol de nodos.
 */
public class Project extends TrackerNode {
  private List<TrackerNode> childNodes;
  private final static Logger LOGGER = LoggerFactory.getLogger("core.Project");

  private boolean invariant(){
    boolean hasParent = ((!this.nodeName.equals("root")) && (this.parentNode != null)) ;
    boolean isRoot = this.nodeName.equals("root");
    boolean hasName = !this.nodeName.equals("");

    return (hasName) && (isRoot || hasParent);
  }

  //TODO
  public Project(String nodeName, Project parentNode, int activityId) {
  //public Project(String nodeName, Project parentNode) {
    this.nodeName = nodeName;
    this.parentNode = parentNode;
    this.childNodes = new ArrayList<>();
    //TODO
    this.nodeId = activityId;
    LOGGER.debug("Projecte " + this.nodeName + " creat.");

    assert invariant();
  }

  public void accept(NodeVisitor visitor){
    assert invariant();
    //pre
    assert (visitor != null) : "No se puede acceptar sin visitor(null)";

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<TrackerNode> childNodesPre = new ArrayList<>(this.childNodes);
    List<String> tagListPre = new ArrayList<>(this.tagList);

    visitor.visitProject(this);

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert childNodesPre.equals(this.childNodes);
    assert tagListPre.equals(this.tagList);

    assert invariant();
  }

  public List<TrackerNode> getChildNodes() {
    assert invariant();

    return childNodes;
  }

  public void setChild(TrackerNode childNode) {
    assert invariant();
    //pre
    assert (childNode != null):"childNode a poner és null";

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<TrackerNode> childNodesPre = new ArrayList<>(this.childNodes);
    List<String> tagListPre = new ArrayList<>(this.tagList);

    this.childNodes.add(childNode);

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert (!childNodesPre.equals(this.childNodes)):"No se ha modificado la lista de hijos al añadir uno";
    assert tagListPre.equals(this.tagList);

    assert invariant();
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
    assert (finalDateTime.isAfter(startDateTime)):"El timepo de finalización dado es anterior al de inicio dado";

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    Duration timeSpentPre = this.timeSpent;
    List<TrackerNode> childNodesPre = new ArrayList<>(this.childNodes);
    List<String> tagListPre = new ArrayList<>(this.tagList);

    //Actualiza el tiempo inicial y final
    this.startDateTime = (this.startDateTime == null || startDateTime.isBefore(this.startDateTime)) ?
                          startDateTime : this.startDateTime;
    this.finalDateTime = (this.finalDateTime == null || finalDateTime.isAfter(this.finalDateTime)) ?
                          finalDateTime : this.finalDateTime;

    Duration totalTime = Duration.ZERO;
    for (TrackerNode ProjectOfTheList : this.childNodes) {
      totalTime = totalTime.plus(ProjectOfTheList.timeSpent);
    }
    this.timeSpent = totalTime;

    LOGGER.debug("activity: " + this.nodeName + " " +
                this.startDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")) + " " +
                this.finalDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")) + " " +
                this.timeSpent.getSeconds());

    if (this.parentNode != null) {
      this.parentNode.updateTimes(this.startDateTime, this.finalDateTime);
    }

    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert (!timeSpentPre.equals(this.timeSpent)): "Tiempo total(timeSpent) no actualizado";
    assert childNodesPre.equals(this.childNodes);
    assert tagListPre.equals(this.tagList);

    assert invariant();
  }

  /*
   * Crea el objeto Project como objeto JSONObject y lo devuelve para que la clase DataManager lo alamacene en un
   * fichero .txt
   */
  public JSONObject getJsonObject() {
    assert invariant();

    String nodeNamePre = this.nodeName;
    Project parentNodePre = this.parentNode;
    LocalDateTime startDateTimePre = this.startDateTime;
    LocalDateTime finalDateTimePre = this.finalDateTime;
    Duration timeSpentPre = this.timeSpent;
    List<TrackerNode> childNodesPre = new ArrayList<>(this.childNodes);
    List<String> tagListPre = new ArrayList<>(this.tagList);

    //No es necesario almacenar los tiempos de los nodos porque ya se obtendrán de los intervalos al ejecutar la
    //función updateTimes()
    JSONObject jsonObject = new JSONObject();
    jsonObject.put("type", "project");
    jsonObject.put("name", this.nodeName);
    if(this.parentNode != null) {
      jsonObject.put("parentName", this.parentNode.getNodeName());
    } else {
      jsonObject.put("parentName", "");
    }
    //TODO
    jsonObject.put("nodeId", this.getNodeId());
    JSONArray tags = new JSONArray();
    for(String tag: this.tagList) {
      tags.put(tag);
    }
    jsonObject.put("tags",tags);
    //post
    assert nodeNamePre.equals(this.nodeName);
    assert parentNodePre == this.parentNode;
    assert startDateTimePre == this.startDateTime;
    assert finalDateTimePre == this.finalDateTime;
    assert timeSpentPre.equals(this.timeSpent);
    assert childNodesPre.equals(this.childNodes);
    assert tagListPre.equals(this.tagList);

    LOGGER.debug("JSONObject: " + jsonObject);

    assert invariant();

    return jsonObject;
  }

  public TrackerNode findActivityById(int n) {
    TrackerNode foundNode = null;
    if (this.getNodeId() == n) {
      foundNode = this;
    } else {
      for (TrackerNode childNode : childNodes) {
        if (childNode.getNodeId() == n) {
          foundNode = childNode;
          break;
        } else if (childNode instanceof Project) {
          foundNode = ((Project) childNode).findActivityById(n);
          if (foundNode != null) {
            break;
          }
        }
      }
    }

    return foundNode;
  }

  public JSONObject toJson(int i) {
    JSONObject json = new JSONObject();
    json.put("name", this.nodeName);
    json.put("id",this.nodeId);
    json.put("class","project");
    long durationInSeconds = this.timeSpent.toHours()*3600+this.timeSpent.toMinutes()*60+this.timeSpent.getSeconds();
    json.put("duration",durationInSeconds);
    if(this.startDateTime!=null){
      json.put("initialDate",this.startDateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    }else { json.put("initialDate", JSONObject.NULL);}
    if(this.finalDateTime!=null){
      json.put("finalDate",this.finalDateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    }else { json.put("finalDate", JSONObject.NULL);}

    //TrackerNode.sort(this.childNodes, compare(<TrackerNode>));
    //childNodes.sort(compare.comparing);
//    Collections.sort(childNodes, new Comparator<CustomData>() {
//      @Override
//      public int compare(CustomData lhs, CustomData rhs) {
//        // -1 - less than, 1 - greater than, 0 - equal, all inversed for descending
//        return lhs.customInt > rhs.customInt ? -1 : (lhs.customInt < rhs.customInt) ? 1 : 0;
//      }
//    });

    JSONArray tags= new JSONArray();
    for(String tag: this.tagList){
      tags.put(tag);
    }
    json.put("tags",tags);

    JSONArray activities= new JSONArray();
    if (i > 0) {
      for (TrackerNode child : this.childNodes) {
        activities.put(child.toJson(i-1));
      }
    }
    json.put("activities",activities);

    boolean running = false;
    running = activeChilds(running);
    json.put("activeChilds",running);

    return json;
  }
  //recursivament explora arbre fills fins que troba una tasca active
  public boolean activeChilds(boolean running){
    int i = 0;
    while(!running && i<childNodes.size()){
      running = childNodes.get(i).activeChilds(running);
      i++;
    }
    return running;
  }

  //Per la sobre carrega de la comparació per ordenar
  //finalDateTime.isBefore(this.finalDateTime)
  //finalDateTime.isAfter(this.finalDateTime)
  public boolean compare(TrackerNode first, TrackerNode second){
    return first.getFinalDateTime().isAfter(second.getFinalDateTime());
  }


}