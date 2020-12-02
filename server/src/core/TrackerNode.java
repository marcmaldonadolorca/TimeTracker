package core;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import visitor.NodeVisitor;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/*
 * La clase TrackerNode es la encargada de definir los objetos mínimos que debe contener cada nodo del árbol.
 * Es la clase padre de las clases Project y Task
 */
public abstract class TrackerNode {
  protected String nodeName;
  protected Project parentNode;
  protected LocalDateTime startDateTime;
  protected LocalDateTime finalDateTime;
  protected Duration timeSpent;
  protected List<String> tagList;
  private final static Logger LOGGER = LoggerFactory.getLogger("core.TrackerNode");
  protected int nodeId;

  public TrackerNode() {
    this.timeSpent = Duration.ZERO;
    this.tagList = new ArrayList<>();
    LOGGER.debug("TrackerNode creat");
  }

  public abstract void accept(NodeVisitor visitor);

  protected void setTag(String tag) {this.tagList.add(tag);}

  public List<String> getTagList(){return this.tagList;}

  public String getNodeName() {
    return nodeName;
  }

  public LocalDateTime getStartDateTime() {
    return startDateTime;
  }

  public LocalDateTime getFinalDateTime() {
    return finalDateTime;
  }

  public Duration getTimeSpent() { return timeSpent; }

  public abstract void updateTimes(LocalDateTime startDateTime, LocalDateTime finalDateTime);

  public abstract JSONObject getJsonObject();

  public abstract TrackerNode findActivityById(int n);

  public abstract JSONObject toJson(int i);

  //TODO
  public int getNodeId() {
    return this.nodeId;
  }
}