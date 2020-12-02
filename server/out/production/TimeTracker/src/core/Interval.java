package core;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import visitor.NodeVisitor;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Observable;
import java.util.Observer;
import java.time.format.DateTimeFormatter;

/*
 * La clase Interval es la encargada de almacenar los tiempos de inicio, fin y duración relacionados con la tarea
 * padre. Estos tiempos se actualizan cada vez que el objeto TimeCounter (Obervable) notifica al intervalo
 * (Observer)
 */
public class Interval implements Observer {
  private final Task parentTask;
  private LocalDateTime startDateTime;
  private LocalDateTime finalDateTime;
  private Duration timeSpent;
  private final int period;
  private final static Logger LOGGER = LoggerFactory.getLogger("core.Interval");
  private int nodeId;

  //TODO
  public Interval(Task parent, int period, int activityId) {
  //public Interval(Task parent, int period) {
    this.parentTask = parent;
    this.period = period;
    this.timeSpent = Duration.ZERO;
    //TODO
    this.nodeId = activityId;
    LOGGER.debug("Interval creat.");
  }

  public void accept(NodeVisitor visitor){
    visitor.visitInterval(this);
  }

  public LocalDateTime getStartDateTime() {
    return startDateTime;
  }

  public LocalDateTime getFinalDateTime() {
    return finalDateTime;
  }

  public Duration getTimeSpent() {
    return timeSpent;
  }

  /*
   * Función que actualiza los tiempos de inicio, fin y duración del intervalo
   */
  @Override
  public void update(Observable o, Object arg) {
    if(this.startDateTime == null) {
      this.startDateTime = (LocalDateTime) arg;
      this.startDateTime = this.startDateTime.minusSeconds(this.period);
    }
    this.finalDateTime = (LocalDateTime) arg;
    this.timeSpent = this.timeSpent.plusSeconds(this.period);

    LOGGER.debug("Interval:" + " " +
                this.startDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")) + " " +
                this.finalDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")) + " " +
                this.timeSpent.getSeconds());

    this.parentTask.updateTimes(startDateTime, finalDateTime);
  }

  /*
   * Crea el objeto Interval como objeto JSONObject y lo devuelve para que la clase DataManager lo alamacene en un
   * fichero .txt
   */
  public JSONObject getJsonobject(){
    JSONObject jsonInterval = new JSONObject();
    jsonInterval.put("startTime",this.startDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")));
    jsonInterval.put("finalTime",this.finalDateTime.format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")));
    jsonInterval.put("duration",this.timeSpent.getSeconds());
    jsonInterval.put("parentName", this.parentTask.getNodeName());
    //TODO
    jsonInterval.put("nodeId", this.getNodeId());

    return jsonInterval;
  }

  public void setIntervalTimes(LocalDateTime startDateTime, LocalDateTime finalDateTime, Duration timeSpent){
    this.startDateTime = startDateTime;
    this.finalDateTime = finalDateTime;
    this.timeSpent = timeSpent;

    //Llama a las funciones de actualizar de la tarea superior para que actualicen sus tiempos.
    this.parentTask.updateTimes(startDateTime, finalDateTime);
  }

  //TODO
  public int getNodeId() {
    return this.nodeId;
  }

}