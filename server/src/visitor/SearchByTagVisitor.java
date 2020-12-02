package visitor;

import core.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.ArrayList;
import java.util.List;

/**
 * La clase SearchByTagVisitor es la encargada de recorrer todos los nodos del árbol comprobando, en cada uno de
 * los nodos, si el tag buscado coincide con alguno de los tags almacenados en la lista de tags del nodo en cuestión.
 */
public class SearchByTagVisitor extends NodeVisitor {
  private String tagToSearch;
  private List<TrackerNode> nodesWithTag;
  private final static Logger LOGGER = LoggerFactory.getLogger("visitor.SearchByTagVisitor");

  public List<TrackerNode> getNodesWithTag() {
    return this.nodesWithTag;
  }

  public SearchByTagVisitor(String listOfTags) {
    this.nodesWithTag = new ArrayList<>();
    this.tagToSearch = listOfTags;
    LOGGER.debug("SearchByTagVisitor creado. Visitor de: " + this.tagToSearch);
  }

  public void visitProject(Project project) {
    for(String nodeTag : project.getTagList()) {
      if (nodeTag.equalsIgnoreCase(this.tagToSearch)) {
        this.nodesWithTag.add(project);
        LOGGER.debug("Proyecto " + project.getNodeName() + " añadido a la lista de búsqueda.");
        break;
      }
    }

    //si hay hijos los visitamos
    if(!project.getChildNodes().isEmpty()) {
      for (TrackerNode childNode : project.getChildNodes()) {
        childNode.accept(this);
      }
    }
  }

  public  void visitTask(Task task){
    for(String nodeTag : task.getTagList()){
      if (nodeTag.equalsIgnoreCase(this.tagToSearch)){
        this.nodesWithTag.add(task);
        LOGGER.debug("Task " + task.getNodeName() + " añadido a la lista de búsqueda.");
        break;
      }
    }
  }

  public void visitInterval(Interval interval){}//no visitamos inervalos porque de momento no pueden tener tags
}