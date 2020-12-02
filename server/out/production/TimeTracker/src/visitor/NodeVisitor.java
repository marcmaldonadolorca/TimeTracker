package visitor;

import core.Interval;
import core.Project;
import core.Task;

/**
 * La clase NodeVisitor es la interfaz que define las funciones que implementarán las clases SearchByTagVisitor y
 * TotalTimeVisitor, que son las encargadas de recorrer el árbol para realizar las funcionalidades pertinentes
 * en cada nodo.
 */
public abstract class NodeVisitor {

  public abstract void visitProject(Project project);

  public abstract void visitTask(Task task);

  public abstract void visitInterval(Interval interval);
}
