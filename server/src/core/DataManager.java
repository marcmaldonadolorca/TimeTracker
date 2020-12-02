package core;

import java.util.List;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONTokener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileWriter; //Escritura de ficheros de texto
import java.io.IOException; //Gesitón de errores
import java.io.InputStream; //Lectura de ficheros de texto

/*
 * La clase DataManager es la encargada de gestionar la lectura y escritura de los nodos (proyectos, tareas e
 * intervalos) del árbol para almacenar los objetos JSONObject en ficheros .txt y viceversa.
 */
public class DataManager {
  private File storageFile;
  private final String fileName;
  private final static Logger LOGGER = LoggerFactory.getLogger("core.DataManager");

  /*
   * Crea el fichero donde se almacenará la estructura del árbol.
   */
  public DataManager(String fileName) {
    try {
      this.storageFile = new File(fileName);
      if (this.storageFile.createNewFile()) {
        LOGGER.info("Fichero creado: " + this.storageFile.getName());
      } else {
        LOGGER.warn("El fichero ya existe.");
      }
    } catch (IOException e) {
      LOGGER.error("Error de creación del fichero: " + e.getMessage());
      e.printStackTrace();
    }
    this.fileName = fileName;
  }

  /*
   * Obtiene todos los datos del árbol almacenados en un objeto JSONObject y los almacena en el fichero .txt
   */
  //TODO
  public void fromJsonToFile(List<TrackerNode> trackerNodes, int biggestIdPlusOne) {
  //public void fromJsonToFile(List<TrackerNode> trackerNodes) {
    JSONArray jsonTree = new JSONArray();

    //Se inicia en la segunda posición porque no es necesario almacenar el root.
    for (int i = 1; i < trackerNodes.size(); i++) {
      jsonTree.put(trackerNodes.get(i).getJsonObject());
    }

    LOGGER.debug("JSON Tree: " + jsonTree.toString());
    JSONObject dataSaved = new JSONObject();
    dataSaved.put("data", jsonTree);
    //TODO
    dataSaved.put("biggestIdPlusOne", biggestIdPlusOne);

    try {
      FileWriter fileWriter = new FileWriter(this.storageFile, false);
      fileWriter.write(dataSaved.toString());
      fileWriter.close();
    } catch (IOException e) {
      LOGGER.error("Error: " + e.getMessage());
      e.printStackTrace();
    }

    LOGGER.info("El JSON se ha guardado correctamente en un fichero.");
  }

  /*
   * Obtiene los datos del árbol almacenados en un fichero .txt y se los pasa a la clase TimeTracker para que
   * reconstruya el árbol
   */
  public void fromFileToJson(TimeTracker tracker) {
    InputStream readFile = DataManager.class.getResourceAsStream("/" + this.fileName);

    if (readFile == null) {
      throw new NullPointerException("Cannot find resource file " + this.fileName);
    }

    JSONTokener tokener = new JSONTokener(readFile);
    JSONObject object = new JSONObject(tokener);
    JSONArray objectsArray = new JSONArray(object.get("data").toString());
    //TODO
    int biggestIdPlusOne = object.getInt("biggestIdPlusOne");

    //TODO
    tracker.createNewTreeFromJson(objectsArray, biggestIdPlusOne);
    //tracker.createNewTreeFromJson(objectsArray);
    LOGGER.info("Se ha cargado correctamente el JSON desde un fichero.");
  }
}