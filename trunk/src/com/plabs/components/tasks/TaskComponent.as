
package com.plabs.components.tasks {
import com.pblabs.engine.core.ITickedObject;
import com.pblabs.engine.entity.IEntity;
import com.threerings.flashbang.pushbutton.EntityComponent;
import com.threerings.util.Map;
import com.threerings.util.Maps;



public class TaskComponent extends EntityComponent
    implements ITickedObject
{
    public static const COMPONENT_NAME :String = "tasks";
    public function TaskComponent ()
    {
        super(COMPONENT_NAME);
    }

    public function onTick (dt :Number) :void
    {
        update(dt);
    }

    public function update (dt :Number) :void
    {
        _updatingTasks = true;
        _anonymousTasks.update(dt, owner);
        if (!_namedTasks.isEmpty()) {
            var thisEntity :IEntity = owner;
            _namedTasks.forEach(updateNamedTaskContainer);
        }
        _updatingTasks = false;

        function updateNamedTaskContainer (name :*, tasks :*) :void {
            // Tasks may be removed from the object during the _namedTasks.forEach() loop.
            // When this happens, we'll get undefined 'tasks' objects.
            if (undefined !== tasks) {
                (tasks as ParallelTask).update(dt, thisEntity);
            }
        }
    }


        /** Adds an unnamed task to this IEntity. */
    public function addTask (task :IEntityTask) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        _anonymousTasks.addTask(task);
    }

    /** Adds a named task to this IEntity. */
    public function addNamedTask (name :String, task :IEntityTask,
        removeExistingTasks :Boolean = false) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        if (null == name || name.length == 0) {
            throw new ArgumentError("name must be at least 1 character long");
        }

        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
        if (null == namedTaskContainer) {
            namedTaskContainer = new ParallelTask();
            _namedTasks.put(name, namedTaskContainer);
        } else if (removeExistingTasks) {
            namedTaskContainer.removeAllTasks();
        }

        namedTaskContainer.addTask(task);
    }

    /** Removes all tasks from the IEntity. */
    public function removeAllTasks () :void
    {
        if (_updatingTasks) {
            // if we're updating tasks, invalidate all named task containers so that
            // they stop iterating their children
            for each (var taskContainer :TaskContainer in _namedTasks.values()) {
                taskContainer.removeAllTasks();
            }
        }

        _anonymousTasks.removeAllTasks();
        _namedTasks.clear();
    }

    /** Removes all tasks with the given name from the IEntity. */
    public function removeNamedTasks (name :String) :void
    {
        if (null == name || name.length == 0) {
            throw new ArgumentError("name must be at least 1 character long");
        }

        var taskContainer :TaskContainer = _namedTasks.remove(name);

        // if we're updating tasks, invalidate this task container so that
        // it stops iterating its children
        if (null != taskContainer && _updatingTasks) {
            taskContainer.removeAllTasks();
        }
    }

    /** Returns true if the IEntity has any tasks. */
    public function hasTasks () :Boolean
    {
        if (_anonymousTasks.hasTasks()) {
            return true;
        } else {
            for each (var namedTaskContainer :* in _namedTasks) {
                if ((namedTaskContainer as ParallelTask).hasTasks()) {
                    return true;
                }
            }
        }

        return false;
    }

    /** Returns true if the IEntity has any tasks with the given name. */
    public function hasTasksNamed (name :String) :Boolean
    {
        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
        return (null == namedTaskContainer ? false : namedTaskContainer.hasTasks());
    }

    protected var _anonymousTasks :ParallelTask = new ParallelTask();

    // stores a mapping from String to ParallelTask
    protected var _namedTasks :Map = Maps.newSortedMapOf(String);

    protected var _updatingTasks :Boolean;
}
}
