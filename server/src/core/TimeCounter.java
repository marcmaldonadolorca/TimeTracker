package core;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.Observable;
import java.util.Timer;
import java.util.TimerTask;

/*
 * La clase TimeCounter es la encargada de realizar la función de reloj en la aplicación para actualizar las
 * correspondientes tareas activas (sus últimos intervalos). Su constructor es privado para conseguir que solo
 * pueda haber un único objeto que desenpeñe la función de reloj.
 */
public class TimeCounter extends Observable {
  private LocalDateTime date;
  private static final TimeCounter uniqueInstance = new TimeCounter();
  private static final int period = 2; //Segundos
  private static Logger LOGGER;

  private TimeCounter() {
    LOGGER = LoggerFactory.getLogger("core.TimeCounter");
    Timer timer = new Timer();
    LOGGER.info("TimeCounter creat.");

    //Crea el thread que notifica periódicamente a los intervalos almacenados en la lista de observers.
    TimerTask repeatedTask = new TimerTask() {
      public void run() {
        date = LocalDateTime.now();
        //LOGGER.debug("run() done on " + date.getSecond());
        setChanged();
        notifyObservers(date);
        //LOGGER.debug("Notificats");
      }
    };

    //Este objeto es el responsable de llamar a la función que cuenta el tiempo y actualiza los períodos de las tareas
    //mediante el uso de la función run() sobrecargada en el constructor en el momento de crear el thread
    timer.scheduleAtFixedRate(repeatedTask, 0, 1000 * period);
  }

  /*
  *  Método para conseguir instancias del  objeto reloj único
  */
  public static TimeCounter getInstance(){
    return uniqueInstance;
  }
}