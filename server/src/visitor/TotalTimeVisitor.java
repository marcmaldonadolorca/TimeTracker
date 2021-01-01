package visitor;

import core.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.time.LocalDateTime;
import java.time.Duration;

/**
 * La clase TotalTimeVisitor es la encargada de contabilizar el tiempo de todos los nodos hijos de un nodo concreto,
 * y que se encuentren dentro del intervalo especificado entre startDateTime y finalDateTime.
 * Esto sirve para determinar el tiempo invertido en la ejecución de dicho proyecto o tarea.
 */
public class TotalTimeVisitor extends NodeVisitor {
  private final LocalDateTime startDateTime;
  private final LocalDateTime finalDateTime;
  private Duration totalTime;
  private final static Logger LOGGER = LoggerFactory.getLogger("visitor.TotalTimeVisitor");

  public TotalTimeVisitor(LocalDateTime startDateTime, LocalDateTime finalDateTime){
    this.startDateTime = startDateTime;
    this.finalDateTime = finalDateTime;
    this.totalTime = Duration.ZERO;
    LOGGER.debug("TotalTimeVisitor creado.");
  }

  public Duration getDuration(){return totalTime;}

  private boolean mustVisit(LocalDateTime startDateTime, LocalDateTime finalDateTime){
    boolean visit = true;

    //solo existen dos situaciones en que no se tiene que visitar.
    if (finalDateTime.isBefore(this.startDateTime) || finalDateTime.isEqual(this.startDateTime)) {
      //Situación 1: cuando el periodo final es anterior al inicio del periodo a contabilizar
      visit = false;
    } else if (startDateTime.isAfter(this.finalDateTime)|| startDateTime.isEqual(this.finalDateTime)) {
      //Situación 2: cuando empieza despues del final de nuestro periodo a contabilozar
      visit = false;
    }

    return visit;
  }

  public void visitProject(Project project){
    //si tiene tiempos y estos son anteriores a la fecha final del periodo de contabilizacion evaluamos
    if (project.getFinalDateTime()!= null && mustVisit(project.getStartDateTime(),project.getFinalDateTime())){
      for(TrackerNode childNode : project.getChildNodes()){
        //Solo visitamos cuando tengan tiempos para contabilizar (final despues de nuestro start)
        if(childNode.getFinalDateTime()!=null && mustVisit(childNode.getStartDateTime(),childNode.getFinalDateTime())){
          childNode.accept(this);
        }
      }
    }
  }

  public void visitTask(Task task){
    //Si  hemos llagado a visitar un Task és porque tiene algun intervalo que nos interesa
    for (Interval childInterval : task.getTaskIntervals()){
      if(mustVisit(childInterval.getStartDateTime(),childInterval.getFinalDateTime())){//intervalo con tiempos para contabilizar
        childInterval.accept(this);
      }
    }
  }

  public void visitInterval(Interval interval) {
    LocalDateTime startIntervalDate = interval.getStartDateTime();
    LocalDateTime finalIntervalDate = interval.getFinalDateTime();

    //4 escenarios posibles
    //caso 1 intervalo empieza antes y termina antes/igual del final periodo contabilización
    //caso 2 intervalo empieza antes y termina después del final periodo contabilización
    //caso 3 intervalo empieza después y termina antes/igual del final periodo contabilización
    //caso 4 intervalo empieza después y termina después del final periodo contabilización

    //casos 1 y 2
    if (startIntervalDate.isBefore(this.startDateTime) || startIntervalDate.isEqual(this.startDateTime)) {
      if (finalIntervalDate.isBefore(this.finalDateTime) || finalIntervalDate.isEqual(this.finalDateTime)) { //1
        this.totalTime = this.totalTime.plus(Duration.between(finalIntervalDate, this.startDateTime).abs());
      }
      else {//2
        this.totalTime = this.totalTime.plus(Duration.between(this.finalDateTime, this.startDateTime).abs());
      }
    } else { //3
      if (finalIntervalDate.isBefore(this.finalDateTime) || finalIntervalDate.isEqual(this.finalDateTime)) {
        this.totalTime = this.totalTime.plus(Duration.between(finalIntervalDate, startIntervalDate).abs());
      }
      else {//4
        this.totalTime = this.totalTime.plus(Duration.between(this.finalDateTime, startIntervalDate).abs());
      }
    }
  }
}